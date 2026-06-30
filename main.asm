.text
.globl main

main:
	# pegar a data de início antes de entrar no loop
	addi $v0, $0, 30 # service code 30 -> pega o tempo atual do sistema
	syscall # chamada de sistema  ($a0 guarda os 32-bits mais baixos do tempo)
	move $s0, $a0 # salva o tempo inicial em $s0
    
    	# inicialização de variável para a alternância temporal
    	addi $s1, $0, 0 # contador de ms (de 0 a 1000ms)
    	addi $s2, $0, 0 # indicador de turno do mostrador (0 = calor, 1 = umidade, 2 = luminosidade)

	addi $s4, $0, -1 # cache do mostrador esquerdo (último valor desenhado)
    	addi $s5, $0, -1 # cache do mostrador direito (último valor desenhado)
    	
main_loop:
    
    	# pega o tempo atual
    	addi $v0, $0, 30 # service code 30 -> pega o tempo atual do sistema
    	syscall # chamada de sistema
    	move $t0, $a0 # salva o tempo atual em $t0

    	# cálculo da diferença de tempo (tempo atual - último tempo)
    	sub $t1, $t0, $s0 # $t1 guarda a diferença

    	# checagem da passagem do tempo (passou de 1ms?)
    	addi $t2, $0, 1 # carrega o tempo de 1ms em $t2
    	
    	blt $t1, $t2, espera_hardware
    	
    	# depois de passar 1ms:
    	# atualização de último tempo para tempo atual para o próximo ciclo
    	move $s0, $t0   
    
    	# contador de alternância temporal
    	add $s1, $s1, $t1 # incrementa o contador com a diferença real de tempo
    	blt $s1, 1000, pula_alternancia # se contador < 1000ms (1 seg), não troca o turno 
    
    	# 1 segundo passou:
    	addi $s1, $0, 0 # reseta para 0 contador de milissegundos
    	addi $s2, $s2, 1 # O turno altera para o próximo sistema (0 -> 1 -> 2)
    	blt $s2, 3, pula_alternancia # se o turno é menor do que 3, continua sem trocar
    	addi $s2, $0, 0 # se o turno chegou em 3, reseta para 0 (volta ao turno do calor) 

pula_alternancia:
	
	# checagem de sensor e lógica dos atuadores:
	
	jal ler_teclado # chama procedimento de teclado.asm para ler as teclas A, B, C
	# $v0 retorna: 0xA (tecla A), 0xB (tecla B), 0xC (tecla C) ou 0 (nenhuma)
	
	# IMPORTANTE: salva o resultado de ler_teclado em $s6 antes de qualquer jal
	# pois jal sobrescreve $ra e chamadas subsequentes destroem $v0
	move $s6, $v0

	beq $s6, 0xA, controle_calor # liga/desliga estufa conforme o estado (crítico ou não) de A
    	beq $s6, 0xB, controle_umid  # liga/desliga irrigação conforme o estado (crítico ou não) de B
    	beq $s6, 0xC, controle_luz   # liga/desliga iluminação conforme o estado (crítico ou não) de C
    
    	j logica_atuadores # nenhuma tecla pressionada -> pula para atualizar displays
 
controle_calor:
    jal altera_estado_calor # chama proc de temperatura.asm
    j logica_atuadores
    
controle_umid:
    jal altera_estado_umidade # TODO: descomentar quando terminar
    j logica_atuadores
    
controle_luz:
    jal altera_estado_luz # TODO: descomentar quando terminar
    j logica_atuadores
    
# lógica dos atuadores (mostrador esquerdo):

logica_atuadores: # começa sempre verificando a temperatura e segue checando os demais

    addi $s3, $0, 0 # acumulador de bits
    
    jal get_estado_calor # chama proc de temperatura.asm
    beq $v0, 0, check_u # se não for crítico, passa a checar a umidade
    ori $s3, $s3, 0x01 # se calor = 1, acende o bit 0 (0x01 - segmento cima)

check_u:
    jal get_estado_umidade # chama proc de umidade.asm
     beq $v0, 0, check_l # se não for crítico, passa a checar a luminosidade
     ori $s3, $s3, 0x40 # se umidade = 1, acende o bit 6 (0x40 - segmento meio)

check_l:
    jal get_estado_luz # chama proc de luminosidade.asm
     beq $v0, 0, push_atuadores
     ori $s3, $s3, 0x08 # Se luz=1, acende o bit 3 (0x08 - segmento inferior)

push_atuadores:
    beq $s3, $s4, diag_calor # "cache" -> Se o mostrador já tem esse valor, pula para não piscar!
    move $s4, $s3 # salva o novo valor no "cache"
    
    move $a0, $s3 # coloca os bits corretos em $a0 ANTES de chamar a função
    jal atualiza_atuadores # chama mostrador.asm para acender as barras
    

# lógica do diagnóstico (mostrador direito):
diag_calor:
    bne $s2, 0, diag_umid # se não for o turno 0, checa o turno 1
    jal get_estado_calor   # chama proc de temperatura.asm; retorna 0 (ideal) ou 1 (crítico) em $v0
    beq $v0, 0, apagar_diag # calor não está crítico -> apaga o display (nada a mostrar neste turno)
    
    # calor está crítico -> mostra 'C'
    addi $t3, $0, 'C'
    beq $t3, $s5, fim_loop # "cache" -> se 'C' já está desenhado, não desenha de novo
    move $s5, $t3
    move $a0, $t3 # coloca 'C' em $a0 antes de chamar a função
    jal atualiza_diagnostico
    j fim_loop

diag_umid:
    bne $s2, 1, diag_luz
     jal get_estado_umidade
     beq $v0, 0, apagar_diag
     addi $t3, $0, 'U'
     beq $t3, $s5, fim_loop
     move $s5, $t3
     move $a0, $t3
     jal atualiza_diagnostico
     j fim_loop
    j apagar_diag # turno de umidade, mas umidade não implementada -> apaga display

diag_luz:
    bne $s2, 2, apagar_diag
     jal get_estado_luz
    beq $v0, 0, apagar_diag
     addi $t3, $0, 'L'
     beq $t3, $s5, fim_loop
     move $s5, $t3
     move $a0, $t3
     jal atualiza_diagnostico
     j fim_loop
    j apagar_diag # turno de luz, mas luz não implementada -> apaga display
    
apagar_diag:
    # apaga o mostrador direito se o sistema do turno atual não está ativo
    li $t3, 0
    beq $t3, $s5, fim_loop # "cache" -> se o display já está apagado, não apaga de novo
    move $s5, $t3
    move $a0, $t3
    jal atualiza_diagnostico

fim_loop:
    j main_loop # volta para o início para repetir o processo 
    
espera_hardware:
    # Usamos sleep de 10ms para:
    # 1. Ser rápido o suficiente para capturar reação humana (< 150ms)
    # 2. Dar tempo suficiente para o Digital Lab Sim registrar cliques do mouse
    # 3. Evitar que a JVM do MARS trave com busy-wait puro
    addi $v0, $0, 32  # Service code 32 -> sleep
    addi $a0, $0, 10  # Sleep por 10 milissegundos
    syscall           
    j main_loop
