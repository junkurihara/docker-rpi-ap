#!/bin/bash
# https://qiita.com/mt08/items/b6356b8e967f5c121bf1

: ${AP_ENABLE_HOSTAPD:=1}
: ${AP_INTERFACE_OUTGOING:=eth0}
	
: ${AP_SUBNET:=192.168.42.0}
: ${AP_DNS:=192.168.11.8}
: ${AP_DOMAIN:="local"}
: ${AP_RANGE_LO:=100}
: ${AP_RANGE_HI:=200}

: ${AP_ADDR:=192.168.42.1}

: ${AP_INTERFACE:=wlan0}
: ${AP_DRIVER:=nl80211}
#: ${AP_DRIVER:=rtl871xdrv}
: ${AP_SSID:=Pi4-AP}
: ${AP_HW_MODE:=a}
: ${AP_CHANNEL:=36}
: ${AP_IEEE80211N:=1}
: ${AP_WMM_ENABLED:=1}
#: ${AP_HT_CAPAB:=[HT40][SHORT-GI-20][DSSS_CCK-40]}
: ${AP_HT_CAPAB:=[MAX-AMSDU-3839][HT40-][HT40+][SHORT-GI-20][SHORT-GI-40][DSSS_CCK-40]}
: ${AP_MACADDR_ACL:=0}
: ${AP_AUTH_ALGS:=1}
: ${AP_IGNORE_BROADCAST_SSID:=0}
: ${AP_WPA_PASSPHRASE:=raspberry}
: ${AP_WPA:=2}
: ${AP_WPA_KEY_MGMT:=WPA-PSK}
: ${AP_RSN_PAIRWISE:=CCMP}
: ${AP_IEEE80211AC:=1} # 802.11ac


# IP Address 
ip link set ${AP_INTERFACE} down
ip link set ${AP_INTERFACE} up
ip addr flush dev ${AP_INTERFACE}
ip addr add ${AP_ADDR}/24 dev ${AP_INTERFACE}

# dhcpd.conf
cat <<EOF > "/etc/dhcp/dhcpd.conf" 
subnet ${AP_SUBNET} netmask 255.255.255.0 {
    range ${AP_SUBNET::-1}${AP_RANGE_LO} ${AP_SUBNET::-1}${AP_RANGE_HI};
    option broadcast-address  ${AP_SUBNET::-1}255;
    option routers ${AP_ADDR};
    default-lease-time 600;
    max-lease-time 7200;
    option domain-name "${AP_DOMAIN}";
    option domain-name-servers ${AP_DNS};
}
EOF

# 
cat <<EOF > "/etc/hostapd/hostapd.conf"
interface=${AP_INTERFACE}
driver=${AP_DRIVER=nl80211}
ssid=${AP_SSID}
hw_mode=${AP_HW_MODE}
channel=${AP_CHANNEL}
ieee80211n=${AP_IEEE80211N}
wmm_enabled=${AP_WMM_ENABLED}
ht_capab=${AP_HT_CAPAB}
macaddr_acl=${AP_MACADDR_ACL}
auth_algs=${AP_AUTH_ALGS}
ignore_broadcast_ssid=${AP_IGNORE_BROADCAST_SSID}
wpa=${AP_WPA}
wpa_key_mgmt=${AP_WPA_KEY_MGMT}
wpa_passphrase=${AP_WPA_PASSPHRASE}
rsn_pairwise=${AP_RSN_PAIRWISE}
hw_mode=${AP_HW_MODE}
ieee80211ac=${AP_IEEE80211AC}
logger_syslog_level=4
ieee80211d=1
vht_capab=[MAX-AMSDU-3839][SHORT-GI-80]
vht_oper_chwidth=0 # 1: 80MHz
#vht_oper_centr_freq_seg0_idx=42  #帯域80MHzの場合に指定する。channel+6
EOF


echo 1 > /proc/sys/net/ipv4/ip_forward
iptables -t nat -A POSTROUTING -o ${AP_INTERFACE_OUTGOING} -j MASQUERADE
iptables -A FORWARD -i ${AP_INTERFACE_OUTGOING} -o ${AP_INTERFACE} -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -A FORWARD -i ${AP_INTERFACE} -o ${AP_INTERFACE_OUTGOING} -j ACCEPT

mkdir -p /var/lib/dhcp/ && touch  /var/lib/dhcp/dhcpd.leases

[ ${AP_ENABLE_HOSTAPD} == 1 ] && hostapd -B /etc/hostapd/hostapd.conf

dhcpd -d ${AP_INTERFACE}

