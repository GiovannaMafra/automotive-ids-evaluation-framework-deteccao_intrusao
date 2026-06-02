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

def process_csv_files(target_dir):
    print(f">> Analisando a pasta principal: {target_dir}")
    if not os.path.exists(target_dir):
        print(f"Erro: A pasta {target_dir} não existe!")
        return

    count = 0
    # os.walk navega por todas as subpastas (as 5 pastas do set_01) automaticamente
    for root, dirs, files in os.walk(target_dir):
        csv_files = [f for f in files if f.endswith('.csv')]
        
        for file_name in csv_files:
            file_path = os.path.join(root, file_name)
            print(f"Processando: {file_path}")
            
            # Descobre o nome do ataque pelo nome do arquivo (ex: 'fuzzing-3.csv' -> 'fuzzing')
            attack_type = file_name.split('-')[0]
            
            try:
                df = pd.read_csv(file_path)
                if 'attack' not in df.columns:
                    print(f"Aviso: Coluna 'attack' não encontrada em {file_name}. Pulando...")
                    continue
                
                # Regra: Se Attack == 1 coloca o tipo do ataque, se for 0 coloca 'normal'
                attack_type = get_attack_type(attack_type);
                df['attack_Type'] = df['attack'].apply(lambda x: attack_type if x == 1 else 'normal')
                
                # Salva por cima do arquivo liberando permissão de escrita
                df.to_csv(file_path, index=False)
                count += 1
            except Exception as e:
                print(f"Erro ao processar {file_name}: {e}")
                
    print(f">> Fim do processamento! Total de arquivos modificados: {count}")

if __name__ == "__main__":
    if len(sys.argv) > 1:
        folder = sys.argv[1]
        process_csv_files(folder)
    else:
        print("Por favor, informe a pasta correta.")
