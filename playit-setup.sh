#!/bin/bash
# Playit.gg setup script for Linux (x86 ONLY - arm uses a different binary)
# Copyright(c) 2021 aBoredDev

# This script downloads the latest playit.gg binary and installs it up as a
# service so that it will run in the background and start automatically
# whenever the computer is started

# Download the latest playit.gg binary for linux and make it executable
wget https://playit.gg/downloads/playit-linux_64-latest
chmod +x ./playit-linux_64-latest

# Install screen so that the user can view the output of the playit host
# we use screen because tmux has caused issues with playit for me in the past
printf "\nInstalling screen\n"
sudo apt install screen

playit_path=$( pwd )

printf "\nInstalling service file\n"
printf "[Unit]
Description=playit.gg tunnel host
After=network-online.target

[Service]
Type=forking
Restart=no
User=$USER
WorkingDirectory=$playit_path
ExecStart=/usr/bin/screen -d -m -S playit.gg $playit_path/playit-linux_64-latest
ExecStop=/usr/bin/screen -S playit.gg -X quit

[Install]
WantedBy=multi-user.target" >> ./playit.service\n"

sudo mv ./playit.service /etc/systemd/system/playit.service

sudo chown root:root /etc/systemd/system/playit.service

# Reload systemctl, then enable and start the service
printf "\nReloading systemctl and enabling service\n"
sudo systemctl daemon-reload
sudo systemctl enable playit
sudo systemctl start playit

# Open screen to show the user the tunnel host, and make sure they know how to exit
printf "\n\n\nOpening tunnel host now.
To exit the tunnel host, do \033[01m\033[04mNOT\033[00m hit Ctrl+c.  Doing so will terminate
the tunnel host.  To exit to the terminal, use \033[01mCtrl+a d\033[00m\n"

printf "\nOnce you have read the above, type 'yes' to view the tunnel host\n"
read confirm
until [ $confirm = 'yes' ]
do
    printf '\nOpening tunnel host now.\n'
    printf 'To exit the tunnel host, do \033[01m\033[04mNOT\033[00m hit Ctrl+c.
    Doing so will terminate the tunnel host.  To exit to the terminal, use
    \033[01mCtrl+a d\033[00m\n'

    printf "Once you have read the above, type 'yes' to view the tunnel host"
    read confirm
done

screen -r playit.gg

printf "\nTo view the tunnel host at any time, use 'screen -r playit.gg', and
\033[01mCtrl+a d\033[00m to return to the terminal\n"
