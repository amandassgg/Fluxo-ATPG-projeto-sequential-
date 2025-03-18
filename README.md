#Sequential - Síntese lógica e fluxo ATPG

Por: Amanda Sousa Gonçalves 

O projeto em questão implementa a síntese lógica e fluxo ATPG de um circuito sequencial descrito em VHDL. O circuito é uma máquina de estados finitos (FSM) com quatro estados: `IDLE`, `FETCH`, `DECODE` e `EXEC`. 

## Estrutura do Projeto

O projeto é composto pelos seguintes principais arquivos:

- **sequential.vhd**: Arquivo VHDL que descreve a máquina de estados finitos (FSM).
- **run_first.sh**: Script para configurar o ambiente e executar a síntese e o DFT.
- **Genus**: Ferramenta utilizada para síntese lógica.
  - Relatórios e arquivos gerados em `backend/synthesis/deliverables/` e `backend/synthesis/reports/`.
- **Modus**: Ferramenta utilizada para DFT (Automatic Test Pattern Generation - ATPG).
  - Relatórios e scripts em `backend/synthesis/work/test_scripts/`.

Observação: O script `run_first.sh` deve ser editado para configurar os caminhos das bibliotecas de tecnologia (`TECH_DIR`, `TECH_DIR_GSC`, `TECH_DIR_GPDK`) e a frequência de operação (`FREQ`).
Para executar o genus (síntese lógica e DFT), retire o comentário (#) da linha 38;
Para executar o modus, retire o comentário (#) da linha 41;

## Executando o Projeto

Para executar a síntese e o DFT, siga os passos abaixo:

1. Edite o script `run_first.sh` para configurar os caminhos das bibliotecas e a frequência de operação.
2. Execute o script:

   ```bash
   ./run_first.sh
3. Recomenda-se rodar primeiro o Genus e, em seguida, editar o run_first.sh para rodar o Modus.
