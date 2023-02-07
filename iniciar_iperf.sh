#Dentro de K8S
#Primero paramos los escenarios con los comandos:
sudo vnx -f vnx/nfv3_home_lxc_ubuntu64.xml -d
sudo vnx -f vnx/nfv3_server_lxc_ubuntu64.xml -d
#Arrancamos la imagen con modo directo:
vnx --modify-rootfs /usr/share/vnx/filesystems/vnx_rootfs_lxc_ubuntu64-20.04-v025-vnxlab/
#Hacemos login user:root password:xxxx

#Paramos el contenedor:
halt -p

#Arrancamos de nuevo los escenarios y comprobamos que iperf se encuentra activo
sudo vnx -f vnx/nfv3_home_lxc_ubuntu64.xml -t
sudo vnx -f vnx/nfv3_server_lxc_ubuntu64.xml -t

#Declaración de los iperf:

#Para el host h11
#Elegimos una velocidad superior a la asignada para comprobar 
#iperf -c 192.168.255.21 -p 5002 -u -b 13M -l 1200 //EJECUTAR EN EL CPE

#Para el host h12
#iperf -c 192.168.255.20 -p 5002 -u -b 13M -l 1200

#Ejecutar el server para escuchar peticiones en el puerto
#iperf -s -u -i 1 -p 5002 //EJECUTAR EN H12
