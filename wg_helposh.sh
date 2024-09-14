#!/bin/bush
 set -o errexit
 #set -o nounset

welcome ()
{
echo "*************************************"
echo "*                                   *"
echo "*              Hello!               *"
echo "*       Installer WireGuard         *"
echo "*          versio 0.1.0             *"
echo "*                                   *"
echo "*************************************"
}

welcome

sleep 2

#LANGUAGE
if [ -z $language ]; then
 echo "Select language/Выбор языка"
 echo "ENGLISH - 1"
 echo "РУССКИЙ - 2"
 echo "enter 1 or 2):"
 read TEXTL
else
 TEXTL=$language
fi
parm1=1
if [[ $TEXTL -eq $parm1 ]]; then
 echo "=====> SELECTED ENGLISH"
else
 echo "=====> ВЫБРАН РУССКИЙ ЯЗЫК"
fi

sleep 1

#ROOT TEST
roottest_en ()
{
if [ $UID -ne 0 ]; then
 echo "ERROR: Not you are a root user. Please run as root!"
 echo exiting...
 sleep 1
 exit 1
else
 echo "=====> YOU ARE IN THE ROOT SESSIONE"
 echo OK
fi
}

roottest_ru ()
{
if [ $UID -ne 0 ]; then
 echo "ERROR: Вы не в сессии пользователя ROOT! Для корректной установки WireGuard,"
 echo "перейдите в сессию ROOT и запустите установку заново!"
 echo "Выход..."
 sleep 1
 exit 1
else
 echo "=====> Вы в сессии ROOT."
 echo OK
fi
}

if [[ $TEXTL -eq $parm1 ]]; then
    roottest_en
else
    roottest_ru
fi
sleep 1

#WG INTERFACE

if [ -z $1 ]; then
    if [[ $TEXTL -eq $parm1 ]]; then
        echo "Creating a network interface."
        echo "The name will consist of the index "wg" + number."
        echo "The interface name should not be the same as other already deployed networks."
        echo "Enter only the interface number in the range 0...100:"
    else
        echo "Создание интерфейса сети."
        echo "Имя будет соcтоять из индекса "wg" + номер."
        echo "Имя интерфейса не должно совпадать с именами, других уже развернутых сетей."
        echo "Введи только номер интерфейса в диапазоне 0...100:"
    fi
    read TEXT1
else
    TEXT1=$1
fi

iifname=$(echo "wg")$TEXT1
echo $(echo "Created interfase wg")$TEXT1
echo OK
sleep 1

#WG CLIENTS

if [ -z $2 ]; then
    if [[ $TEXTL -eq $parm1 ]]; then
        echo "Enter the number of clients you need"
        echo "(minimum 2; maximum 252):"
    else
        echo "Введите необходимое количество клиентов"
        echo "(минимум 2; максимум 252):"
    fi
    read TEXT2
else
    TEXT2=$2
fi

all_clients=$TEXT2
echo $(echo "Clients will be created: ")$TEXT2
echo OK
sleep 1

#WG PORT

if [ -z $3 ]; then
    if [[ $TEXTL -eq $parm1 ]]; then
        echo "Enter the port number, standard WireGuard port 51820."
        echo "(enter 51820 or another free port):"
    else
        echo "Введите номер порта, стандартный порт WireGuard 51820."
        echo "(введите 51820 или другой нейспользуемый порт):"
    fi
    read TEXT3
else
    TEXT3=$3
fi

PORT=$TEXT3
echo $(echo "Port defined ")$TEXT3
echo OK
sleep 1

#IP_CONFIGURETION

if [ -z $4 ]; then
    if [[ $TEXTL -eq $parm1 ]]; then
        echo "Definition of a private VPN network."
        echo "IP addresses are formed in the subnet 172.21.0.0 -172.21.255.255."
        echo "Enter the subnet number 172.21.XXX.0 (XXX = 1 - 255):"
    else
        echo "Определение частной впн сети."
        echo "IP адреса формируются в подсети 172.21.0.0 -172.21.255.255."
        echo "Введите номер подсети 172.21.XXX.0 (XXX = 1 - 255):"
    fi
    read TEXT4
else
    TEXT4=$4
fi

aaa=172
bbb=21
ccc=$TEXT4
ddd=0

if [[ $TEXTL -eq $parm1 ]]; then
    echo "=====> SELECTED SUBNET:"
else
    echo "=====> ВЫБРАНА ПОДСЕТЬ:"
