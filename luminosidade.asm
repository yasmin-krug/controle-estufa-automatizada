.data
	# variável local para armazenar o estado do sensor de calor
	# 0 -> temperatura ideal (cooler desligado)
	# 1 -> calor crítico (cooler ligado)
	estado_luz: .word 0

.text
.globl altera_estado_luz
.globl get_estado_luz

# alternância de temperatura -> inverte o estado do sensor
altera_estado_luz:
    	lw $t0, estado_luz # carrega o estado atual do calor para $t0
    
    	xori $t0, $t0, 1 # a instrução xori com o número 1 inverte o bit       
    
    	sw $t0, estado_luz # salva o novo estado invertido de volta na memória
    	jr $ra # retorna ao chamador (main.asm)

# get_estado_calor -> informa qual é o estado do sensor e retorna se é ideal (0) ou crítico (1)
get_estado_luz:
    	lw $v0, estado_luz # carrega o estado no $v0 (retorno)
    	jr $ra # retorna ao chamador (main.asm)
