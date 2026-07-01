.data
    	# endereços de memória do teclado no simulador
    	endereco_linha: .word 0xFFFF0012  # onde escrevemos para escolher a linha
    	endereco_coluna: .word 0xFFFF0014  # onde lemos para saber qual coluna foi apertada
    
    	map_a: .word 0x44
    	map_b: .word 0xffffff84
    	map_c: .word 0x18
    
    	# variável para evitar efeito metralhadora (vários cliques enquanto segura o botão)
    	ultima_tecla: .word 0 # 0 -> nenhuma, 0xA -> tecla A...

.text
.globl ler_teclado, processa_teclado

ler_teclado:
	# salvar endereços base nos registradores
    	lw $t0, endereco_linha
    	lw $t1, endereco_coluna

    	# verificação da linha 2 (teclas 8, 9, A, B) ---
    	li $t2, 0x04 # 0x04 seleciona a linha 2
    	sb $t2, 0($t0) # envia o comando para o teclado 
    
    	nop
    	nop
    
    
    	lb $t3, 0($t1) # lê a resposta (qual coluna está pressionada)
    	# checa se é a tecla A (coluna 2 -> 0x04)
    	lw $t6, map_a
    	beq $t3, $t6, a_detectada
	
    	# checa se é a tecla B (coluna 3 -> 0x08)
    	lw $t6, map_b
    	beq $t3, $t6, b_detectada
	
    	# verificação da linha 3 (teclas C, D, E, F) ---
    	li $t2, 0x08 # 0x08 seleciona a Linha 3
    	sb $t2, 0($t0) # envia o comando para o teclado
    
    	li $v0, 32
    	li $a0, 10
    	syscall
    
    	lb $t3, 0($t1) # lê a resposta
    	# checa se é a tecla C (coluna 0 -> 0x01)
    	lw $t6, map_c
    	beq $t3, $t6, c_detectada
    

    	# nenhuma tecla foi pressionada:
    	# zera a memória de última tecla
    	sw $zero, ultima_tecla
    	li $v0, 0 # retorna 0 (nenhuma ação)
    	jr $ra # retorna ao chamador (volta para o main.asm)


# processamento da tecla A
a_detectada:
    	li $t4, 0xA # código da tecla A
    	j checar_repeticao


# processamento da tecla B
b_detectada:
    	li $t4, 0xB # código da tecla B
    	j checar_repeticao


# processamento da tecla C
c_detectada:
    	li $t4, 0xC # código da tecla C
    	j checar_repeticao


# "Edge Detection" -> identificar apenas a tecla do último clique
checar_repeticao:
    	lw $t5, ultima_tecla # carrega a última tecla que foi lida no ciclo anterior
    	beq $t4, $t5, ignora_tecla # se a tecla atual for igual a anterior, o botão está sendo segurado

    # se a tecla for nova (primeiro clique):
   	sw $t4, ultima_tecla # atualiza a memória para dizer "esta tecla está sendo segurada agora"
    	move $v0, $t4 # coloca o código da tecla (0xA, 0xB ou 0xC) em $v0 
    
    	jr $ra # retorna ao chamador (volta para o main.asm)

ignora_tecla:
    	li $v0, 0 # retorna 0 (ignora a tecla, pois já foi registrada no instante que afundou)
    	jr $ra # retorna ao chamador (volta para o main.asm)
    
processa_teclado:
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	jal ler_teclado # chama procedimento de teclado.asm para ler as teclas A, B, C
	# $v0 retorna: 0xA (tecla A), 0xB (tecla B), 0xC (tecla C) ou 0 (nenhuma)
	
	# IMPORTANTE: salva o resultado de ler_teclado em $s6 antes de qualquer jal
	# pois jal sobrescreve $ra e chamadas subsequentes destroem $v0
	move $s6, $v0

	beq $s6, 0xA, controle_calor # liga/desliga estufa conforme o estado (cr�tico ou n�o) de A
    	beq $s6, 0xB, controle_umid  # liga/desliga irriga��o conforme o estado (cr�tico ou n�o) de B
    	beq $s6, 0xC, controle_luz   # liga/desliga ilumina��o conforme o estado (cr�tico ou n�o) de C
    	j volta_main
    	
controle_calor:
    	jal altera_estado_calor
    	j volta_main

controle_umid:
    	jal altera_estado_umidade # TODO: descomentar quando terminar
    	j volta_main
    
controle_luz:
    	jal altera_estado_luz # TODO: descomentar quando terminar

volta_main:
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra
