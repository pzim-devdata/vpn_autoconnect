# VPNautoconnect.sh for Linux : Automatically connect to the VPN at startup and reconnect if connection is lost.

[![GitHub license](https://img.shields.io/github/license/pzim-devdata/vpn_autoconnect?style=plastic)](https://github.com/pzim-devdata/vpn_autoconnect/blob/master/LICENSE)   [![GitHub issues](https://img.shields.io/github/issues/pzim-devdata/vpn_autoconnect?style=plastic)](https://github.com/pzim-devdata/vpn_autoconnect/issues)    ![GitHub repo size](https://img.shields.io/github/repo-size/pzim-devdata/vpn_autoconnect?style=plastic)    ![GitHub All Releases](https://img.shields.io/github/downloads/pzim-devdata/vpn_autoconnect/total?style=plastic)    ![GitHub release (latest by date)](https://img.shields.io/github/v/release/pzim-devdata/vpn_autoconnect?style=plastic)    [![GitHub commits](https://img.shields.io/github/commits-since/pzim-devdata/vpn_autoconnect/v1.0.0.svg?style=plastic)](https://GitHub.com/pzim-devata/vpn_autoconnect/commit/)

[Download :inbox_tray:](https://github.com/pzim-devdata/vpn_autoconnect/releases/download/v1.0.0/VPNautoconnect.zip)

## Description :

A script to automatically connect to the VPN at startup (if you lauch this script at startup) and reconnect  every 5 seconds if connection is lost.
This updated version will also reconnect the wifi and ethernet card if used if connection is lost with a ping check

![Presentation__gif](https://github.com/pzim-devdata/Tools-for-Linux/blob/master/VPNautoconnect/GifVPN)


## How to install :



1. Download the file "VPNautoconnect.sh" in a folder called `VPN` in your `Home` directory :

```
cd ~
git clone https://github.com/pzim-devdata/vpn_autoconnect.git VPN
```

2. Then open your Terminal in the folder where "VPNautoconnect.sh" is located and type :

```
cd ~
chmod +x VPN/VPNautoconnect.sh
``` 

3. Connect to the VPN at startup :

If you want to connect to the VPN automatically at startup :

  - Execute `Create_autostart_entry.py`

or

   - Enter the address of the script "VPNautoconnect.sh" (which is `VPN/VPNautoconnect.sh` in this exemple)  in your favorite startup tool : like "gnome-tweak-tool" for Gnome or other startup applications for other desktop environment : https://winaero.com/blog/manage-startup-apps-linux-mint/

Reboot an enjoy ! :blush:


-----------------------------------------


In bonus, you can [download 3 little scripts for Nemo or Nautilus](https://github.com/pzim-devdata/Tools-for-Linux/raw/master/VPNautoconnect/Scripts.zip) in order to connect or disconnect quickly and easily :blush:
Install them in this directory :

- For Caja (Mate) in : ~/.config/caja/scripts.
- For Nautilus (Gnome/Unity) in : ~/.local/share/nautilus/scripts
- For Némo (Cinnamon) in : ~/.local/share/nemo/scripts/


![](https://github.com/pzim-devdata/Tools-for-Linux/blob/master/VPNautoconnect/Image3.png)


--------------------------------------------

## - [Licence](https://github.com/pzim-devdata/DATA-developer/raw/master/LICENSE)
MIT License
Copyright (c) 2019 pzim-devdata

--------------------------------------------

## - [Contact :email:](mailto:contact@pzim.fr?subject=Contact%20from%20Github)
Created by [@pzim](https://www.pzim.fr/) - feel free to contact me!






   
