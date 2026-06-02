#!/bin/bash
#SBATCH --job-name=train-rf-can
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=16
#SBATCH --mem=16G
#SBATCH -p short-simple
#SBATCH --qos=simple
#SBATCH --output=slurm_train_rf_%j.out 
#SBATCH --signal=USR1@5

python3 -m pip install --user --upgrade scikit-learn torch torchmetrics "numpy<2.0.0" "pandas<2.0.0"

echo ">> Entrando na pasta do framework..."
cd /home/CIN/gmm8/automotive-ids-evaluation-framework-deteccao_intrusao

# Defina aqui o caminho do JSON que você salvou com as configurações do Random Forest
SELECTED_MODEL_TRAIN_VALIDATE_CONFIG="config_jsons/model_train_validate/CAN_rf_train_one_class.json"

echo ">> Iniciando o Treinamento do Random Forest (One-Class) para o CAN..."
python3 execute_model_train_validation.py --config $SELECTED_MODEL_TRAIN_VALIDATE_CONFIG

echo ">> Treinamento concluído!"