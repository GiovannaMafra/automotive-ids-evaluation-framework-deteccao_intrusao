import os
import sys
import glob
import pandas as pd

def get_attack_type(filename):
    """Define o tipo de ataque baseado no nome do arquivo (case-insensitive)."""
    filename_lower = filename.lower()
    
    if 'dos' in filename_lower:
        return 'DoS'
    elif 'fuzzing' in filename_lower:
        return 'fuzzing'
    elif 'interval' in filename_lower:
        return 'interval'
    elif 'standstill' in filename_lower:
        return 'standstill'
    elif 'systematic' in filename_lower:
        return 'systematic'
    else:
        return 'spoofing'

def main():
    if len(sys.argv) < 2:
        print("Erro: Você precisa passar o caminho do diretório.")
        print("Uso: python3 add_attack_column.py <diretorio_dos_csvs>")
        sys.exit(1)
        
    target_dir = sys.argv[1]
    if not os.path.isdir(target_dir):
        print(f"Erro: O diretório '{target_dir}' não existe.")
        sys.exit(1)

    # Busca todos os arquivos .csv dentro da pasta informada
    csv_files = glob.glob(os.path.join(target_dir, "*.csv"))
    
    if not csv_files:
        print(f"Nenhum arquivo .csv encontrado em: {target_dir}")
        return

    print(f"Iniciando o processamento de {len(csv_files)} arquivos...")

    for file_path in csv_files:
        filename = os.path.basename(file_path)
        attack_label = get_attack_type(filename)
        
        print(f"-> Processando: '{filename}' | Classe: {attack_label}")
        
        try:
            # Carrega o arquivo individual
            df = pd.read_csv(file_path)
            
            # Adiciona a nova coluna com o tipo correspondente
            df['attack_type'] = attack_label
            
            # Sobrescreve o arquivo original adicionando a coluna
            df.to_csv(file_path, index=False)
            
        except Exception as e:
            print(f"  [ERRO] Falha ao processar {filename}: {e}")

    print("\n[SUCESSO] Todos os arquivos individuais foram processados e rotulados!")

if __name__ == "__main__":
    main()