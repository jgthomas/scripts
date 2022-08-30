DEVICE="wlan0"


networks() {
        iwctl station $DEVICE scan && iwctl station $DEVICE get-networks
}


connect() {
        ssid="$1"
        passphrase="$2"

        if [[ ! -z $passphrase ]]; then
                iwctl --passphrase=$passphrase station $DEVICE connect $ssid
        else
                iwctl station $DEVICE connect $ssid
        fi
}


known() {
        iwctl known-networks list
}


usage() {
        printf "\nUsage: $program command [network] [password]\n\n"
        printf '%-10s%-10s%-15s%-20s%-10s \n\n' "help" "" "" "" "display this message"
}


operation="$1"
network="$2"
password="$3"


[[ -z $operation ]] && { usage; exit 1; }


case $operation in
        "networks")
                networks
                exit 0
                ;;
        "connect")
                connect $network $password
                exit 0
                ;;
        "known")
                known
                exit 0
                ;;
        "help")
                usage
                exit 0
                ;;
esac
