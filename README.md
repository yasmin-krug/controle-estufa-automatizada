# controle-estufa-automatizada
Projeto de sistema de controle para uma Estufa Automatizada em Assembly MIPS

Atividades realizadas por arquivo:

main.asm:
1) guarda o tempo inicial e inicializa variáveis para alternância temporal
2) inicia loop que registra o tempo atual e compara com o inicial; quando chega a 1ms, atualiza o tempo atual para o presente; incrementa um contador de milissegundos da alternância; verifica se o contador já atingiu 1000ms e, se sim, reseta ele. Senão, o procedimento pula_alternância inicia, aplicando toda a lógica de: leitura do teclado, atualização de estados, atuadores e diagnósticos, e repete o processo.

teclado.asm:
1) faz a leitura do teclado "selecionando" as linhas e verificando o endereço de memória relativo às colunas, checando somente as teclas de interesse (A, B e C) e direcionando ao procedimento de cada uma (o procedimento apenas carrega o valor da tecla para ser devolvido pela função e chama o procedimento checar_repetição
2) contém os procedimentos de detecção das teclas e os procedimentos checar_repeticao e ignorar_tecla
3) checar repeticao faz edge detection (identifica apenas a tecla do último clique), prevenindo o programa de alternar o estado a cada checagem da tecla e, por consequência, ligar e desligar o sistema muitas vezes em pouquíssimo tempo). Para isso, o procedimento usa um outro auxiliar (ignorar_tecla), que retorna 0 ao main.asm

mostrador.asm:

