#!/bin/bash
#api nordvpn : https://sleeplessbeastie.eu/2019/02/18/how-to-use-public-nordvpn-api/
#@pzim-devdata

#This script is for automaticaly reconnecting to a specified VPN when it's disconnected or when connection to internet is lost thanks to a ping check it will reconnect all connections
#Logs are stored in ~/Programmes/VPN/Autoconnect/.Vpnautoconnect.log

#NordVPN lowest load : curl --silent "https://api.nordvpn.com/v1/servers/recommendations?&filters%5C%5Bservers_technologies%5C%5D%5C%5Bidentifier%5C%5D=openvpn_udp&limit=2" | jq --raw-output --slurp ' .[] | sort_by(.load) | limit(2;.[]) | [.hostname, .load] | "\(.[0]): \(.[1])"' | tail -n 1 | cut -d ':' -f 1

#Specify a folder for logs :
LOG_PLACE="$(dirname "$BASH_SOURCE")/.Vpnautoconnect.log"

#wait for the connection to be etablished before starting :
connectivity=$(nmcli networking connectivity)
i=1
while [ "$connectivity" != "full" ] && [ $i -lt 11 ]; do 
    echo "Aucune connexion internet. Essai $i/10";
    sleep 4;
    connectivity=$(nmcli networking connectivity)
    i=$((i+1))
done


#I. 
#It will automaticaly select the active VPN or if not active it will select a first one in alphabetic order :
if [ -n "$(nmcli -t -f NAME,TYPE c s -a | grep vpn | cut -d ':' -f1 | head -n1)" ]; then
    DEFAULT_VPN_NAME="$(nmcli -t -f NAME,TYPE c s -a | grep vpn | cut -d ':' -f1 | head -n1)"
else
    DEFAULT_VPN_NAME="$(nmcli -t -f NAME,TYPE,DEVICE c s | grep vpn | grep ':$' | cut -d ':' -f 1 | sort | head -n1)"
fi;

#Add a second VPN in case of first VPN failed :
#It will automaticaly select a non active VPN in unalphabetic order :
#VPN_NAME2= "$(cat ~/Programmes/VPN/Autoconnect/.10_meilleures_connexions_vpn.log | head -n1)"
VPN_NAME2="$(nmcli -t -f NAME,TYPE,DEVICE c s | grep vpn | grep ':$' | cut -d ':' -f 1 | sort -r | head -n1)"

#II.
#It will automaticaly select the ETHERNET active connection(s) or if non active the non active ETHERNET connection sort by priority
if [ -n "$(nmcli -t -f NAME,TYPE c s -a | grep "ethernet" | cut -d ':' -f1)" ]; then
    ETHERNET_CARD_NAMES="$(nmcli -t -f NAME,TYPE c s -a | grep "ethernet" | cut -d ':' -f1)"
else
    ETHERNET_CARD_NAMES="$(nmcli -t -f AUTOCONNECT-PRIORITY,NAME,TYPE,AUTOCONNECT,DEVICE c s | sort -n -r | grep -E "ethernet" | grep ':$'  | cut -d ':' -f2)"
fi;

#Add a wifi card name :
#It will automaticaly select the WIFI active connection(s) or if non active the non active WIFI connection sort by priority

if [ -n "$(nmcli -t -f NAME,TYPE c s -a | grep "wireless")" ]; then
    nmcli radio wifi on
    WIFI_CARD_NAMES="$(nmcli -t -f NAME,TYPE c s -a | grep "wireless" | cut -d ':' -f1)"
else
    nmcli radio wifi off
    WIFI_CARD_NAMES="$(nmcli -t -f AUTOCONNECT-PRIORITY,NAME,TYPE,AUTOCONNECT,DEVICE c s | sort -n -r | grep -E "wireless" | grep ':$' | cut -d ':' -f2)"
fi;


IFS=$'\n' read -ra ETHERNET_CON_NAMES <<< "$ETHERNET_CARD_NAMES"
IFS=$'\n' read -ra WIFI_CON_NAMES <<< "$WIFI_CARD_NAMES"

RECONNECT_ETHERNET='for con_name in "${ETHERNET_CON_NAMES[@]}"; do     nmcli con down "$con_name"; sleep 3; nmcli con up "$con_name"; done'
RECONNECT_WIFI='nmcli radio wifi off; nmcli radio wifi on; sleep 3; for con_name in "${WIFI_CON_NAMES[@]}"; do     nmcli --wait 8 con up "$con_name" || true; done)'
#eval $RECONNECT_ETHERNET

#III.
#Automatically reconnect

while [ "true" ]
do
    if [[ $(nmcli con show --active | grep "vpn") != *vpn* ]];then
        echo "" >> $LOG_PLACE
        echo "The $(date +%x) at $(date +%X), you have been disconnected from VPN, trying to reconnect..." >> $LOG_PLACE
        #notify-send "VPN déconnecté. Reconnexion en cours...  à $(date +%X)" --icon=network-vpn-symbolic
        (sleep 1s && (nmcli con down "$(nmcli -t -f NAME,TYPE c s -a | grep vpn | cut -d ':' -f1 | head -n1)"; nmcli con down "$DEFAULT_VPN_NAME"; nmcli con down "$VPN_NAME2"; nmcli --wait 8 con up "$DEFAULT_VPN_NAME" )   )
        if [[ $(nmcli con show --active | grep "vpn") == *vpn* ]];then
            echo "The $(date +%x) at $(date +%X), the VPN has been reconnected..." >> $LOG_PLACE
            #notify-send "VPN reconnecté à $(date +%X)" --icon=network-vpn-symbolic
        fi;
    else
        echo "Already connected to a VPN!"
    fi;

    connectivity=$(nmcli networking connectivity check)
    if [[ $connectivity == "full" ]]; then
