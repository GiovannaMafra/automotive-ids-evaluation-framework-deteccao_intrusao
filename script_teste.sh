#!/bin/bash
#SBATCH --job-name=teste-cnn-can
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=16
#SBATCH --mem=16G
#SBATCH --gres=gpu:1
#SBATCH -p short-simple
#SBATCH --qos=simple
#SBATCH --output=slurm_teste_cnn_%j.out
#SBATCH --signal=USR1@5

python3 -m pip install --user --upgrade scikit-learn torch torchmetrics "numpy<2.0.0" "pandas<2.0.0"

echo ">> Entrando na pasta do framework..."
cd /home/CIN/gmm8/automotive-ids-evaluation-framework-deteccao_intrusao

# Defina aqui o caminho do JSON que você salvou com as configurações do Random Forest
SELECTED_MODEL_TRAIN_VALIDATE_CONFIG="config_jsons/model_test/CAN_test_03_PrunedCNNIDS.json"

echo ">> Iniciando o Teste do CNN para o CAN Teste 01..."
python3 execute_model_test.py --model_test_config $SELECTED_MODEL_TRAIN_VALIDATE_CONFIG

echo ">> Teste concluído!"