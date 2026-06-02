#!/bin/bash
#SBATCH --job-name=can_one_class
#SBATCH --output=slurm_one_class_%j.out
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=16G

# 1. Pasta temporária para o download
cdir="/tmp/process_can_${SLURM_JOB_ID}"
mkdir -p "$cdir"

echo ">> Garantindo que as bibliotecas estão instaladas no nó..."
# Adicionado 'scapy' na lista de instalação
python3 -m pip install --user --upgrade gdown scapy "numpy<2.0.0" "pandas<2.0.0"

echo ">> Baixando a pasta concatenada do Google Drive..."
# ATENÇÃO: Substitua "COLOQUE_O_NOVO_ID_AQUI" pelo ID real do novo link do Drive!
python3 -m gdown "1TFRx9hXVQsAIJ3K18OvGUasdGN-Wie7e" -O "$cdir/dataset_concatenado.zip"

echo ">> Extraindo os arquivos na sua Home..."
# Cria a pasta base e extrai o zip (ajustando permissões)
mkdir -p ~/can_train_test_concatenado
unzip -q "$cdir/dataset_concatenado.zip" -d ~/can_train_test_concatenado/
chmod -R 755 ~/can_train_test_concatenado/

echo ">> Criando a pasta de saída para as features geradas..."
# Garante que a pasta 'processed_one_class' exista para o framework não dar erro ao salvar
mkdir -p ~/can_train_test_concatenado/processed_one_class

echo ">> Executando o framework (Gerador de Features One-Class)..."
# Abre um sub-shell, vai até a pasta real do framework e roda o script lá de dentro
cd /home/CIN/gmm8/automotive-ids-evaluation-framework-deteccao_intrusao

echo ">> Executando o framework (Gerador de Features One-Class)..."
chmod +x run_framework.sh
./run_framework.sh

echo ">> Limpando os arquivos temporários do download..."
rm -rf "$cdir"

echo ">> Processamento One-Class concluído com sucesso!"