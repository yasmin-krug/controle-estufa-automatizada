.text
.globl inicializa_tempo, atualiza_tempo

inicializa_tempo:
# pegar a data de inÃ­cio antes de entrar no loop
	addi $v0, $0, 30 # service code 30 -> pega o tempo atual do sistema
	syscall # chamada de sistema  ($a0 guarda os 32-bits mais baixos do tempo)
	move $s0, $a0 # salva o tempo inicial em $s0
    
    	# inicializaÃ§Ã£o de variÃ¡vel para a alternÃ¢ncia temporal
    	addi $s1, $0, 0 # contador de ms (de 0 a 1000ms)
    	addi $s2, $0, 0 # indicador de turno do mostrador (0 = calor, 1 = umidade, 2 = luminosidade)

	addi $s4, $0, -1 # cache do mostrador esquerdo (Ãºltimo valor desenhado)
    	addi $s5, $0, -1 # cache do mostrador direito (Ãºltimo valor desenhado)
    	jr $ra
    	
atualiza_tempo:
# pega o tempo atual
    	addi $v0, $0, 30 # service code 30 -> pega o tempo atual do sistema
    	syscall # chamada de sistema
    	move $t0, $a0 # salva o tempo atual em $t0

    	# cÃ¡lculo da diferenÃ§a de tempo (tempo atual - Ãºltimo tempo)
    	sub $t1, $t0, $s0 # $t1 guarda a diferenÃ§a

    	# checagem da passagem do tempo (passou de 1ms?)
    	addi $t2, $0, 1 # carrega o tempo de 1ms em $t2
    	
    	blt $t1, $t2, espera_hardware
    	# depois de passar 1ms:
    	# atualização de último tempo para tempo atual para o próximo ciclo
    	move $s0, $t0   
    
    	# contador de alternância temporal
    	add $s1, $s1, $t1 # incrementa o contador com a diferença real de tempo
    	blt $s1, 1000, volta_para_iniciar_logica_atuadores # se contador < 1000ms (1 seg), não troca o turno 
    
    	# 1 segundo passou:
    	addi $s1, $0, 0 # reseta para 0 contador de milissegundos
    	addi $s2, $s2, 1 # O turno altera para o próximo sistema (0 -> 1 -> 2)
    	blt $s2, 3, volta_para_iniciar_logica_atuadores # se o turno é menor do que 3, continua sem trocar
    	addi $s2, $0, 0 # se o turno chegou em 3, reseta para 0 (volta ao turno do calor) 

    	jr $ra
 
volta_para_iniciar_logica_atuadores:
 	jr $ra
    	
espera_hardware:
    # Usamos sleep de 10ms para:
    # 1. Ser rÃ¡pido o suficiente para capturar reaÃ§Ã£o humana (< 150ms)
    # 2. Dar tempo suficiente para o Digital Lab Sim registrar cliques do mouse
    # 3. Evitar que a JVM do MARS trave com busy-wait puro
    addi $v0, $0, 32  # Service code 32 -> sleep
    addi $a0, $0, 10  # Sleep por 10 milissegundos
    syscall           
    j atualiza_tempo
