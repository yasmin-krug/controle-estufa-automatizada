.text
.globl main

main:
	jal inicializa_tempo

main_loop:
	jal atualiza_tempo
    	# checagem de sensor e logica dos atuadores:
	jal processa_teclado    
    	jal logica_atuadores # nenhuma tecla pressionada -> pula para atualizar displays
	jal logica_diagnostico
	j main_loop

