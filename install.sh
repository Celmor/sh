log=${HOME}/new/log/pacman.$(date +d%F | tr -d '\n')."$1".color.log
echo "> $log"
echo $ pacman -Si $1 | tee -a $log
pacman -Si --color=always $1 | tee -a $log
echo $ sudo pacman -S $@ | tee -a $log
sudo pacman -S --color=always $@ 2>&1 | tee -a $log
