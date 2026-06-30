.text
.globl logica_atuadores

# lógica dos atuadores (mostrador esquerdo):

logica_atuadores: # começa sempre verificando a temperatura e segue checando os demais
	addi $sp, $sp, -4
	sw $ra, 0($sp)
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
    beq $s3, $s4, volta_main # "cache" -> Se o mostrador já tem esse valor, pula para não piscar!
    move $s4, $s3 # salva o novo valor no "cache"
    
    move $a0, $s3 # coloca os bits corretos em $a0 ANTES de chamar a função
    jal atualiza_atuadores # chama mostrador.asm para acender as barras
    
    
volta_main:
	lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra