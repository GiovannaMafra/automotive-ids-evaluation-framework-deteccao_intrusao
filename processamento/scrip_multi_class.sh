#!/bin/bash
#SBATCH --job-name=can_multi_class
#SBATCH --output=slurm_multi_class_%j.out
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=16
#SBATCH --mem=16G
#SBATCH -p short-simple
#SBATCH --qos=simple

# 1. Pasta temporária para o download
cdir="/tmp/process_can_${SLURM_JOB_ID}"
mkdir -p "$cdir"

echo ">> Garantindo que as bibliotecas estão instaladas no nó..."
# ---> ALTERADO AQUI: Adicionado 'scikit-learn' <---
python3 -m pip install --user --upgrade gdown scapy scikit-learn "numpy<2.0.0" "pandas<2.0.0"

echo ">> Baixando a pasta concatenada do Google Drive..."
# ATENÇÃO: Substitua "COLOQUE_O_NOVO_ID_AQUI" pelo ID real do novo link do Drive!
python3 -m gdown "1TFRx9hXVQsAIJ3K18OvGUasdGN-Wie7e" -O "$cdir/dataset_concatenado.zip"

echo ">> Extraindo os arquivos na sua Home..."
# ---> ALTERADO AQUI: Adicionado '-qo' para sobrescrever sem perguntar e extraindo direto em '~/' <---
unzip -qo "$cdir/dataset_concatenado.zip" -d ~/
chmod -R 755 ~/can_train_test_concatenado/

echo ">> Arquivo baixado. Iniciando limpeza expressa de 'NA'..."

python3 -c "
import pandas as pd
path = '/home/CIN/gmm8/can_train_test_concatenado/test_03_known_vehicle_unknown_attack/concatenated_test_03.csv'
df = pd.read_csv(path)
df = df.dropna()
for col in df.select_dtypes(include=['object']).columns:
    df = df[df[col] != 'NA']
df.to_csv(path, index=False)
"
echo ">> Arquivo limpo com sucesso! Continuando o pipeline..."

echo ">> Criando a pasta de saída para as features geradas..."
# ALTERADO: Agora cria a subpasta 'train'
mkdir -p ~/can_train_test_concatenado/processed_multi_class/test_03

echo ">> Executando o framework (Gerador de Features Multi-Class)..."
# Abre um sub-shell, vai até a pasta real do framework e roda o script lá de dentro
cd /home/CIN/gmm8/automotive-ids-evaluation-framework-deteccao_intrusao

echo ">> Executando o framework (Gerador de Features Multi-Class)..."
chmod +x run_framework.sh
./run_framework.sh

echo ">> Limpando os arquivos temporários do download..."
rm -rf "$cdir"

echo ">> Processamento One-Class concluído com sucesso!"