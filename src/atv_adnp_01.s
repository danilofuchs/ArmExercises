; atv_adnp_01.s - Prime numbers
; Developed for board EK-TM4C1294XL
; Danilo Fuchs
; 19/07/2020

; Template:
; Prof. Guilherme Peron
; 12/03/2018

; Contexto:
; Números primos são os números naturais que têm apenas dois divisores diferentes: o 1 e ele mesmo. Desta forma o 1 não é primo, pois ele só tem 1 divisor.
; 
; Objetivo:
; Utilizando instruções Assembly para Cortex-M4 e o simulador do Keil uVision, encontrar os números primos em uma lista de números previamente fornecida e ordená-la.
; 
; Tarefas:
; - Verificar em uma lista de números fornecida quais números são primos começando na posição da memória RAM 0x20000000;
; - Ordenar a lista de números primos encontrada do menor para o maior pelo algoritmo bubble sort começando na posição da memória RAM 0x20000100;
; 
; 
; Roteiro:
; Dada a seguinte lista de números aleatórios {193;	63; 176; 127; 43; 19; 211; 3; 203; 5; 21; 127; 206; 245; 157; 237; 241;	105; 252; 19}, encontrar quais números são primos e fornecer uma lista com os números primos ordenados ao final utilizando o algoritmo de bubble sort. Entregar a pasta do projeto do Keil com todos os arquivos zipado e o fluxograma da ideia proposta também dentro da pasta (preferencialmente em algum site ou aplicativo, e.g. http://draw.io). Nomear o arquivo com o nome e o último sobrenome dos dois alunos da dupla. Ex.: fulanodetal1_fulanodetal2_ap1.zip
;   
; Declarar antes do label start um “EQU” para definir a posição base da memória RAM para a lista de números aleatórios e uma posição base da memória para a lista a ser ordenada (nome EQU 0x20000000 e nome EQU 0x20000100).
; Carregar de forma automatizada a lista de números aleatória para a memória RAM a partir da posição 0x20000000 utilizando o STRB e endereçamento indexado (pós-indexado);
; Fazer uma varredura da lista de números aleatórios para encontrar quais números são primos e quando o número for primo escrevê-lo na memória RAM a partir da posição 0x20000100, formando ainda uma lista desordenada, guardando em um registrador o tamanho da lista sendo formada.
; Depois que a lista for formada, ordená-la utilizando o algoritmo bubble sort (https://www.embarcados.com.br/algoritmos-de-ordenacao-bubble-sort/)
; Ao final do código a lista de números primos deve estar ordenada a partir da posição 0x20000100.



; -------------------------------------------------------------------------------
        THUMB
; -------------------------------------------------------------------------------
; CONSTANTS
RAM_INITIAL_ADDR EQU 0x20000000
UNORDERED_PRIME_NUMBERS EQU 0x20000100

; -------------------------------------------------------------------------------

		AREA  DATA, ALIGN=2

; -------------------------------------------------------------------------------

        AREA    |.text|, CODE, READONLY, ALIGN=2

        EXPORT PrimeNumbersList
; ------------------------------------------------------------------------------
PrimeNumbersList
; Start Here <======================================================
    ; R0 = Next memory address to get numbers
    ; R1 = Prime numbers count (count)
    ; R2 = Current number under test (num)
    ; R3 = Divider testing R3's divisibility (div)
    ; R4 = Current address of number under test
    ; R5 = Next memory address to save numbers
	mov R0, #RAM_INITIAL_ADDR
    mov R1, #0
    mov R3, #2
    ldr R4, =NUMBERS_ARRAY
    ldr R5, =UNORDERED_PRIME_NUMBERS

    bl loadNumbersList

    mov R0, #RAM_INITIAL_ADDR
    ldrb R2, [R0], #1

    bl checkIfBelowMaxAndPrime

    ldr R4, =UNORDERED_PRIME_NUMBERS
    bl bubbleSort

    b endProgram
    
endProgram
    b endProgram

loadNumbersList
    ldrb R2, [R4], #1 ; Read from ROM
    strb R2, [R0], #1 ; Save to array in memory
    cmp R2, #0 ; Checks for end-of-array byte
    bne loadNumbersList ; Continue searching
    bxeq LR ; Return to initial step if found 0

checkIfBelowMaxAndPrime
    cmp R2, #0
    bne checkIfPrime ; num != 0 -> check
    bxeq LR  ; num == 0  -> end

checkIfPrime
    cmp R2, R3
    beq saveInRamAndRestartCheck ; num == div -> is prime!
    bne checkIfDivisible         ; num != div -> needs to check if divisible

saveInRamAndRestartCheck
    strb R2, [R5], #1  ; saves num into address R5 and increments to next one
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
    ldrb R2, [R0], #1  ; R2 = *(R0++)
    mov R3, #2  ; R3 = 2
    b checkIfBelowMaxAndPrime

bubbleSort
    ldrb R6, [R4], #1 ; Load R4 into memory
    ldrb R7, [R4]     ; Load next value

    cmp R7, #0 ; Go back if end of array
    bxeq LR

    cmp R6, R7
    push {LR} ; We need to save LR to go back at the end
    blhi invertPositions ; If R6 > R7, should invert
    pop {LR}

    b bubbleSort

invertPositions
    mov R8, R6 ; Save to temporary reg
    mov R6, R7
    mov R7, R8

    strb R6, [R4, #-1] ; Save new R6 into *(R4 - 1)
    strb R7, [R4]      ; Save new R7 into *(R4)

    bx LR

NUMBERS_ARRAY DCB 0xC1,0x40,0xB0,0x7F,0x2B,0x13,0xD3,0x03,0xCB,0x05,0x15,0x7F,0xCE,0xF5,0x9D,0xED,0xF1,0x69,0xFC,0x13,0
;                  193;	 63; 176; 127;  43;  19; 211;   3; 203;   5;  21; 127; 206; 245; 157; 237; 241;	105; 252;  19, \0
;         Ordered: 3, 5, 19, 19, 21, 43, 64, 105, 127, 127, 157, 176, 193, 203, 206, 211, 237, 241, 245, 252
;     Ordered hex: ["3", "5", "13", "13", "15", "2b", "40", "69", "7f", "7f", "9d", "b0", "c1", "cb", "ce", "d3", "ed", "f1", "f5", "fc"]
    align
    end