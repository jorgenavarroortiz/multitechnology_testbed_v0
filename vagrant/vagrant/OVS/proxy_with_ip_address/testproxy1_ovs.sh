sudo ifconfig mtap0 0 promisc up
sudo ifconfig toserver-br 10.8.0.1/24 promisc up
sudo sysctl -w net.ipv4.conf.toserver-br.rp_filter=0
sudo sysctl -w net.ipv4.conf.all.rp_filter=0

sudo route add -net 66.6.6.0/27  dev brmptcp_1   # From 66.6.6.0  to 66.6.6.31 through eth1 (to client)
sudo route add -net 66.6.6.32/27 dev toserver-br # From 66.6.6.32 to 66.6.6.63 through eth2 (to server)

# NOTA: añadir el arp -s ... a la interfaz del otro equipo (con -i toserver-br, y otra con -i eth2... parece que con -i toserver-br sirve) -> hay que ver por qué no funciona el ARP
# Poner bien la ruta... ahora mismo 66.6.6.0/24 por eth2, pero habrá que revisarlo... el cliente también está en esa red y se llega por otra interfaz

# Parece que tras poner las rutas bien funciona el ARP... por confirmar