#    PINGCON=$(ping 1.1.1.1 -c5 -q -i 1 -W 1 | grep "% packet");#If ping is under 60% it will reconnect 
#    if [[ $(echo $PINGCON | cut -d " " -f4) > 3 ]];then
        echo "PINGCHECK OK!"
    else
        echo "" >> $LOG_PLACE
        echo "The $(date +%x) at $(date +%X), first ping check failed, trying to reconnect with another VPN…" >> $LOG_PLACE
        #notify-send "Perte de la connexion. Reconnexion d'un autre VPN en cours... à $(date %X)" --icon=network-vpn-symbolic
        sleep 1; nmcli con down "$(nmcli -t -f NAME,TYPE c s -a | grep vpn | cut -d ':' -f1 | head -n1)"; nmcli con down "$DEFAULT_VPN_NAME"; nmcli con down "$VPN_NAME2"; nmcli --wait 8 con up "$VPN_NAME2";
        connectivity=$(nmcli networking connectivity check)
        if [[ $connectivity == "full" ]]; then
            echo "The $(date +%x) at $(date +%X), the VPN has been reconnected" >> $LOG_PLACE
            #notify-send "Reconnexion du VPN réussie à $(date +%X)" --icon=network-vpn-symbolic
        else
            echo "The $(date +%x) at $(date +%X), the second ping check failed, trying to reconnect all connections..." >> $LOG_PLACE
#            #notify-send "Échec de la reconnexion du VPN. Reconnexion totale en cours avec les paramètres par défaut... à $(date +%X)" --icon=network-vpn-symbolic
            sleep 1; nmcli con down "$(nmcli -t -f NAME,TYPE c s -a | grep vpn | cut -d ':' -f1 | head -n1)"; nmcli con down "$DEFAULT_VPN_NAME"; nmcli con down "$VPN_NAME2"; nmcli radio wifi off;
            connectivity=$(nmcli networking connectivity check)
            i=1
            while [ "$connectivity" != "full" ] && [ $i -lt 11 ]; do 
                echo "Aucune connexion internet. Essai $i/10";
                sleep 4;
                eval $RECONNECT_ETHERNET; 
                connectivity=$(nmcli networking connectivity check);
                if [[ $connectivity != "full" ]]; then
                    eval $RECONNECT_WIFI; 
                    connectivity=$(nmcli networking connectivity check)
                fi;
                i=$((i+1))
            done;
            nmcli --wait 8 con up "$DEFAULT_VPN_NAME";
            if [[ $(nmcli con show --active | grep "vpn") != *vpn* ]];then
                sleep 1; nmcli con down "$(nmcli -t -f NAME,TYPE c s -a | grep vpn | cut -d ':' -f1 | head -n1)"; nmcli con down "$DEFAULT_VPN_NAME"; nmcli con down "$VPN_NAME2"; nmcli --wait 8 con up "$VPN_NAME2";
            fi;
            connectivity=$(nmcli networking connectivity check)
            if [[ $connectivity == "full" ]]; then
                echo "The $(date +%x) at $(date +%X), reconnected with sucess !" >> $LOG_PLACE
#                notify-send "Reconnexion totale réussie... à $(date +%X)" --icon=network-vpn-symbolic
            fi;
        fi;
        
#        PINGCON2=$(ping 1.1.1.1 -c5 -q -i 1 -W 1 | grep " 0%");
#        if [[ $PINGCON2 == *0%*packet*loss* ]];then
#        if [[ $PINGCON2 != *0%*packet*loss* ]];then
#            echo "The $(date +%x) at $(date +%X), the second ping check failed, trying to reconnect all connections as default config…" >> $LOG_PLACE
#            #notify-send "Echec de la reconnexion du VPN. Reconnexion totale en cours avec les paramétres par défaut... à $(date +%X)" --icon=network-vpn-symbolic
#            sleep 1; nmcli con down "$(nmcli -t -f NAME,TYPE c s -a | grep vpn | cut -d ':' -f1 | head -n1)"; nmcli radio wifi off; nmcli con down "$DEFAULT_VPN_NAME"; nmcli con down "$VPN_NAME2";nmcli dev disconnect $SECOND_NETWORK_CARD_NAME; nmcli con down "$SECOND_NETWORK_CARD_NAME"; nmcli dev disconnect $NETWORK_CARD_NAME; nmcli con down "$NETWORK_CARD_NAME"; 
#            #nmcli radio wifi on; 
#            nmcli dev connect $NETWORK_CARD_NAME; nmcli con up "$NETWORK_CARD_NAME"; nmcli dev connect $SECOND_NETWORK_CARD_NAME; nmcli con up "$SECOND_NETWORK_CARD_NAME"; sleep 4s; nmcli --wait 8 con up "$DEFAULT_VPN_NAME" )   )
#            PINGCON3=$(ping 1.1.1.1 -c5 -q -i 1 -W 1 | grep " 0%");
#            if [[ $PINGCON3 == *0%*packet*loss* ]];then
#                echo "The $(date +%x) at $(date +%X), reconnected with sucess !" >> $LOG_PLACE
#                #notify-send "Reconnexion totale réussie... à $(date +%X)" --icon=network-vpn-symbolic
#            fi;
#        fi;
    fi;
    sleep 5;
done
