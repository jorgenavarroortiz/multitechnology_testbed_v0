#!/bin/bash
# Jorge Navarro-Ortiz (jorgenavarro@ugr.es), University of Granada 2020

#############################
# Parsing inputs parameters
#############################

usage() {
  echo "Usage: $0 [-m] -o <server/client> [-N <OVPN IP network>] [-S <OVPN server IP address>]" 1>&2;
  echo ""
  echo "E.g. for mptcpUe2: $0 -o server -N 10.8.0.0"
  echo "E.g. for mptcpUe1: $0 -o client -S 10.1.1.4"
  echo "NOTE: You can include several servers in the client by repeating -S <OVPN server IP address>."
  echo ""
  echo "       -m ....................... create namespace MPTCPns with virtual interfaces"
  echo "       -o ....................... create an OpenVPN connection, indicating if this entity is server or client"
  echo "       -N ....................... OVPN network address (only for server)"
  echo "       -S ....................... OVPN server IP address (only for client)"
  exit 1;
}

S=0
while getopts ":mo:N:S:" o; do
  case "${o}" in
    m)
      ns=1
      MPTCPNS="MPTCPns"
      EXEC_MPTCPNS="sudo ip netns exec ${MPTCPNS}"
      echo "NAMESPACE=MPTCPns"
      ;;
    o)
      OVPN=1
      OVPN_ENTITY=${OPTARG}
      echo "Create an OpenVPN connection"
      ;;
    N)
      OVPN_NETWORK_ADDRESS=${OPTARG}
      echo "OVPN network address ${OPTARG}"
      ;;
    S)
      S=S+1
#      OVPN_SERVER_IP=${OPTARG}
      OVPN_SERVER_IP+=("$OPTARG")
      echo "OVPN server IP address ${OPTARG}"
      ;;
    *)
      usage
      ;;
  esac
done
shift $((OPTIND-1))

#if [ -z "${p}" ] || [ -z "${s}" ] || [ -z "${c}" ] || [ -z "${f}" ] || [ -z "${u}" ] || [ -z "${OVPN}" ]; then
#  usage
#fi

# Create OpenVPN connection if required
  if [[ $OVPN_ENTITY == "client" ]]; then
    # OpenVPN client
#    if [[ $ns == 1 ]]; then
#      EXEC_OVPN=$EXEC_MPTCPNS
#    else
      EXEC_OVPN="sudo"
#    fi

    cd ovpn-config-client

    # Automatically modify the configuration file according to the OVPN server IP address
    i=0
    for val in "${OVPN_SERVER_IP[@]}"; do
      i=$((i+1))
      echo "Creating VPN $i connecting to server at $val through tap$((i-1))..."

      cp ovpn-client.conf.GENERIC ovpn-client${i}.conf
      sed -i 's/SERVER_IP_ADDRESS/'${val}'/' ovpn-client${i}.conf
      $EXEC_OVPN openvpn ovpn-client${i}.conf &

      # It is required to remove tap0 from the MPTCP interfaces pool.
      # Otherwise, it will start not working intermittently.
      sleep 5
      TAPIF=`$EXEC_OVPN ip link show | grep tap$((i-1)) -m 1 | cut -d ":" -f 2 | tr -d " "`
      echo "TAPIF: $TAPIF"
    done
  else
    # OpenVPN server
#    if [[ $ns == 1 ]]; then
#      EXEC_OVPN=$EXEC_MPTCPNS
#    else
      EXEC_OVPN="sudo"
#    fi
    # Automatically modify the configuration file according to the OVPN network address
    cd ovpn-config-proxy
    cp ovpn-server.conf.GENERIC ovpn-server.conf
    sed -i 's/OVPN_NETWORK_ADDRESS/'${OVPN_NETWORK_ADDRESS}'/' ovpn-server.conf

    $EXEC_OVPN openvpn ovpn-server.conf &

    # It is required to remove tap0 from the MPTCP interfaces pool.
    # Otherwise, it will start not working intermittently.
    sleep 5
    TAPIF=`$EXEC_OVPN ip link show | grep tap -m 1 | cut -d ":" -f 2 | tr -d " "`
    echo "TAPIF: $TAPIF"
  fi
