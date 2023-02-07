#!/bin/bash

# Requires the following variables
# KUBECTL: kubectl command
# OSMNS: OSM namespace in the cluster vim
# VACC: "pod_id" or "deploy/deployment_id" of the access vnf
# VCPE: "pod_id" or "deploy/deployment_id" of the cpd vnf
# HOMETUNIP: the ip address for the home side of the tunnel
# VNFTUNIP: the ip address for the vnf side of the tunnel
# VCPEPUBIP: the public ip address for the vcpe
# VCPEGW: the default gateway for the vcpe

set -u # to verify variables are defined
: $KUBECTL
: $OSMNS
: $VACC
: $VCPE
: $HOMETUNIP
: $VNFTUNIP
: $VCPEPUBIP
: $VCPEGW
: $HX1
: $HX2
: $BridgeID

echo "RENES_START.SH"
echo "Entramos al renes start tras haber identificado las variables"

if [[ ! $VACC =~ "helmchartrepo-accesschart"  ]]; then
    echo ""       
    echo "ERROR: incorrect <access_deployment_id>: $VACC"
    exit 1
fi

if [[ ! $VCPE =~ "helmchartrepo-cpechart"  ]]; then
    echo ""       
    echo "ERROR: incorrect <cpe_deployment_id>: $VCPE"
    exit 1
fi

echo "Ejecutamos los pods. Nota el osmns es: $OSMNS"

export ACC_EXEC="kubectl exec -n 7b2950d8-f92b-4041-9a55-8d1837ad7b0a -it helmchartrepo-accesschart-0027974866-b85564789-879zf --"
export CPE_EXEC="kubectl exec -n 7b2950d8-f92b-4041-9a55-8d1837ad7b0a -it helmchartrepo-cpechart-0032665116-5b86d87d59-x6rt9 --"
echo "ACC_EXEC = $ACC_EXEC"
echo "CPE_EXEC = $CPE_EXEC"

# Router por defecto en red residencial
VCPEPRIVIP="192.168.255.1"

# Router por defecto inicial en k8s (calico)
K8SGW="169.254.1.1"

## 1. Obtener IPs de las VNFs
echo "## 1. Obtener IPs de las VNFs"
IPACCESS=`$ACC_EXEC hostname -I | awk '{print $1}'`
echo "IPACCESS = $IPACCESS"

IPCPE=`$CPE_EXEC hostname -I | awk '{print $1}'`
echo "IPCPE = $IPCPE"

## 2. Iniciar el Servicio OpenVirtualSwitch en cada VNF:
echo "## 2. Iniciar el Servicio OpenVirtualSwitch en cada VNF"
$ACC_EXEC service openvswitch-switch start
$CPE_EXEC service openvswitch-switch start

## 3. En VNF:access agregar un bridge y configurar IPs y rutas
echo "## 3. En VNF:access agregar un bridge y configurar IPs y rutas"
$ACC_EXEC ovs-vsctl add-br brint
$ACC_EXEC ifconfig net1 $VNFTUNIP/24

#Cambio ACC_EXEC
$ACC_EXEC ip link add vxlanacc type vxlan id 0 remote $HOMETUNIP dstport 4789 dev net1
# En la siguiente línea se ha corregido el dispositivo, que debe ser eth0
$ACC_EXEC ip link add vxlanint type vxlan id 1 remote $IPCPE dstport 8742 dev eth0
$ACC_EXEC ovs-vsctl add-port brint vxlanacc
$ACC_EXEC ovs-vsctl add-port brint vxlanint
$ACC_EXEC ifconfig vxlanacc up
$ACC_EXEC ifconfig vxlanint up
$ACC_EXEC ip route add $IPCPE/32 via $K8SGW

## 4. En VNF:cpe agregar un bridge y configurar IPs y rutas
echo "## 4. En VNF:cpe agregar un bridge y configurar IPs y rutas"
$CPE_EXEC ovs-vsctl add-br brint
$CPE_EXEC ifconfig brint $VCPEPRIVIP/24


#Cambio CPE_EXEC
$CPE_EXEC ovs-vsctl add-port brint vxlanint -- set interface vxlanint type=vxlan options:remote_ip=$IPACCESS options:key=1 options:dst_port=8742
$CPE_EXEC ifconfig brint mtu 1400
$CPE_EXEC ifconfig net1 $VCPEPUBIP/24
$CPE_EXEC ip route add $IPACCESS/32 via $K8SGW
$CPE_EXEC ip route del 0.0.0.0/0 via $K8SGW
$CPE_EXEC ip route add 0.0.0.0/0 via $VCPEGW

#Configuración del bridge
$ACC_EXEC ovs-vsctl set bridge brint protocols=OpenFlow10,OpenFlow12,OpenFlow13
$ACC_EXEC ovs-vsctl set bridge brint other-config:datapath-id=$BridgeID
$ACC_EXEC ovs-vsctl set-controller brint tcp:127.0.0.1:6633
$ACC_EXEC ovs-vsctl set-manager ptcp:6632
echo "$ACC_EXEC"
$ACC_EXEC chmod +x /home/qos_simple_switch_13.py 
$ACC_EXEC ryu-manager ryu.app.rest_qos ryu.app.rest_conf_switch ./home/qos_simple_switch_13.py &

## 5. En VNF:cpe iniciar Servidor DHCP
echo "## 5. En VNF:cpe iniciar Servidor DHCP"
$CPE_EXEC sed -i 's/homeint/brint/' /etc/default/isc-dhcp-server
$CPE_EXEC service isc-dhcp-server restart
sleep 10

## 6. En VNF:cpe activar NAT para dar salida a Internet
echo "## 6. En VNF:cpe activar NAT para dar salida a Internet"
$CPE_EXEC chmod +x /usr/bin/vnx_config_nat 
$CPE_EXEC /usr/bin/vnx_config_nat brint net1

##Ejecución del ArpWatch
echo "ArpWatch"
$CPE_EXEC touch /var/lib/arpwatch/arp.dat
$CPE_EXEC arpwatch -i brint

## Calidad de Servicio QoS
echo "QoS"
$ACC_EXEC curl -X PUT -d '"tcp:127.0.0.1:6632"' http://127.0.0.1:8080/v1.0/conf/switches/$BridgeID/ovsdb_addr
$ACC_EXEC curl -X POST -d '{"port_name": "vxlanacc", "type": "linux-htb", "max_rate": "12000000", "queues": [{"min_rate": "8000000"}, {"max_rate": "4000000"}]}' http://127.0.0.1:8080/qos/queue/$BridgeID
$ACC_EXEC curl -X POST -d '{"match": {"dl_dst": "'${HX1}'", "dl_type": "IPv4"}, "actions":{"queue": "0"}}' http://127.0.0.1:8080/qos/rules/$BridgeID
$ACC_EXEC curl -X POST -d '{"match": {"dl_dst": "'${HX2}'", "dl_type": "IPv4"}, "actions":{"queue": "1"}}' http://127.0.0.1:8080/qos/rules/$BridgeID