fi

echo $aaa$(echo ".")$bbb$(echo ".")$ccc$(echo ".")$ddd
echo OK
sleep 1


#WIREGUARD INSTALLATION

apt update && apt install wireguard curl

#DIRECTORIES & FILES

etc_wg=$(echo "/etc/wireguard")
if [ -d $etc_wg ]; then
    if [[ $TEXTL -eq $parm1 ]]; then
        echo "=====> The directory /etc/wireguard already exists."
    else
        echo "=====> Директория /etc/wireguard уже существует."
    fi
    
else
    mkdir $etc_wg
    if [[ $TEXTL -eq $parm1 ]]; then

        echo "=====> OK The directory /etc/wireguard prepared."
    else
        echo "=====> OK Директория /etc/wireguard создана."
    fi
fi
sleep 1

dir_wg=$(echo "/etc/wireguard/")${iifname}
dir_wgkeys=${dir_wg}$(echo "/.wgkeys")
dir_clprivkey=${dir_wg}$(echo "/.clients_keys_privite")
dir_clpubkey=${dir_wg}$(echo "/clients_key_public")
dir_clients=${dir_wg}$(echo "/clients")
logfile=${dir_wg}$(echo "/installer.log")
install_conf=${dir_wg}$(echo "/")${iifname}$(echo "-installer.conf")

echo "Check and create directories"
if ! [ -d $dir_wg ]; then
    mkdir $dir_wg && mkdir $dir_wgkeys && mkdir $dir_clprivkey && mkdir $dir_clpubkey && mkdir $dir_clients && touch $logfile && touch $install_conf && echo "INTALLEL FILELOG" > $logfile && echo "Directorias prepared OK"
else
    echo "INTALLER FILELOG" > $logfile && echo "Directorias prepared OK"
fi

wg_installer_conf ()
{
echo "# WireGuard configuretion" > $install_conf
echo "# WG network interface name:" >> $install_conf
echo $(echo "iifname=wg")${TEXT1} >> $install_conf
echo "# Number of clients. minimum 2 maximum 252" >> $install_conf
echo $(echo "all_clients=")${TEXT2} >> $install_conf
echo "# Subnet number 172.21.XXX.0" >> $install_conf
echo $(echo "ccc=")${TEXT4} >> $install_conf
echo "# WireGuards port:" >> $install_conf
echo $(echo "PORT=")${PORT} >> $install_conf
echo "# WireGuards subnet:" >> $install_conf
echo $aaa$(echo ".")$bbb$(echo ".")$ccc$(echo ".")$ddd >> $install_conf
}

wg_installer_conf && echo $(echo "Created configure file installer ")${install_conf} >> $logfile
sleep 1

# CREATE SERVERS KEYS

echo "Creating keys"

key_clients=$all_clients
clns_num=1

check_key=${dir_wgkeys}$(echo "/check_key")

server_keys_create ()
{
   wg genkey | tee ${dir_wgkeys}$(echo "/privitekey") | wg pubkey | tee ${dir_wgkeys}$(echo "/publickey") && echo "The keys are created:" > $check_key | date >> $check_key && echo "Created WG keys" >> $logfile $check_key 
}


if ! [ -f $check_key ]; then
    server_keys_create
else
    if [[ $TEXTL -eq $parm1 ]]; then
        echo "WARNING: Keys for the wg-server already exist!"
        cat $check_key
        while true; do
        read -p "Rewrite the keys? (y/n) " yn1
        case $yn1 in 
	        [yY] ) server_keys_create; 
		        break;;
	        [nN] ) echo "The keys were not overwritten...";
                echo "WARNING: The servers keys were not overwritten..." >> $logfile;
		        break;;
	        * ) echo invalid response;;
        esac

        done
        
    else
        echo "ВНИМАНИЕ: Ключи wg-сервера уже созданы!"
        cat $check_key
        while true; do
        read -p "Перезаписать существующие ключи? (y/n) " yn2
        case $yn2 in 
	        [yY] ) server_keys_create; 
		        break;;
	        [nN] ) echo "WARNING: Ключи не были перезаписаны...";
                echo "WARNING: The servers keys were not overwritten..." >> $logfile;
                break;;
	        * ) echo "Неверный аргумент";;
        esac

        done
    fi
fi
sleep 1
    
# CREATE CLIENTS KEYS


check_client_keys=${dir_clprivkey}$(echo "/check_client_keys")

