#!/usr/bin/python3
import os
import time

f = open(os.path.expanduser('~')+"/.config/autostart/vpnautoconnect.desktop", "w")
f.write("[Desktop Entry]\nName=VPN autoconnect\nGenericName=Automatically connect to the VPN at startup and reconnect every 5 seconds\nComment=Automatically connect to the VPN at startup and reconnect every 5 seconds\nExec="+os.path.dirname(os.path.abspath(__file__))+"/VPNautoconnect.sh\nIcon="+os.path.dirname(os.path.abspath(__file__))+"/icons/vpn_autoconnect.png\nNoDisplay=false\nHidden=false\nTerminal=false\nType=Application\nX-GNOME-Autostart-enabled=true\nX-GNOME-Autostart-Delay=3")
f.close()
print("An autostart entry has been created, reboot the computer and vpnautoconnect will start automatically ;-)\n")
time.sleep(3)


