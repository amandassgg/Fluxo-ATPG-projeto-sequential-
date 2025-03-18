#Configuracoes iniciais

echo "initial configurations"

# FAVOR, INSERIR  O ENDERECO DE SEU CONJUNTO DE BIBLIOTECAS
TECH_DIR="/home/tools/cadence/gpdk/gsclib045_all_v4.4/lan/flow/t1u1/reference_libs/GPDK045"
TECH_DIR_GSC="/home/tools/cadence/gpdk/gsclib045_svt_v4.4/lan/flow/t1u1/reference_libs/GPDK045/gsclib045_svt_v4.4/gsclib045"
TECH_DIR_GPDK="/home/tools/cadence/gpdk/gpdk045_v_6_0"

export PROJECT_DIR=$(pwd)
export DESIGNS=$(basename $PROJECT_DIR)
export BACKEND_DIR=${PROJECT_DIR}/backend
export TECH_DIR=$TECH_DIR
export TECH_DIR_GSC=$TECH_DIR_GSC
export TECH_DIR_GPDK=$TECH_DIR_GPDK
export HDL_NAME=${DESIGNS}
export VLOG_LIST="$BACKEND_DIR/synthesis/deliverables/${DESIGNS}.v  $BACKEND_DIR/synthesis/deliverables/${DESIGNS}_io.v  $BACKEND_DIR/synthesis/deliverables/${DESIGNS}_chip.v"
export CELLS_DIR=${TECH_DIR}/gsclib045_svt_v4.4/lan/flow/t1u1/reference_libs/GPDK045/gsclib045_svt_v4.4/gsclib045/verilog

echo
echo "configurations complete"
echo

#FAVOR, INSERIR A FREQUENCIA EM MHz
FREQ=10  # Substitua pelo valor desejado

FREQ=$(expr $FREQ \* 1000000)
period_clock=$((1000000000 / FREQ))

export period_clock
        

echo "Period is: $period_clock ns"
echo
cd ${PROJECT_DIR}/backend/synthesis/work

#GENUS
#genus -abort_on_error -lic_startup Genus_Synthesis -lic_startup_options Genus_Physical_Opt -log genus -overwrite -files ${PROJECT_DIR}/backend/synthesis/scripts/genus.tcl 

#MODUS
modus -abort_on_error -log atpg -overwrite -files ${PROJECT_DIR}/backend/synthesis/work/test_scripts/runmodus.atpg.tcl
