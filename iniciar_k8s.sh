echo Iniciar Escenario K8S

#Nos conectamos a la MV de K8S
#ssh -l upm 192.168.56.11

#Arrancamos los escenarios home y server en K8s
sudo vnx -f vnx/nfv3_home_lxc_ubuntu64.xml -t
sudo vnx -f vnx/nfv3_server_lxc_ubuntu64.xml -t
xhost +

