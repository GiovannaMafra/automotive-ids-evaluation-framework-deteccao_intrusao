#!/bin/bash
#SBATCH --job-name=process_set01
#SBATCH --output=slurm-%j.out
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=16G

# Criando uma pasta temporária única para este Job (evita erro de permissão)
cdir="/tmp/process_can_${SLURM_JOB_ID}"
mkdir -p "$cdir"

echo ">> Baixando o dataset do Google Drive..."
python3 -m gdown --id "1sjYWPOAZ62mvlFKPOtJNO-mOIlHQXoTk" -O "$cdir/dataset.zip"

echo ">> Extraindo APENAS a pasta set_01 para economizar espaço..."
# O "*/set_01/*" diz para o unzip ignorar o set_02, set_03, set_04, etc.
unzip -q "$cdir/dataset.zip" "*/set_01/*" -d "$cdir"

# Força permissão total de leitura/escrita nos arquivos extraídos
chmod -R 755 "$cdir"

echo ">> Localizando a pasta set_01 extraída..."
TARGET_DIR=$(find "$cdir" -type d -name "set_01" | head -n 1)

if [ -z "$TARGET_DIR" ]; then
    echo "Erro Crítico: Pasta set_01 não foi encontrada no zip!"
    chmod -R 755 "$cdir" && rm -rf "$cdir"
    exit 1
fi

echo ">> Executando o script Python nas subpastas de: $TARGET_DIR"
python3 ./add_attack_column.py "$TARGET_DIR"

echo ">> Enviando APENAS o set_01 modificado para a sua Home..."
mkdir -p ~/can_train_test_modificado
rsync -avz "$TARGET_DIR/" ~/can_train_test_modificado/set_01/

echo ">> Limpando os arquivos temporários com segurança..."
chmod -R 755 "$cdir"
rm -rf "$cdir"

echo ">> Processo concluído com sucesso!"