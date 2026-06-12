# # Fitosol
# random_font=$(ls /usr/share/figlet/*.flf | shuf -n1)
# figlet -t -r -s -f $random_font "fitosol" | lolcat -h 0.1 -r -b -v 0.25



if [[ -e $HOME/.motd ]]; then cat $HOME/.motd | lolcat -h 0.1 -r -b -v 0.25; fi
