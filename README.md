# Cloudflare DDNS in shell
Simple shell script that provides the ability to update your cloudflare A records to your machine's IP.

This script is [forked from this gist](https://gist.github.com/radiantly/3dbff163624ca3dd32ee8ecf225a7b02), and the gist is a fork from another projects. I needed a solution for updating multiple A records in cloudflare, instead of one, so i changed myself and made another small changes.

# Dependencies 
This script needs the *jq* installed in your machine, you can install in ubuntu or arch using:
```
sudo apt install jq

sudo pacman -S jq
```
# Configuration
Make a copy from ddns.sh and follow the script comments, you'll need from cloudflare: 
* Your account email
* An api token, you can generate [here](https://dash.cloudflare.com/profile/api-tokens)
* The zoneID, can be found in the "Overview" tab of your domain