.data
	# endereços de memória dos displays no simulador
	end_mostrador_esq: .word 0xFFFF0011  # atuadores (barrinhas)
	end_mostrador_dir: .word 0xFFFF0010  # diagnóstico (letras)

.text
.globl atualiza_atuadores
.globl atualiza_diagnostico

# atualização dos atuadores -> recebe como parâmetro o byte mapeado pra acender (ex: 0x01 = cooler)
atualiza_atuadores:
    lw $t0, end_mostrador_esq # carrega o endereço do mostrador esquerdo
    sb $a0, 0($t0) # escreve o byte passado pelo main.asm
    jr $ra # retorna para main.asm

# atualização do diagnóstico -> recebe como parâmetro o caractere em ASCII/Hexadecimal 
atualiza_diagnostico:
    lw $t0, end_mostrador_dir # carrega o endereço do mostrador direito
    
    # se o param $a0 for 0, o main.asm quer apagar o mostrador
    beq $a0, 0, apaga_display

    # mapeamento de'C' (segmentos A, D, E, F) -> 0x39
    beq $a0, 'C', print_c
    
    # mapeamento de 'U' (segmentos B, C, D, E, F) -> 0x3E
    beq $a0, 'U', print_u
    
    # mapeamento de 'L' (segmentos D, E, F) -> 0x38
    beq $a0, 'L', print_l

apaga_display:
    addi $t1, $0, 0x00 # 0x00 apaga todos os segmentos
    sb $t1, 0($t0) # armazena o valor 0x00 no endereço do mostrador da direita
    jr $ra # retorna ao chamador

print_c:
    addi $t1, $0, 0x39 # código hexa para formar 'C'
    sb $t1, 0($t0) # armazena o valor 0x39 no endereço do mostrador da direita
    jr $ra # retorna ao chamador

print_u:
    addi $t1, $0, 0x3E # código hexa para formar 'U'
    sb $t1, 0($t0) # armazena o valor 0x3E no endereço do mostrador da direita
    jr $ra # retorna ao chamador

print_l:
    addi $t1, $0, 0x38 # código hexa para formar 'L'
    sb $t1, 0($t0) # armazena o valor 0x38 no endereço do mostrador da direita
    jr $ra # retorna ao chamador