clients_keys_create ()
{
    while [ $clns_num -le $key_clients ]
    do
    (( clns_num++ ))
        if ! [ -f ${dir_clprivkey}$(echo "/$clns_num.privite") ]
        then
            wg genkey | tee ${dir_clprivkey}$(echo "/$clns_num.privite") | wg pubkey | tee ${dir_clpubkey}$(echo "/$clns_num.public") && echo "Client$clns_num keys created" >> $logfile
            echo $(echo $(date +%m-%d-%Y)&(echo " Client$clns_num key created.")) >> $check_client_keys
        else
            if [[ $TEXTL -eq $parm1 ]]; then
                echo "WARNING: Keys for client $clns_num already exist. No keys were created."
            else
                echo "WARNING: Ключи для клиент $clns_num уже существуют. Клучи не были созданы."
               
            fi
            echo "WARNING: Keys for client $clns_num already exist. No keys were created." >> $logfile
        fi
    done
    
}

clients_keys_rewrite ()
{
    while [ $clns_num -le $key_clients ]
    do
    (( clns_num++ ))
        wg genkey | tee ${dir_clprivkey}$(echo "/$clns_num.privite") | wg pubkey | tee ${dir_clpubkey}$(echo "/$clns_num.public") && echo "Client$clns_num keys created" >> $logfile
        echo $(echo $(date +%m-%d-%Y)$(echo " Client$clns_num key created.")) >> $check_client_keys
    done
}

if ! [ -f $check_client_keys ]; then
    echo "CREATED KEYS" > $check_client_keys
    echo >> $check_client_keys
    clients_keys_create
    echo "Created clients keys OK"
else
    if [[ $TEXTL -eq $parm1 ]]; then
        echo "WARNING: Keys for the wg-clients already exist!"
        echo "Rewrite all clients keys? (y)"
        echo "Save all existing client keys and create new client keys? (n)"
        while true; do
        read -p "Rewrite all clients keys? (y/n) " yn3
        case $yn3 in 
	        [yY] ) echo "CREATED KEYS:" > $check_client_keys; 
                echo "" >> $check_client_keys;
                clients_keys_rewrite;
		        break;;
	        [nN] ) echo "ADDED KEYS:" >> $check_client_keys;
                echo "" >> $check_client_keys;
                clients_keys_create;
		        break;;
	        * ) echo invalid response;;
        esac
        done
        
    else
        echo "WARNING: Ключи для wg-клиентов уже существуют!"
        echo "Переписать все ключи клиентов? (y)"
        echo "Сохранить все существующие клиентские ключи и создать новые клиентские ключи? (n)"
        while true; do
        read -p "Переписать все ключи клиентов? (y/n) " yn4
        case $yn4 in 
	        [yY] ) echo "CREATED KEYS:" > $check_client_keys;
                echo "" >> $check_client_keys;
                clients_keys_rewrite;
		        break;;
	        [nN] ) echo "ADDED KEYS:" >> $check_client_keys;
                echo "" >> $check_client_keys;
                clients_keys_create;
		        break;;
	        * ) echo invalid response;;
        esac
        done
    fi
fi
echo "OK All keys completed..."
sleep 1
echo

# CREATE CONFIG FILES

server=${dir_wg}$(echo "/")${iifname}$(echo ".conf")
touch ${server} && echo $(echo "TOUCH FILE: ")${server} >> $logfile

ip4_conf=${dir_wg}$(echo "/public_ipv4.conf")
echo "YOU PUBLIC IPv4 ADRESS" > $ip4_conf
curl -s4 icanhazip.com > $ip4_conf #переписать через "if"

#PUBLIC IPv6
ip6_conf=${dir_wg}$(echo "/public_ipv6.conf")
if [[ $TEXTL -eq $parm1 ]]; then
    echo
    while true; do
    read -p "Will the wg_server support IPv6? (y/n) " yn5
    case $yn5 in 
	    [yY] ) echo $(echo "Address = ")$(curl -s6 icanhazip.com) > $ip6_conf; #переписать через "if"
        break;;
        [nN] ) echo "#Address = " > $ip6_conf;
	        break;;
        * ) echo invalid response;;
    esac
    done
else
    echo
    while true; do
    read -p "Будет ли wg_сервер поддерживать протокол IPv6? (y/n) " yn6
    case $yn6 in 
	    [yY] ) echo $(echo "Address = ")$(curl -s6 icanhazip.com) > $ip6_conf; #переписать через "if"
	        break;;
        [nN] ) echo "#Address = " > $ip6_conf;
	        break;;
        * ) echo invalid response;;
    esac
    done
