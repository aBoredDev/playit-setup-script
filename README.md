# playit-setup-script
A script to set up the playit.gg tunnel host (https://playit.gg/) and install it as a service on Linux.

## Usage
### Ubuntu, Debian
Do not run the script as root, it will elevate permissions when it needs to
```bash
$ bash <(curl -sS https://raw.githubusercontent.com/aBoredDev/playit-setup-script/main/playit-setup.sh)
```
And that's it

## Viewing the tunnel host
To view the tunnel host once it is running, use the following command:
```bash
$ screen -r playit
```
To exit the tunnel host and return to the terminal session, use __Ctrl+A D__.  This will detach you from the screen session and return you to your previous terminal session.  If you use Ctrl+C, it will terminate the tunnel host.  If this happens, simply restart the tunnel host using `systemctl restart`.
