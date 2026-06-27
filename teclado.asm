.data
	mostrador_esq: .word 0xFFFF0011 # endereço do mostrador da esquerda
    	mostrador_dir: .word 0xFFFF0010 # endereço do mostrador da direita
.text
.globl configura_mostrador_atuadores # torna a função visível a outros arquivos

	configura_mostrador_atuadores:
			lw $t0, mostrador_esq # carrega o endereço do mostrador da esquerda
    			sb $a0, 0($t0) # armazena o parâmetro em $a0 na memória do mostrador
    			jr $ra # retorna ao chamador
	
	