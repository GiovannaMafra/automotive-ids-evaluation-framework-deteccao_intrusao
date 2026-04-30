#!/bin/bash
#SBATCH --job-name=agent_build
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=48
#SBATCH --mem=64G
#SBATCH --gres=gpu:1
#SBATCH -p short-complex
#SBATCH --qos=complex
#SBATCH --signal=USR1@5
set -e

cdir=${TMPDIR}/detec${SLURM_JOB_ID}
mkdir -p "$cdir" 
chmod 700 "$cdir"
cd "$cdir"

function clean_up {
    cd $cdir || exit 1
    cd .. || exit 1
    
    rm -rf "${cdir:?}"
    exit
}

trap 'clean_up' EXIT SIGTERM

module purge
module use /opt/easybuild/modules/all
module load flex Bison zlib CMake OpenSSL/1.1
module load Python/3.10.8-GCCcore-12.2.0 Xvfb freeglut glew

if [ ! -d ~/automotive-ids-evaluation-framework-deteccao_intrusao ]; then
    echo "Missing automotive-ids-evaluation-framework-deteccao_intrusao directory. Exiting."
    exit 1
fi

cp -r ~/test/automotive-ids-evaluation-framework-deteccao_intrusao .
cd automotive-ids-evaluation-framework-deteccao_intrusao

if [ ! -d ~/ids_venv ]; then
    python3 -m venv ~/ids_venv
    source ~/ids_venv/bin/activate
    pip install -r requirements.txt
    deactivate
    echo "Virtual environment created and dependencies installed."
else
    echo "Virtual environment already exists. Skipping creation."
fi

source ~/ids_venv/bin/activate

python3 execute_model_test.py --model_test_config config_jsons/test_detection_time/TOW_MC_PrunedCNNIDS_detection_time.json
