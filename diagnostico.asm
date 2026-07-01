.text
.globl logica_diagnostico

# lógica do diagnóstico (mostrador direito):
logica_diagnostico:
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	
diag_calor:
    	bne $s2, 0, diag_umid # se não for o turno 0, checa o turno 1
    	jal get_estado_calor   # chama proc de temperatura.asm; retorna 0 (ideal) ou 1 (crítico) em $v0
    	beq $v0, 0, apagar_diag # calor não está crítico -> apaga o display (nada a mostrar neste turno)
    
    	# calor está crítico -> mostra 'C'
    	addi $t3, $0, 'C'
    	beq $t3, $s5, volta_main # "cache" -> se 'C' já está desenhado, não desenha de novo
    	move $s5, $t3
    	move $a0, $t3 # coloca 'C' em $a0 antes de chamar a função
    	jal atualiza_diagnostico
    	j volta_main

diag_umid:
    	bne $s2, 1, diag_luz
     	jal get_estado_umidade
     	beq $v0, 0, apagar_diag
     	addi $t3, $0, 'U'
     	beq $t3, $s5, volta_main
     	move $s5, $t3
     	move $a0, $t3
     	jal atualiza_diagnostico
     	j volta_main
    	j apagar_diag # turno de umidade, mas umidade não implementada -> apaga display

diag_luz:
    bne $s2, 2, apagar_diag
     jal get_estado_luz
    beq $v0, 0, apagar_diag
     addi $t3, $0, 'L'
     beq $t3, $s5, volta_main
     move $s5, $t3
     move $a0, $t3
     jal atualiza_diagnostico
     j volta_main
    j apagar_diag # turno de luz, mas luz não implementada -> apaga display
    
apagar_diag:
    # apaga o mostrador direito se o sistema do turno atual não está ativo
    li $t3, 0
    beq $t3, $s5, volta_main # "cache" -> se o display já está apagado, não apaga de novo
    move $s5, $t3
    move $a0, $t3
    jal atualiza_diagnostico
    
volta_main:
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra
