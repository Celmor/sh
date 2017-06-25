#!/bin/bash
#progress only option via linecount
#todo: wget's quiet
#todo: wireshark/dumpcap priv

read -r linecount _ < <(wc -l "$0")
install=(pacman -S --color=always --)
installThis=".\install.txt"
while getopts "iv" opt; do
  case $opt in
	i)
      i="install";;
    v)
      v="verbose";;
    \?)
      echo error;;
  esac
done

# -> after installation
# d2017-02-06
for i in {"https://raw.githubusercontent.com/Argon-/mpv-stats/master/stats.lua","https://raw.githubusercontent.com/mpv-player/mpv/master/TOOLS/lua/autocrop.lua","https://raw.githubusercontent.com/donmaiq/Mpv-Playlistmanager/master/playlistmanager.lua"}; do
	file="$HOME/.config/mpv/scripts/${i##*/}"
	[ ! -f "$file" ] && { \
		{ wget -O "$file" "$i" || cp -a "/Data/Backup/Software/extension-script/mpv/${i##*/}" "$file"; } && \
		printf "%s" "[$LINENO] MPV: added \"${i##*/}\"" || \
		printf "%s" "[$LINENO] MPV: failed adding \"${i##*/}\"" >&2; }
done
# d2017-03-05
if [ ! -e /usr/local/bin/meld ]; then
	echo -en '#!/bin/bash\nGTK_THEME=Adwaita /usr/bin/meld $@'
	chmod +x /usr/local/bin/meld
else
	echo "[$LINENO] meld: failed creating start script in /usr/local/bin/"
fi
install(){
	[ $# -eq 1 ] \
	&& "${install[@]}" || { printf "%s" "Error: Package: \"$@\" couldn't be installed!"; return 1; } \

	&& which "$1" || { printf "%s" "Warning: Package: \"$@\" didn't put an executable in \$PATH."; }
}

#https://wiki.wireshark.org/CaptureSetup/CapturePrivileges
#$ sudo usermod -aG wireshark celmor
#$ sudo setcap 'CAP_NET_RAW+eip CAP_NET_ADMIN+eip' /usr/sbin/dumpcap
#$ sudo chmod u+s /usr/bin/dumpcap

# packages
# todo: if install option set:
if [ "$i" ]; then
	if [ $EUID -ne 0 ]; then
		printf "%s\n" "Error: Must be run as root with install option"; exitcode=1
	else
		[ "$v" ] && printf "%s\n" "Verbose: Installing Applications using ${install[0]}."
		pacman -Sy \
		while  "$installThis" read -r i; install "$i"
	fi
fi

#package: steam
# https://wiki.archlinux.org/index.php/Flatpak#Add_a_repository
# http://www.omgubuntu.co.uk/2017/06/steam-now-available-flatpak
sudo pacman -S flatpak xdg-desktop-portal \
&& flatpak remote-delete flathub \
&& flatpak remote-add flathub https://flathub.org/repo/flathub.flatpakrepo \
&& flatpak install flathub com.valvesoftware.Steam \
&& sudo pacman -Rns steam-manjaro \
|| printf "%s" "Error: Package: \"Steam\" couldn't be installed!"
ln -s /usr/bin/true /usr/local/bin/resolvconf

return $exitcode