fi

pub_ip4=$(cat $ip4_conf)
pub_ip6=$(cat $ip6_conf)
in_port=$PORT
ipv4=${aaa}$(echo ".")${bbb}$(echo ".")${ccc}
ipv6=$(echo "fd00:a")${aaa}$(echo ":")${bbb}$(echo ":")${ccc}$(echo "::c")
server_ip4=$ipv4$(echo ".1/24")
server_ip6=${ipv6}$(echo "1/64")

echo $(echo "Public IPv4 adress: ")${pub_ip4}$(echo ":")${in_port} >> $logfile
echo $(echo "Public IPv6 adress: ")${pub_ip6}$(echo ":")${in_port} >> $logfile
echo $(echo "Local server IPv4 adress: ")${server_ip4} >> $logfile
echo $(echo "Local server IPv6 adress: ")${server_ip6} >> $logfile
echo

echo "CREATE CONFIG FILES"

echo "[Interface]" > ${server}
echo $(echo "Address = ")${server_ip4} >> ${server}
echo $(echo "Address = ")${server_ip6} >> ${server}
echo "SaveConfig = true" >> ${server}
echo $(echo "ListenPort = ")${in_port} >> ${server}
server_privkey=$(cat ${dir_wgkeys}$(echo "/privitekey"))
server_pubkey=$(cat ${dir_wgkeys}$(echo "/publickey"))
echo $(echo "PrivateKey = ")${server_privkey} >> ${server}

clients=$all_clients
cln_num=1

config_files_create ()
{
    while [ $cln_num -le $clients ]
    do
    (( cln_num++ ))
    echo "Creat client $cln_num" && echo "" >> ${server}
    echo "#client $cln_num" >> ${server}
    echo "[Peer]" >> ${server}
    echo $(echo "PublicKey = ")$(cat ${dir_clpubkey}$(echo "/$cln_num.public")) >> ${server}
    echo $(echo "AllowedIPs = ")${ipv4}$(echo ".$cln_num/32, ")${ipv6}$(echo "$cln_num/128") >> ${server}

        #CREATE CLIENT CONFIG FILE
        touch $(echo ${dir_clients}$(echo "/client_$cln_num.conf"))
        echo "[Interface]" > $(echo ${dir_clients}$(echo "/client_$cln_num.conf"))
        echo $(echo "PrivateKey = ")$(cat ${dir_clprivkey}$(echo "/$cln_num.privite")) >> $(echo ${dir_clients}$(echo "/client_$cln_num.conf"))
        echo $(echo "Address = ")${ipv4}$(echo ".$cln_num/32, ")${ipv6}$(echo "$cln_num/128") >> $(echo ${dir_clients}$(echo "/client_$cln_num.conf"))
        echo "DNS = 208.67.222.222, 208.67.222.222" >> $(echo ${dir_clients}$(echo "/client_$cln_num.conf"))
        echo "" >> $(echo ${dir_clients}$(echo "/client_$cln_num.conf"))
        echo "[Peer]" >> $(echo ${dir_clients}$(echo "/client_$cln_num.conf"))
        echo $(echo "PublicKey = ")${server_pubkey} >> $(echo ${dir_clients}$(echo "/client_$cln_num.conf"))
        echo $(echo "Endpoint = ")${pub_ip4}$(echo ":")${in_port} >> $(echo ${dir_clients}$(echo "/client_$cln_num.conf"))
        echo "AllowedIPs = 0.0.0.0/0" >> $(echo ${dir_clients}$(echo "/client_$cln_num.conf"))
        echo "PersistentKeepalive = 30" >> $(echo ${dir_clients}$(echo "/client_$cln_num.conf"))
        echo $(echo "Client_$cln_num created IPs: ")${ipv4}$(echo ".$cln_num/32, ")${ipv6}$(echo "$cln_num/128") >> $logfile && echo "Client$cln_num config file created! OK"
    done
}

config_files_create

echo

#COMPLETE

echo "COMPLITED" && echo "COMPLITED" >> $logfile
echo $(echo "Endpoind IPv4: ")${pub_ip4}
echo $(echo "Endpoind IPv6: ")${pub_ip6}
echo $(echo "Interface configurete file in: ")${dir_wg}
echo $(echo "Clients configurete files in: ")${dir_clients}
echo "OK"

exit

