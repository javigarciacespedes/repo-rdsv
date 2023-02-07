#Nos conectamos por ssh a OSM
#ssh -l upm 192.168.56.12 


echo "Listamos y guardamos el id del cluster de k8s"
osm k8scluster-list
export KID=$(osm k8scluster-list | grep -i -E -o [0-9a-z]{8}-[0-9a-z]{4}-[0-9a-z]{4}-[0-9a-z]{4}-[0-9a-z]{12})
echo "KID = $KID"

echo "Creamos la variable OSMNS"
export OSMNS=$(osm k8scluster-show --literal $KID | grep -A1 projects | grep -E -o -m1 [0-9a-z]{8}-[0-9a-z]{4}-[0-9a-z]{4}-[0-9a-z]{4}-[0-9a-z]{12})
#export OSMNS=7b2950d8-f92b-4041-9a55-8d1837ad7b0a
echo "OSMNS = $OSMNS"

#Punto 5 - Añadimos el repo al interfaz web
echo "Helm Chart Repo"
osm repo-add --type helm-chart --description "Repositorio Helm" helmchartrepo https://juanfranvs.github.io/repo-rdsv

#Punto 7 - Instalación de descriptores/añadimos los ficheros tar
echo "Creando los helms de accessknf"
osm vnfd-create /home/upm/shared/repo-rdsv/pck/accessknf_vnfd.tar.gz
echo "Creando los helms de cpeknf"
osm vnfd-create /home/upm/shared/repo-rdsv/pck/cpeknf_vnfd.tar.gz
echo "Creando los helms de renes"
osm nsd-create /home/upm/shared/repo-rdsv/pck/renes_ns.tar.gz

#Punto 9 - Configuramos las variables de entorno
echo "Creamos la variable para posteriormete borrarla y exportarla de nuevo. Esperamos 70 segundos"
export NSID1=$(osm ns-create --ns_name renes1 --nsd_name renes --vim_account dummy_vim)
echo "NSID1 = $NSID1"
sleep 70
osm ns-delete $NSID1
echo "NSID1 = $NSID1 eliminado. Esperando 70 segundos."
sleep 70
echo "Volviendo a crear NSID1. Esperando 70 segundos para continuar el flujo de ejecución."
export NSID1=$(osm ns-create --ns_name renes1 --nsd_name renes --vim_account dummy_vim)
echo "NSID1 = $NSID1"
echo "Creamos la variable para posteriormete borrarla y exportarla de nuevo. Esperamos 70 segundos"
export NSID2=$(osm ns-create --ns_name renes2 --nsd_name renes --vim_account dummy_vim)
echo "NSID1 = $NSID2"
sleep 70
osm ns-delete $NSID2
echo "NSID2 = $NSID2 eliminado. Esperando 70 segundos."
sleep 70
echo "Volviendo a crear NSID1. Esperando 70 segundos para continuar el flujo de ejecución."
export NSID2=$(osm ns-create --ns_name renes2 --nsd_name renes --vim_account dummy_vim)
echo "NSID2 = $NSID2"
sleep 70
#Punto 10 - Accedemos a los pods
echo "Acceso y exportación de los pods"
kubectl -n $OSMNS get pods
export ACCPOD=$(kubectl -n $OSMNS get pods | grep helmchartrepo-accesschart | awk '{print $1}')
echo "ACCPOD = $ACCPOD"
export CPEPOD=$(kubectl -n $OSMNS get pods | grep helmchartrepo-cpechart | awk '{print $1}')
echo "CPEPOD = $CPEPOD"
#export ACCPOD=$(kubectl -n $OSMNS get pods --no-headers -o custom-columns=":metadata.name" | grep access)
#export CPEPOD=$(kubectl -n $OSMNS get pods --no-headers -o custom-columns=":metadata.name" | grep cpe)

#----PROBAR----- Punto 11 - Acceso a los pods ya conectados
echo "Acceso a pods conectados"


#Configuramos los renes 1 y 2
#cd ~/shared/rdsv-final
sh osm_renes1.sh
sh osm_renes2.sh
