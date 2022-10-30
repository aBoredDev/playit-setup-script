#!/bin/bash
# Playit.gg setup script for Linux (x86 and arm)
# Copyright(c) 2021 aBoredDev

# This script downloads the latest playit.gg binary and installs it up as a
# service so that it will run in the background and start automatically
# whenever the computer is started

# Check the device's architechture
arch=$( uname -m )
# Check the device's OS, because we can use apt for debian/ubuntu
distro=$( grep --colour=never -Po '(?<=^ID-LIKE=).*$' /etc/os-release )

name=""
playit_path=""

case $1 in
    --service-only)
        printf "\n\033[04=====m\033[01mChecking for existing playit.gg binaries\033[00m\033[04=====\033[00m\n"
        # Look for any files in the current directory which start with 'playit', and strip the ./ off the front
        name=$( find . -regex .*/playit.* )
        name=$( basename -a $name )
        
        # Allow the user to select a binary or specifiy a different one
        printf "Possible existing binaries found.  Please select from the following list, or choose Other to specify a diiferent binary:\n"
        select FILE in $name Other 
        do
            case $FILE in
                Other)
                    printf "Enter the name of your playit binary\n"
                    read name
                    printf "Using $name\n"
                    playit_path=$( pwd )
                ;;
                *)
                    printf "Using $FILE\n"
                    name=$FILE
                    playit_path=$( pwd )
                ;;
            esac
            break   
        done
    ;;
    *)
        # Check for an existing playit binary in the current directory, and delete it if one exists
        # We do this because wget doesn't overwrite files when downloading, instead it appends a number to the filename,
        # which might cause the verion to not actually be the latest version.
        # TODO: Update this
        printf "\n\033[04=====m\033[01mChecking for existing playit.gg binaries\033[00m\033[04=====\033[00m\n"
        case $arch in
            x86_64)
                if [ -e playit-linux_64-latest ]
                then
                    printf "Found existing playit binary, deleting...\n"
                    rm playit-linux_64-latest
                else
                    printf "No existing binaries found\n"
                fi
            ;;
            armv7l)
                if [ -e playit-armv7-latest ]
                then
                    printf "Found existing playit binary, deleting...\n"
                    rm playit-armv7-latest
                else
                    printf "No existing binaries found\n"
                fi
                if [ -e playit-linux_64-latest ]
                then
                    printf "You appear to have downloaded the x86 binary on an arm machine.
It will not work!  So we're just going to delete it for you.\n"
                    rm playit-linux_64-latest
                fi
            ;;
        esac

        # Check what distro we're on
        case $distro in
            debian) # Get the package if we're on a debian based distro
                # For Debian & Ubuntu based systems
                curl -SsL https://playit-cloud.github.io/ppa/key.gpg | sudo apt-key add -
                sudo curl -SsL -o /etc/apt/sources.list.d/playit-cloud.list https://playit-cloud.github.io/ppa/playit-cloud.list
                sudo apt update
                sudo apt install playit
                playit_path="/opt/playit"
                name="playit"
            ;;
            *) # Download the latest binary for the correct architecture if not on debian/ubuntu
                printf "\n\033[04========m\033[01mDownloading latest binary\033[00m\033[04========\033[00m\n"
                case $arch in
                    x86_64)
                        wget https://github.com/playit-cloud/playit-agent/releases/download/v0.9.3/playit-0.9.3
                        chmod +x ./playit-0.9.3
                        name='playit-0.9.3'
                        playit_path=$( pwd )
                    ;;
                    armv7l)
                        wget https://github.com/playit-cloud/playit-agent/releases/download/v0.9.3/playit-0.9.3-armv7
                        chmod +x ./playit-0.9.3-armv7
                        name='playit-0.9.3-armv7'
                        playit_path=$( pwd )
                    ;;
                esac
            ;;
        esac
    ;;
esac

# Check to see if the user has specifed that they don't want it installed as a service
case $1 in
    --no-service)
        printf "\n\n\033[04========m\033[01mStarting playit\033[00m\033[04========\033[00m\n\n"
        printf "Opening tunnel host
To exit the tunnel host, use \033[01mCtrl+c\033[00m.  If you need to copy the claim URL,
use \033[01mCtrl+Insert\033[00m (or \033[01mCtrl+fn+Insert\033[00m, if your insert key is
shared with your Delete key)
To start the tunnel host again at any time, run './$name'\n"

        printf "\nOnce you have read the above, type 'yes' to start the tunnel host\n"
        read confirm
        until [ $confirm = 'yes' ]
        do
            printf "Starting tunnel host
To exit the tunnel host, use \033[01mCtrl+c\033[00m.  If you need to copy the claim URL,
use \033[01mCtrl+Insert\033[00m (or \033[01mCtrl+fn+Insert\033[00m, if your insert key is
shared with your Delete key)\n
To start the tunnel host again at any time, run './$name'\n"

            printf "\nOnce you have read the above, type 'yes' to start the tunnel host\n"
            read confirm
        done

        ./$name
    ;;
    *)
        printf "\n\n\033[04========m\033[01mInstalling playit as a service\033[00m\033[04========\033[00m\n\n"
        # Install screen so that the user can view the output of the playit host
        # we use screen because tmux has caused issues with playit for me in the past
        printf "\n\033[04=====m\033[01mInstalling screen\033[00m\033[04=====\033[00m\n"
        sudo apt install screen

        printf "\nInstalling service file\n"
        # I know this looks messy, but if I don't do it this way the service file ends up indented
        printf "[Unit]
Description=playit.gg tunnel host
After=network-online.target

[Service]
Type=forking
Restart=no
User=$USER
WorkingDirectory=$playit_path
ExecStart=/usr/bin/screen -d -m -S playit.gg $playit_path/$name
ExecStop=/usr/bin/screen -S playit.gg -X quit

[Install]
WantedBy=multi-user.target\n" > ./playit.service

        sudo mv -f ./playit.service /etc/systemd/system/playit.service

        sudo chown root:root /etc/systemd/system/playit.service

        # Reload systemctl, then enable and start the service
        printf "\n\033[04=====m\033[01mReloading systemctl and enabling service\033[00m\033[04=====\033[00m\n"
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
    ;;
esac
