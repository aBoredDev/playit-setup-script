# playit-setup-script
A script to set up the [playit.gg](https://playit.gg/) tunnel host and install it as a service on Linux.  But why would you even want that?
- If playit is running as a systemd service, you don't need to worry about restarting it if your machine ever shuts down,  It will start automatically whenever your machine starts up.
- It's much quicker to restart it when it's a service, because all you need is one command, rather than two or three.
- Single command installers are nice, particularly when you're dealing with a service.

## Usage
### Debin/Ubuntu, Raspberry Pi (Raspbian)
The script doesn't need to be run as root, it will elevate permissions when it needs to.
```bash
$ bash <(curl -sS https://raw.githubusercontent.com/aBoredDev/playit-setup-script/main/playit-setup.sh)
```
And that's it!

## Viewing the tunnel host
To view the tunnel host once it is running, use the following command:
```bash
$ screen -r playit
```
To exit the tunnel host and return to the terminal session, use __Ctrl+A D__.  This will detach you from the screen session and return you to your previous terminal session.  If you use Ctrl+C, it will terminate the tunnel host.  If this happens, simply restart the tunnel host using `systemctl start playit`.

## Managing the service
To manage any service on Linux under systemd, you use the `systemctl` command.
- To stop the playit service, run `sudo systemctl stop playit`.
- To start the playit service, run `sudo systemctl start playit`.
- To restart the playit service, run `sudo systemctl restart playit`.
- To view the status of the playit service, run `systemctl status playit`.

For more information on the systemctl command, see [this article](https://www.digitalocean.com/community/tutorials/how-to-use-systemctl-to-manage-systemd-services-and-units) on DigitalOcean, or the [man page](https://www.man7.org/linux/man-pages/man1/systemctl.1.html).

## Disclaimer
I am not associated with playit.gg in any way beyond being a user.  This script is un-offcial.

---

Credit for the original idea goes to \_-\_\_—\_\_-#5324 on Discord.  I saw him mention making an auto-update/installer script, and since I didn't see any mention of one anywhere, I decided to take a crack at it myself.