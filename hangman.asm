.data
palavra: .asciiz "banana"
input: .space 32
resultado: .space 32
# caracteres auxiliares
barra_n: .asciiz "\n"
# strings auxiliares
numero_acertos: .asciiz "\nnumero de acertos: "
numero_erros: .asciiz "\nnumero de erros: "
ganhou_str: .asciiz "Voce ganhou\n"
perdeu_str: .asciiz "Voce perdeu\n"
palavra_aux: .asciiz "A palavra era "
letra_rep: .asciiz "Letra nao pode ser repetida"
insira_letra: .asciiz "Digite a letra: "

.text
#=====================
# configuracao inicial
#=====================
# carrega enderecos das palavras nos registradores
la $s0, palavra
la $s1, input
la $s2, resultado
la $s3, barra_n
la $s4, numero_acertos
la $s5, numero_erros
la $s7, insira_letra
# carrega a posicao de input em t0
or $t0, $s1, $zero
# carrega a posicao da palavra em t1
or $t1, $s0, $zero
# carrega a posicao de resultado em t5
or $t5, $s2, $zero
# registrador auxiliar para carregar espaco em asccii
ori $t2, $zero, 32
# inicializa em 0 contadores
# t8 armazena numero de acertos
or $t8, $zero, $zero
# t9 armazena numero de erros
or $t9, $zero, $zero


#===============================
# determina o tamanho da palavra
#===============================
# inicializa o contador em 0
li $s6, 0
# carrega o caractere
lenght:
lbu $t3, 0($t1)
# testa se eh null
beq $t3, $zero, fim_lenght
# se nao for, add +1 ao contador
addi $s6, $s6, 1
# vai para o proximo caractere
addi $t1, $t1, 1
#volta para o inicio do loop
j lenght
# t1 volta a apontar pro incio da string
fim_lenght:
or $t1, $zero, $s0


#===========================
# cria a string do resultado
#===========================
# carrega underline nos registradores
ori $t3, $zero, 95
#inicializa o contador em 0
or $t4, $zero, $zero
loop_resultado:
# coloca underline na string
sb $t3, 0($t5)
# vai para proxima posicao
addi $t5, $t5, 1
# coloca o espaco na string
sb $t2, 0($t5)
# vai para proxima posicao
addi $t5, $t5, 1
# adiciona +1 ao contador
addi $t4, $t4, 1
# testa se o contador eh igual ao tamanho da palavra
beq $t4, $s6, fim_loop_resultado
# senao for, volta pro inicio do loop
j loop_resultado
# se for, faz o t5 apontar de novo pro incio da string
fim_loop_resultado:
or $t5, $s2, $zero


jogo_inicio:
#========================
# recebe input do usuario
#========================
# carrega codigo de print para syscall
ori $v0, $zero, 4
# imprime a mensagem
or $a0, $zero, $s7
syscall
# carrega codigo de input para syscall
ori $v0, $zero, 8
# carrega argumentos
or $a0, $zero, $t0
ori $a1, $zero, 2
syscall


#=================================
# testa se a letra ja foi inserida
#=================================
# recebe o endereco do input para percorre-lo
or $t6, $zero, $s1
# carrega o ultimo input
lbu $t3, 0($t0)
loop_input:
# testa se o endereco nao eh igual ao do proprio input
beq $t6, $t0, end_igual
# carrega caractere do input
lbu $t7, 0($t6)
# compara caractere com input
beq $t3, $t7, input_repetido
j input_nao_repetido
# se for igual, eh repetido
input_repetido:
# imprime o \n
or $a0, $zero, $s3
syscall
# imprime aviso
la $t7, letra_rep
li $v0, 4 
or $a0, $zero, $t7
syscall
# pula a comparacao
j apos_compara
# se nao for repetido vai para proximo caractere do input
input_nao_repetido:
addi $t6, $t6, 2
# testa se eh null
beq $t7, $zero, fim_input
# senao repete o loop
j loop_input
fim_input: nop
end_igual: nop


#====================================
# compara string com input do usuario
#====================================
# t6 controla se houve um acerto e eh inicializado em 0
or $t6, $zero, $zero
# carrega o ultimo input
lbu $t3, 0($t0)
# carrega caractere da palavra
loop:
lbu $t4, 0($t1)
# compara caractere com input
beq $t3, $t4, char_igual_input
j char_dif_input
# se for igual resultado recebe o caractere na posicao equivalente
char_igual_input:
sb $t3, 0($t5)
# soma +1 acerto
addi $t8, $t8, 1
# sinaliza para t6 que houve um acerto
ori $t6, $zero, 1
# vai para o proximo caractere
char_dif_input:
addi $t1, $t1, 1
# resultado vai para posicao equivalente
addi $t5, $t5, 2
# se for null termina o loop
beq $t4, $zero, fim_loop
# senao volta para o loop
j loop
# retorna os valores originais
fim_loop:
or $t1, $s0, $zero
or $t5, $s2, $zero 
# testa se houve um acerto
beqz $t6, errou
j nao_errou
# se nao houve um acerto, soma +1 erro
errou:
addi $t9, $t9, 1
# continua a execucao
nao_errou: nop
apos_compara: nop


#========================
# formata string do input
#========================
# adiciona um espaco na string
addi $t0, $t0, 1
sb $t2, 0($t0)
# vai para proxima posicao de memoria
addi $t0, $t0, 1


#============================
# imprime string do resultado
#============================
# imprime o \n
li $v0,4 
or $a0, $zero, $s3
syscall
# imprime a string
or $a0, $zero, $s2
syscall


#=========================
# imprime input do usuario
#=========================
# imprime o \n
li $v0,4 
or $a0, $zero, $s3
syscall
# imprime a string
or $a0, $zero, $s1
syscall


#=============================
# imprime mensagens auxiliares
#=============================
# imprime a msg de acertos
li $v0, 4
or $a0, $zero, $s4
syscall
# imprime numero de acertos
li $v0, 1
or $a0, $zero, $t8
syscall
# imprime a msg de erros
li $v0, 4
or $a0, $zero, $s5
syscall
# imprime numero de erros
li $v0, 1
or $a0, $zero, $t9
syscall
# quebra duas linhas para proxima rodada
li $v0,4 
or $a0, $zero, $s3
syscall
or $a0, $zero, $s3
syscall


#=======================
# testa se o jogo acabou
#=======================
# testa se o numero de acertos eh igual ao tamanho da palavra
beq $t8, $s6, ganhou
# testa se o numero de erros eh igual ao numero maximo de erros
beq $t9, 6, perdeu
# senao volta para o inicio do jogo
j jogo_inicio
#se ganhou carrega mensagem de vitoria
ganhou:
la $s1, ganhou_str
j fim_jogo
#se perdeu carrega mensagem de derrota
perdeu:
la $s1, perdeu_str
fim_jogo:
# imprime a mensagem
or $a0, $zero, $s1
syscall
# carrega e imprime auxiliar da palavra
la $s1, palavra_aux
or $a0, $zero, $s1
syscall
# imprime a palavra original
or $a0, $zero, $s0
syscall
# imprime o \n
or $a0, $zero, $s3
syscall
