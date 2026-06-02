#!/bin/bash
#SBATCH --job-name=ids-add-column
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=16
#SBATCH --mem=16G
#SBATCH --gres=gpu:1
#SBATCH -p short-simple
#SBATCH --qos=simple
#SBATCH --signal=USR1@5
set -e

# Diretório temporário de processamento rápido no nó do cluster
cdir=${TMPDIR}/process_can_${SLURM_JOB_ID}
mkdir -p "$cdir" 
chmod 700 "$cdir"
cd "$cdir"

# Função executada ao terminar ou se o job for cancelado/interrompido
function clean_up {
    echo ">> Iniciando sincronização dos arquivos modificados de volta para o Home..."
    sync_src="$cdir/can_train_test"
    if [ -d "$sync_src" ]; then
        # Cria uma pasta específica no seu Home para você baixar depois
        mkdir -p ~/can_train_test_modificado
        rsync -av "$sync_src/" ~/can_train_test_modificado/
        echo ">> Sucesso! Arquivos individuais salvos em: ~/can_train_test_modificado/"
    else
        echo "Aviso: O diretório fonte '$sync_src' não existe. Pulando rsync."
    fi

    # Remove a pasta temporária do nó de computação
    cd ..
    rm -rf "$cdir"
    echo ">> Limpeza do nó concluída."
}

# Garante que os arquivos modificados voltem para o Home mesmo em caso de erro
trap 'clean_up' EXIT SIGTERM

# Carrega os módulos do cluster
module purge
module use /opt/easybuild/modules/all
module load flex Bison zlib OpenSSL/1.1
module load Python/3.10.8-GCCcore-12.2.0 Xvfb freeglut glew

# Cria ou ativa o ambiente virtual do Python garantindo as dependências básicas
if [ ! -d ~/ids_venv ]; then
    python3 -m venv ~/ids_venv
    source ~/ids_venv/bin/activate
    python -m pip install pandas gdown
else
    source ~/ids_venv/bin/activate
fi

# 1. Baixa o dataset utilizando o seu link específico do Google Drive
echo "Baixando o dataset do Google Drive..."
python -m gdown "https://drive.google.com/file/d/1sjYWPOAZ62mvlFKPOtJNO-mOIlHQXoTk/view?usp=sharing" -O can_train_test.zip

# 2. Descompacta o arquivo zip na área temporária
echo "Descompactando o dataset..."
unzip can_train_test.zip
rm can_train_test.zip

# 3. Executa o script Python para adicionar a coluna (sem fazer nenhuma concatenação)
echo "Iniciando script de inserção da coluna por arquivo..."
python3 ~/add_attack_column.py "$cdir/can_train_test/set_01/train_01"

echo "Processamento no nó concluído. O comando clean_up vai salvar os arquivos no seu Home."