//******************************************************************
//Universidad del Valle de Guatemala
// IE2023: Programación de micrcontroladores
// Display7.asm
// Autor : Larsson González
// Proyecto: Ejemplos
// Hardware: ATMega328P 
// Created: 5/2/2024 14:35:10
// Última modificación: 
//******************************************************************
// CONFIGURACION GENERAL
//******************************************************************
.include "M328PDEF.inc"
.CSEG
.ORG 0x0000

//******************************************************************
// STACK POINTER
//******************************************************************
LDI R16, LOW(RAMEND)
OUT SPL, R16
LDI R17, HIGH(RAMEND)
OUT SPH, R16

//******************************************************************
// DEFINICION DE REGISTROS Y CONSTANTES
//******************************************************************


//******************************************************************
// CONFIGURACION DE PUERTOS DE I/O
//******************************************************************
LDI r16, 0xFF   ; Configurar todos los bits del puerto B como salida
OUT DDRC, r16   ; Escribir en el registro DDRB

//******************************************************************
// PROGRAMA PRINCIPAL
//******************************************************************
MAIN:
	 ; Configurar el Timer0 para generar un retardo de aproximadamente 1s
    LDI r16, (1<<CS02) | (1<<CS00)   ; Configura el prescaler a 1024
    OUT TCCR0B, r16   ; Escribir en el registro TCCR0B
	CALL TIMER0		;Manda a llamar a la subrutina de TIMER0
	LDI R20, 0   

    

LOOP:
    IN R16, TIFR0
	CPI R16, (1<<TOV0)
	BRNE LOOP

	LDI R16, 195
	OUT TCNT0, R16

	SBI TIFR0, TOV0
	INC R20
	CPI R20, 10
	BRNE LOOP
//******************************************************************
// SUB RUTINAS
//******************************************************************
INCREMENTO:
	CPI R21, 0X0F
	BREQ RESET
	INC R21

ENCELUD:
	OUT PORTC, R21
	RJMP LOOP

TIMER0:
	LDI R16, (1<<CS02) | (1<<CS00)
	OUT TCCR0B, R16

	LDI R16, 195
	OUT TCNT0, R16

	RET

RESET:
	CLR R21
	RJMP ENCELUD


