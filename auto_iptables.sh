#! /bin/bash

#Color presets
RED='\033[0;31m'
RST='\033[0m' #reset color

#Check if script is running as sudo/root and exits on fail
if [[ $EUID -ne 0 ]]; then
   echo -e "\nThis script must be run as ${RED}root${RST} / ${RED}sudo${RST}\n"
   exit 1
fi

# Help function
Help_msg()
{
	echo
	echo "Usage: -f [Input file] -g [Gateway]"
	echo "options:"
	echo -e " f\tSelect input file to use"
	echo -e " g\tSelect default gateway to use"
	echo -e " h\tPrint help Message."
	echo
}

#Input handler
while getopts "f:h" flag; do
	case ${flag} in
		f)	file=${OPTARG};;

		g)	gateway=${OPTARG};;

		h)	Help_msg
			exit;;
		\?)
			echo -e "\nInvalid option\n"
			Help_msg
			exit;;
	esac
done

#Read IPs from input file into IP_array variable
readarray -t IP_array <${file}

#IPTABLES rules
for i in "${IP_array[@]}"; do

	#Check for empty lines
	if [ ! -z "$i" ]; then

		#iptables rules
		iptables -A client_rules -s ${i} -j ACCEPT
		iptables -A client_rules -d ${i} -j ACCEPT

		#Default Gateway rules
		ip route add ${i} via ${gateway}
	fi
done

#For testing purposes only
#iptables -L
#iptables -F client_rules
