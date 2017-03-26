# do this once
sudo sysctl -w net.ipv4.ip_forward=1
echo "net.ipv4.ip_forward=1" | sudo tee /etc/sysctl.d/30-ipforward.conf
# iptables service needs to be enables so iptables rules are read from /etc/iptables/iptables.rules after boot of host
sudo iptables -t nat -A POSTROUTING -o eth1 -j MASQUERADE #eth1: internet facing interface
sudo iptables -A FORWARD -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
sudo iptables -A FORWARD -s 10.0.0.0/16 -i br0 -m conntrack --ctstate NEW -j ACCEPT
sudo bash -c "iptables-save > /etc/iptables/iptables.rules"
 
# setup (put this in/etc/libvirt/hooks/daemon if using libvirt or top of qemu start script):
pidfile=qemu_setup.pid
if [ ! -f "/tmp/$pidfile" ]; then
    ip link add name br0 type bridge
    ip addr add 10.0.1.1/24 dev br0 # <- this is your gateway
    ip link set br0 up
    ip tuntap add dev tap0 mode tap
    ip link set tap0 master br0
    ip link set tap0 up promisc on
    echo $$ > $pidfile
    fi
# rest of qemu start script if not using libvirt:
qemu-system-x86_64 -net nic,model=e1000 -net tap,ifname=tap0,script=no,downscript=no # ... other options ...
