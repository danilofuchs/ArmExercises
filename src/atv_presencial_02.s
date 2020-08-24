; atv_presencial_02.s - Prime numbers
; Developed for board EK-TM4C1294XL
; Danilo Fuchs
; 22/03/2020

; Template:
; Prof. Guilherme Peron
; 12/03/2018

; Objetivo:
; Números primos são os números naturais que têm apenas dois divisores diferentes: o 1 e ele mesmo.
; Desta forma o 1 não é primo, pois ele só tem 1 divisor.
; Utilizando instruções Assembly para Cortex-M4 e o simulador do Keil uVision, encontrar um vetor
; e colocar na memória RAM a partir do endereço 0x20000000 os primeiros números primos de 0 a 255 (0 a 0xFF). 
; 
; Roteiro:
; - Fazer um fluxograma da ideia proposta. (Preferencialmente em algum site ou aplicativo, e.g. http://draw.io) e o código.
; - Declarar antes do label start um “EQU” para definir a posição base da memória RAM (nome EQU 0x20000000).
; - Utilizar um registrador para armazenar a posição da memória RAM atual que será gravado o próximo número primo. Ao gravar na memória RAM, utilizar o modo pós-fixado, que após gravar incrementa o registrador;
; - Utilizar o comando de gravar na memória RAM em bytes;
; - Utilizar um registrador para guardar o tamanho do vetor para ao final da execução do código saber quantos números foram colocados na memória;
; - Utilizar um registrador para fazer a varredura dos números, começando em 2 e indo até 255 (0xFF);
; - Utilizar um registrador para iterar de 2 até o número atual para verificar se o número tem algum divisor intermediário, fazendo-o número não primo;
; - Não existe operação de resto de divisão em Assembly Cortex-M4. Neste caso, deve-se utilizar duas operações UDIV e MLS. Com UDIV calcula-se o divisor de um número. Sabendo-se o divisor, realiza-se a operação MLS (MLS Rd, Rm, Rs, Rn  -->   Rd = Rn - Rm*Rs)
; - Caso o número atual seja primo, coloque-o imediatamente na memória RAM; Caso contrário não o coloque na memória RAM;
; - Incrementa-se o Registrador que faz a varredura dos números até chegar em 255.


; -------------------------------------------------------------------------------
        THUMB
; -------------------------------------------------------------------------------
; CONSTANTS
RAM_INITIAL_ADDR EQU 0x20000000
; -------------------------------------------------------------------------------

		AREA  DATA, ALIGN=2


; -------------------------------------------------------------------------------

        AREA    |.text|, CODE, READONLY, ALIGN=2

        EXPORT PrimeNumbers
; ------------------------------------------------------------------------------
PrimeNumbers
; Start Here <======================================================
    ; R0 = Next memory address to save numbers
    ; R1 = Prime numbers count (count)
    ; R2 = Current number under test (num)
    ; R3 = Divider testing R3's divisibility (div)
	mov R0, #RAM_INITIAL_ADDR
    mov R1, #0
    mov R2, #2
    mov R3, #2

    b checkIfBelowMaxAndPrime
    
endProgram 
    b endProgram

checkIfBelowMaxAndPrime
    cmp R2, #255
    blo checkIfPrime ; num < 255  -> check
    blhs endProgram  ; num >= 255 -> end

checkIfPrime
    cmp R2, R3
    beq saveInRamAndRestartCheck ; num == div -> is prime!
    bne checkIfDivisible         ; num != div -> needs to check if divisible

saveInRamAndRestartCheck
    str R2, [R0], #1  ; saves num into address R0 and increments to next one
    add R1, #1        ; Increment array size
    b restartCheck

checkIfDivisible
    ; R4 = R3 % R2 ; mod = num % div
    udiv R4, R2, R3    ; R4 = R2 / R3 (quotient)
    mls R4, R4, R3, R2 ; R4 = R2 - R4 * R3 (remainder)

    cmp R4, #0
    beq restartCheck         ; num % div == 0 (is divisible! not prime)
    bne incrementDivAndCheck ; num % div != 0 (is not divisible! check next div)

incrementDivAndCheck
    add R3, #1     ; R3 % R2 == 0 (is divisible! not prime)
    b checkIfPrime

restartCheck
    add R2, #1  ; R2 = R2 + 1
    mov R3, #2  ; R3 = 2
    b checkIfBelowMaxAndPrime

    align
    end