.data
    # armazenar se cooler, irrigação ou iluminação estão ON ou OFF

.text
.globl main

main:
    # pegar a data de iníio antes de entrar no loop
    addi $v0, $0, 30 # service code 30 -> pega o tempo atual do sistema
    syscall # chamada de sistema  ($a0 guarda os 32-bits mais insignificantes do tempo)
    move $s0, $a0 # salva o tempo inicial em $s0
    
    # inicialização de variável para a alternância temporal
    addi $s1, $0, 0 # contador de 1ms (de from 0 a 1000)
    addi $s2, $0, 0 # indicador de turno do mostrador (0 = calor, 1 = umidade, 2 = luminosidade)

main_loop:
    
    # pega o tempo atual
    li $v0, 30 # service code 30 -> pega o tempo atual do sistema
    syscall # chamada de sistema
    move $t0, $a0 # salva o tempo atual em $t0

    # cálculo da diferença de tempo (tempo atual - último tempo)
    sub $t1, $t0, $s0 # $t1 guarda a diferença

    # checagem da passagem do tempo (passou 1ms?)
    li $t2, 1 # carrega o tempo de 1ms em $t2
    blt $t1, $t2, main_loop # se diferença < 1ms, recomeça main_loop (espera)

    # depois de passar 1ms
    # atualização de último tempo para tempo atual para o próximo ciclo
    move $s0, $t0   
    
    
    # contador de alternância temporal
    addi $s1, $s1, 1 # incrementa o contador de milissegundos em 1
    blt $s1, 1000, pula_alterancia # se contador < 1000ms (1 seg), não troca o turno 
    
    # 1 segundo passou:
    addi $s1, $0, 0 # reseta para 0 contador de milissegundos
    addi $s2, $s2, 1 # O turno altera para o próximo sistema (0 -> 1 -> 2)
    blt $s2, 3, pula_alterancia # se o turno é menor do que 3, continua sem trocar
    addi $s2, $0, 0 # se o turno chegou em 3, reseta para 0 (volta ao turno do calor) 


pula_alterancia:
	# checagem de sensor e lógica do atuador TODO:
	
	jal ler_teclado # chama procedimento de teclado.asm apara ler as teclas A, B, C
	
	beq $v0, 0xA, ligar_estufa # se A é critico -> liga estufa
    	beq $v0, 0xB, ligar_irrigacao # se B é crítico -> liga irrigação
    	beq $v0, 0xC, ligar_iluminacao # se C é crítico -> liga iluminação
    	
    	# jal logica_processamento # atualiza alternância de estados (ex: a temperatura é crítica?)
    
    	# jal atualiza_atuadores # chama mostrador.asm para ligar os segmentos do mostrador da esquerda
    
    	# jal atualiza_diagnosticos # chama mostrador.asm para mostrar 'C', 'U' ou 'L' no mostrador da direita
    
    	j main_loop # volta para o início para repetir o processo