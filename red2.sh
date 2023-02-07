export NSID2=$(osm ns-create --ns_name renes2 --nsd_name renes --vim_account dummy_vim)
echo "NSID2 = $NSID2"
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
export ACCPOD2=$(kubectl -n $OSMNS get pods | grep helmchartrepo-accesschart | awk '{print $1}')
echo "ACCPOD = $ACCPOD"
export CPEPOD2=$(kubectl -n $OSMNS get pods | grep helmchartrepo-cpechart | awk '{print $1}')
echo "CPEPOD = $CPEPOD"

echo "Acceso a pods conectados"


#Configuramos los renes 1 y 2
#cd ~/shared/rdsv-final
#sh osm_renes1.sh
sh osm_renes2.sh
