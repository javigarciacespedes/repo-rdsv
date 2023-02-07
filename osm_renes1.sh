#!/bin/bash
# OSMNS Need to be defined in calling shell
# KID=$(osm k8scluster-list | grep -Eo [0-9a-z]{8}-[0-9a-z]{4}-[0-9a-z]{4}-[0-9a-z]{4}-[0-9a-z]{12})
# export OSMNS=$(osm k8scluster-show --literal $KID | grep -A1 projects | grep -Eo -m1 [0-9a-z]{8}-[0-9a-z]{4}-[0-9a-z]{4}-[0-9a-z]{4}-[0-9a-z]{12})

# service instance name
export SINAME="renes1"
echo "SINAME=$SINAME"
# HOMETUNIP: the ip address for the home side of the tunnel
export HOMETUNIP="10.255.0.2"
echo "HOMETUNIP=$HOMETUNIP"
# VNFTUNIP: the ip address for the vnf side of the tunnel
export VNFTUNIP="10.255.0.1"
echo "VNFTUNIP=$VNFTUNIP"
# VCPEPUBIP: the public ip address for the vcpe
export VCPEPUBIP="10.100.1.1"
echo "VCPEPUBIP=$VCPEPUBIP"
# VCPEGW: the default gateway for the vcpe
export VCPEGW="10.100.1.254"
echo "VCPEGW=$VCPEGW"
# MACs
export HX1="02:fd:00:04:00:01" #Para QoS
echo "HX1=$HX1"
export HX2="02:fd:00:04:01:01" #Para QoS
echo "HX2=$HX2"
export BridgeID="0000000000000001" #Para QoS
echo "BridgeID=$BridgeID"
./osm_renes_start.sh
