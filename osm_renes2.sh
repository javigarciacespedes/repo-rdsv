
#!/bin/bash
# OSMNS Need to be defined in calling shell
# KID=$(osm k8scluster-list | grep -Eo [0-9a-z]{8}-[0-9a-z]{4}-[0-9a-z]{4}-[0-9a-z]{4}-[0-9a-z]{12})
# export OSMNS=$(osm k8scluster-show --literal $KID | grep -A1 projects | grep -Eo -m1 [0-9a-z]{8}-[0-9a-z]{4}-[0-9a-z]{4}-[0-9a-z]{4}-[0-9a-z]{12})

# service instance name
export SINAME="renes2"

# HOMETUNIP: the ip address for the home side of the tunnel
export HOMETUNIP="10.255.0.4"

# VNFTUNIP: the ip address for the vnf side of the tunnel
export VNFTUNIP="10.255.0.3"

# VCPEPUBIP: the public ip address for the vcpe
export VCPEPUBIP="10.100.1.2"

# VCPEGW: the default gateway for the vcpe
export VCPEGW="10.100.1.254"

# MACs
export HX1="02:fd:00:04:03:01"
export HX2="02:fd:00:04:04:01"
export BridgeID="0000000000000002"
./osm_renes_start2.sh
