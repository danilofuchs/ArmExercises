; ex08.s - FACTORIAL
; Developed for board EK-TM4C1294XL
; Danilo Fuchs
; 22/03/2020

; Template:
; Prof. Guilherme Peron
; 12/03/2018

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