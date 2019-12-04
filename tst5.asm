; STANDARD HEADER FILE
	PROCESSOR		16F876A
;---REGISTER FILES 선언 ---
;  BANK 0
INDF	 EQU	00H
TMR0	 EQU	01H
PCL	 EQU	02H
STATUS	 EQU	03H
FSR	 EQU	04H	
PORTA	 EQU	05H
PORTB	 EQU	06H
PORTC	 EQU	07H
EEDATA	 EQU	08H
EEADR	 EQU	09H
PCLATH	 EQU	0AH
INTCON	 EQU	0BH
; BANK 1
OPTINOR	 EQU	81H
TRISA	 EQU	85H
TRISB	 EQU	86H
TRISC	 EQU	87H
EECON1	 EQU	88H
EECON2	 EQU	89H
ADCON1	 EQU	9FH
;---STATUS BITS 선언---
IRP	 EQU	7
RP1	 EQU	6
RP0	 EQU	5
NOT_TO 	 EQU	4
NOT_PD 	 EQU	3
ZF 	 EQU	2 ;ZERO FLAG BIT
DC 	 EQU	1 ;DIGIT CARRY/BORROW BIT
CF 	 EQU	0 ;CARRY BORROW FLAG BIT

; -- INTCON BITS 선언 --
; -- OPTION BITS 선언 --

W 	 EQU	B'0' ; W 변수를 0으로 선언
F 	 EQU	.1   ; F 변수를 1로 선언

; --USER
DISP1	 EQU 	20H
DBUF1	 EQU  	21H
DBUF2	 EQU	22H
DISP2	 EQU	23H
KEY_T	 EQU	24H
KEY_DATA	 EQU	25H

;MAIN PROGRAM
	ORG	0000
	BSF 	STATUS,RP0 ; BANK를 1로 변경함
	MOVLW	B'00001111'; RA4는 OUTPUT.. Z
	MOVWF	TRISA
	MOVLW	B'00000111'
	MOVWF	ADCON1
	MOVLW	B'00000000';
	MOVWF	TRISC	 ; PORTC OUTPUT설정
	BCF	STATUS,RP0 ; BANK를 0으로 변경

LP 	MOVLW	0FH
	MOVWF	KEY_DATA	;초기화
LP2	MOVLW	B'11110111';RC3=0 RC2,1,0=1
	MOVWF	PORTC
	CLRF	KEY_T	;SCAN위치
LP1	CALL	READ_KEY	;KEY가 눌러짐 확인
	INCF	KEY_T,F
	RRF	PORTC,F	;다음 위치 선택
	BTFSC	STATUS,CF	;마지막 위치 확인
	GOTO	LP1 ;마지막 위치 --> KEY 값에 따라서 주어진 일하기
	MOVF	KEY_DATA,W
	SUBLW	78H	;'78'이 동시에 눌려졌는지 확인
	BTFSS	STATUS,ZF
	GOTO	LP3
;특정시간 동안 소리내기
	BSF	PORTA,4 ; BUZZER ON
	CALL 	DELAY
LP3	BCF	PORTA,4
	GOTO 	LP ;	초기화
;스위치가 눌러짐을 확인
READ_KEY
	MOVF	PORTA,W;스위치 읽기
	ANDLW	B'00000111'
	SUBLW	B'00000111'
	BTFSC	STATUS,ZF ;KEY 눌러짐 확인
	RETURN		;KEY 눌러지지 않으면 그냥 리턴
	;KEY 값을 얻기 위한 TABLE ADDRESS 만듦
	MOVF	PORTA,W
	MOVWF	KEY_DATA
	RLF	KEY_DATA,F
	RLF	KEY_DATA,W
	ANDLW	B'00011100'
	IORWF	KEY_T,W
	;ANDLW	B'00011111'
	CALL	KEY_TABLE
	MOVWF	KEY_DATA ;들어온 스위치 값
	RETURN
		
; SUBROUTINE
; KEY 값을 저장하는 TABLE -- 32개임
KEY_TABLE	
	ADDWF	PCL,F
	RETLW 	0FH ; '000'+'00'일때
	RETLW 	0FH ; '000'+'01'일때
	RETLW 	0FH ; '000'+'10'일때
	RETLW 	0FH ; '000'+'11'일때
	RETLW 	0FH ; '001'+'00'일때
	RETLW 	0FH ; '001'+'01'일때
	RETLW 	78H ; '001'+'10'일때 -- '7','8'이 동시에 눌려진 상태
	RETLW 	0FH ; '001'+'11'일때
	RETLW 	0FH ; '010'+'00'일때
	RETLW 	0FH ; '010'+'01'일때
	RETLW 	0FH ; '010'+'10'일때
	RETLW 	0FH ; '010'+'11'일때
	RETLW 	01H ; '011'+'00'일때
	RETLW 	04H ; '011'+'01'일때
	RETLW 	07H ; '011'+'10'일때
	RETLW 	10H ; '011'+'11'일때 -- '*' CODE
	
	RETLW 	0FH ; '100'+'00'일때
	RETLW 	0FH ; '100'+'01'일때
	RETLW 	0FH ; '100'+'10'일때 
	RETLW 	0FH ; '100'+'11'일때
	RETLW 	02H ; '101'+'00'일때
	RETLW 	05H ; '101'+'01'일때
	RETLW 	08H ; '101'+'10'일때
	RETLW 	00H ; '101'+'11'일때
 	RETLW 	03H ; '110'+'00'일때
 	RETLW 	06H ; '110'+'01'일때
 	RETLW 	09H ; '110'+'10'일때
 	RETLW 	11H ; '110'+'11'일때 -- '#'CODE
 	RETLW 	0FH ; '110'+'00'일때
 	RETLW 	0FH ; '110'+'01'일때
 	RETLW 	0FH ; '110'+'10'일때
 	RETLW 	0FH ; '110'+'11'일때
; SUBROUTINE
DELAY		
	MOVLW	.250
	MOVWF	DBUF1	 ; 250번을 확인하기 위한 변수
LOOP1	MOVLW	.250
	MOVWF	DBUF2	 ; 250번을 확인하기 위한 변수
LOOP2	NOP
	DECFSZ	DBUF2,F
	GOTO	LOOP2
	DECFSZ	DBUF1,F	 ; 변수를 감소시켜 00이 되었나 확인
	GOTO	LOOP1	 ; ZERO가 아니면 여기에 들어옴
	RETURN	
	
	
END