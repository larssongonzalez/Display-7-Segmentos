//******************************************************************
//Universidad del Valle de Guatemala
// IE2023: Programación de micrcontroladores
// display7segmentos.asm
// Autor : Larsson González
// Proyecto: Ejemplos
// Hardware: ATMega328P 
// Created: 2/2/2024 17:13:52
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
//TABLA7SEG: .DB 0x7F, 0x4B, 0x3F, 0x5F, 0x4B, 0x57, 0x77, 0x4F, 0x7F, 0x4F, 0x6F, 0x73, 0x37, 0x7B, 0x37, 0x27

//******************************************************************
// CONFIGURACION DE PUERTOS DE I/O
//******************************************************************
/*LDI r23, 0xFF   ; Configurar todos los bits del puerto B como salida
OUT DDRC, r23   ; Escribir en el registro DDRB*/

;Configuro Puerto D como salidas (DISPLAY)
LDI R16, 0b11111111
OUT DDRD, R16

;Entrada en PB0, PB1 (PUSHBUTTON)
LDI R16, 0b00000011
OUT PORTB, R16	;Configura Puerto D0 como Entrada
LDI R16, 0b00000000
OUT DDRB, R16
;CBI DDRB, 0b00000000

;LDI R18, 0b00000000	//Estos tres registros se les carga 0 
;LDI R19, 0b00000000
;LDI R20, 0b00000000

LDI	R16, (1 << CLKPCE)	//Nos permite trabajar a 1M HZ
STS CLKPR, R16
LDI	R16, 0b00000011
STS CLKPR, R16

//******************************************************************
// PROGRAMA PRINCIPAL
//******************************************************************
MAIN:
	
	 ; Configurar el Timer0 para generar un retardo de aproximadamente 1s
    /*LDI r16, (1<<CS02) | (1<<CS00)   ; Configura el prescaler a 1024
    OUT TCCR0B, r16   ; Escribir en el registro TCCR0B
	CALL TIMER0		;Manda a llamar a la subrutina de TIMER0
	LDI R22, 0*/  

	LDI R20, 0
	LDI ZH, HIGH(TABLA7SEG<<1)
	LDI ZL, LOW(TABLA7SEG<<1)
	ADD ZL, R25
	LPM R25, Z
	OUT PORTD, R25


LOOP:
	//*******************************************************
	// Esta configuracion es del Timer0
	/*IN R23, TIFR0
	CPI R23, (1<<TOV0)
	BRNE LOOP

	LDI R23, 195
	OUT TCNT0, R23

	SBI TIFR0, TOV0
	INC R22
	CPI R22, 10
	BRNE LOOP*/
	//*******************************************************
	// Esta configuracion es del Display de 7 Segmentos
	;Leer los valores del puerto B
	IN R16, PINB
	
	;Verifica si el boton de incremento esta presionado
	SBRS R16, PB0
	CALL INCREMENTO1

	;Verifica si el boton de decremento esta presionado
	SBRS R16, PB1
	CALL DECREMENTO1

	;OUT PORTD, R18

	RJMP LOOP

//******************************************************************
// SUB RUTINAS
//******************************************************************
// Configuracion de Subrutinas del Display de 7 Segmentos
/*INCREMENTO:
	CPI R21, 0X0F
	BREQ RESET
	INC R21

ENCELUD:
	OUT PORTC, R21
	RJMP LOOP

TIMER0:
	LDI R23, (1<<CS02) | (1<<CS00)
	OUT TCCR0B, R23

	LDI R23, 195
	OUT TCNT0, R23

	RET

RESET:
	CLR R21
	RJMP ENCELUD*/

//******************************************************************
// Configuracion de Subrutinas del Timer0

;Se configura el antirebote del push1 e incrementa el display
INCREMENTO1:
	LDI R17, 200
	;LDI R23, (1<<CS02) | (1<<CS00)
	;OUT TCCR0B, R23
	;Antirebote
	DELAY:
		DEC R17
		BRNE DELAY
	;Verifica el PB0 de nuevo
	SBIS PINB, PB0
	RJMP INCREMENTO1
	;CALL TIMER0
	INC R20 ;incrementa el registro para el push
	CALL DISPLAY  ;manda a llamar a la tabla del display para verificar el estado de la tabla y luego incrementar

	RET

;Se configura el antirebote del push2 y decrementa el display
DECREMENTO1:
	LDI R17, 200
	;LDI R23, (1<<CS02) | (1<<CS00)
	;OUT TCCR0B, R23
	;Antirebote
	DELAY2:
		DEC R17
		BRNE DELAY2
	;Verifica el PB1 de nuevo
	SBIS PINB, PB1
	RJMP DECREMENTO1
	;CALL TIMER0
	DEC R20 ;decrementa el push y al display
	CALL DISPLAY ;manda a llamar a la tabla del display para verificar el estado de la tabla y luego decrementar

	RET


;Funcion para organizar la tabla y verificar estados del registro Z
DISPLAY:
	LDI ZH, HIGH(TABLA7SEG<<1)
	LDI ZL, LOW(TABLA7SEG<<1)
	ADD ZL, R20
	LPM R25, Z
	OUT PORTD, R25

	RET
	
	

//*************************************************************************************************************
TABLA7SEG: .DB 0x7E, 0x0C, 0xB6, 0x9E, 0xCC, 0xDA, 0xFA, 0x0E, 0xFE, 0xCE, 0xEE, 0xF8, 0x72, 0xBC, 0xF2, 0xE2
//*************************************************************************************************************
