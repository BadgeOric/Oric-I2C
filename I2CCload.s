;;;==================================================================
;;;		I2CCload - Oric Wifi Loader in Combo with Socket Client
;;;==================================================================


RxBuffL		=	$00		; receive buffer pointer low byte	- ZP location change as required
RxBuffH		=	$01		; receive buffer pointer high byte	ZP location change as required
TxBuffL		=	RxBuffL		
TxBuffH		=	RxBuffH
ByteBuff	=	$02		; byte buffer for Tx/Rx routines	ZP location change as required
I2cCountL	=	$03		; Tx/Rx byte count low byte			ZP location change as required
I2cCountH	=	$04		; Tx/Rx byte count high byte		ZP location change as required
RWFlag		= 	$05
DATFlag		= 	$06		; If not $FF sends contents before read.
DevAddress	=	$07		; main device address
DevReadAdd	=	$08		; some devices have a 2nd address for read/write ops
DelayFlag	=	$09		; Set to 1 to have a delay after each sent byte (LCDs Need this).. 
ByteCountL	=	$0a
ByteCountH	=	$0b

I2CPort		=	$301		; 6522 Via Output Register Port A	(change to suit system)
ViaDDRA		=	I2CPort+2	; 6522 Via Data Direction Register Port A
ViaPCR		= 	I2CPort+12	; Preipeheral Control Register to Diable AY chip
SDA	=	%00000001	;SDA is 1st byte of Port A of 6522 (pin 2 of chip)
CLK	=	%00000010	;CLK is 2nd byte of Port A	of 6522 (pin3 of chip)

;;; For an Oric Computer the following would be needed :-
;;;	A cable that connected pin 3 , 5 and 4 of the printer port
;;; These are as you look at the back of the Oric the 2nd and 3rd pins of the bottom row
;;; And Any of the top row that you like (they are all ground)
;;; Pin 3 is the SDA line
;;; Pin 5 is the ClK line
;;; Pin 4 is a GND line
;;; You could take +5v from pin 33 of the expansion port (bottom far right looking from back)
;;;
;;; The Oric Via is mapped at #300-#30F so for this the I2CPort should be set at #301
;;; 


auto
	lda #<Init			;; Load $2f5/6 with jump vector for "!" extension command
	sta $2f5
	lda #>Init			
	sta $2f6
	rts


Init					;; this is where the above jump vecotr points to.
	SEI					;; Typing a ! will run this routine.
	lda #$FF			;; Setup 6522 Via
	sta ViaDDRA
	sta I2CPort
	nop
	nop
	jsr StopI2c			;; Ensure I2C is in known condition
	lda #4
	sta I2cCountL
	lda #0
	sta I2cCountH		;; limit to 255 bytes send/receive at the moment
Getheader				;; set up i2c transfer to load 12 bytes from
	lda #0				;;module and store in $400
	sta RxBuffL			;; this is the "new" header as sent by the Socket_Client
	sta I2cCountH
	sta DATFlag
	sta DelayFlag
	sta ByteCountH
	lda #1
	sta RWFlag
	lda #12
	sta ByteCountL
	lda #4
	sta I2cCountL
	sta $7
	sta $8
	lda #$04
	sta RxBuffH	
headerloop				;; get the 12 bytes and store in $400
	jsr GetData			
	lda #4
	sta I2cCountL
	clc 
	lda RxBuffL
	adc I2cCountL
	sta RxBuffL
	lda RxBuffH
	adc #0
	sta RxBuffH
	sec
	lda ByteCountL
	sbc I2cCountL
	sta ByteCountL
	lda ByteCountH
	sbc	#0
	sta ByteCountH
	lda ByteCountL
	bne headerloop
	lda ByteCountH
	BNE	headerloop		; loop if not all done
	ldx #0
transloop				; transfer the 12 bytes from $400
	lda $400,x			;to $00
	sta $0,x
	inx
	cpx #12
	bne transloop
basicend
	clc
	lda $0
	adc $0A
	sta $9C
	sta $9e
	lda $01
	adc $0B
	sta $9D
	sta $9f
ByteLoop				; now get the data based on the 12 bytes header.
	jsr GetData
	lda #4
	sta I2cCountL
	clc 
	lda RxBuffL
	adc I2cCountL
	sta RxBuffL
	lda RxBuffH
	adc #0
	sta RxBuffH
	sec
	lda ByteCountL
	sbc I2cCountL
	sta ByteCountL
	lda ByteCountH
	sbc	#0
	sta ByteCountH
	lda ByteCountL
	bne ByteLoop
	lda ByteCountH
	BNE	ByteLoop		; loop if not all done
	CLI
	rts



GetData
	lda RWFlag				; test for read or write needed (0 is write, 1 = read)
	bne RcvRoutine
	jsr SendAddr			; send address to activate device (starts in write mode)
	jsr SendData
	jmp EndofGetorSend
RcvRoutine
	lda DATFlag
	beq skipcommand
	jsr SendAddr
	lda DATFlag
	jsr ByteOut
skipcommand
	jsr SndReadAdd
	jsr ReadData
EndofGetorSend
	jsr StopI2c				;stop i2c
	rts						;return to monitor/basic/calling routine
	

SendAddr
	LDA	I2CPort			; get i2c port state
	nop
	nop
	ORA	#$01			; release data
	STA	I2CPort			; out to i2c port
	nop
	nop
	LDA	#$03			; release clock
	STA	I2CPort			; out to i2c port
	nop
	nop
	LDA	#$01			; set for data test
WaitAD
	BIT	I2CPort			; test the clock line
	BEQ	WaitAD			; wait for the data to rise
	LDA	#$02			; set for clock test
WaitAC
	BIT	I2CPort			; test the clock line
	BEQ	WaitAC			; wait for the clock to rise
	JSR	StartI2c		; generate start condition
	LDA	DevAddress
	ROL					; get address (including read/write bit)
	JSR	ByteOut			; send address byte
	BCS	StopI2c			; branch if no ack
	RTS					; else exit

SndReadAdd
	LDA	I2CPort			; get i2c port state
	ORA	#$01			; release data
	STA	I2CPort			; out to i2c port
	nop
	nop
	LDA	#$03			; release clock
	STA	I2CPort		; out to i2c port
	nop
	nop
	LDA	#$01			; set for data test
WaitADr
	BIT	I2CPort		; test the clock line
	BEQ	WaitADr			; wait for the data to rise
	LDA	#$02			; set for clock test
WaitACr
	BIT	I2CPort		; test the clock line
	BEQ	WaitACr			; wait for the clock to rise
	JSR	StartI2c		; generate start condition
	LDA	DevReadAdd		; get address (including read/write bit)
	ROL
	ORA #1					
	JSR	ByteOut			; send address byte
	BCS	StopI2c			; branch if no ack
	RTS				; else exit

SendData
	JSR	StartI2c
	LDY	#$00			; set index to zero
WriteLoop
	LDA	(RxBuffL),Y 	; get byte from buffer
	JSR	ByteOut			; send byte to device
	BCS	StopI2c			; branch if no ack
	lda DelayFlag
	bne Skipdelay		;check delay flag is delay is needed (1 set)
	jsr	SpinWheels
Skipdelay
	INY				; increment index
	BNE	NoHiWrInc		; branch if no rollover
	INC	RxBuffH			; else increment pointer high byte
NoHiWrInc
	DEC	I2cCountL		; decrement count low byte
	lda I2cCountL
	BNE	WriteLoop		; loop if not all done
	RTS

StopI2c
	LDA	#$00			; now hold the data down
	STA	I2CPort			; out to i2c port
	nop
	nop					; need this if running >1.9MHz
	LDA	#$02			; release the clock
	STA	I2CPort			; out to i2c port
	nop
	nop					; need this if running >1.9MHz
	LDA	#$03			; now release the data (stop)
	STA	I2CPort			; out to i2c port
	nop
	nop
	RTS


StartI2c
	STA	I2CPort			; out to i2c port
	nop				; need this if running >1.9MHz
	nop
	LDA	#$00			; clock low, data low
	STA	I2CPort			; out to i2c port
	nop
	nop
	RTS

ReadData
    LDY #$00            ; set index to zero
ReadLoop
    JSR ByteIn          ; get byte from device
    LDA I2cCountL       ; get count low byte
    CMP #$01            ; compare with end count + 1
    SBC #$00            ; subtract carry, leaves Cb = 0 for last byte
 	JSR DoAck2           ; send ack bit
    LDA ByteBuff        ; get byte from byte buffer
    STA (TxBuffL),Y     ; save in device buffer
    INY             ; increment index
	dec I2cCountL
    LDA I2cCountL       ; get count low byte
    BNE ReadLoop        ; loop if not all done
    RTS
	
		
	
ByteOut
	STA	ByteBuff		; save byte for transmit
	LDX	#$08			; 8 bits to do
OutLoop
	LDA	#$00			; unshifted clock low
	ROL	ByteBuff		; bit into carry
	ROL					; get data from carry
	STA	I2CPort			; out to i2c port
	nop		; need this if running >1.9MHz
	nop
	ORA	#$02			; clock line high
	STA	I2CPort			; out to i2c port
	nop
	nop
	LDA	#$02			; set for clock test
WaitT1
	BIT	I2CPort			; test the clock line
	BEQ	WaitT1			; wait for the clock to rise
	LDA	I2CPort			; get data bit
	AND	#$01			; set clock low
	STA	I2CPort			; out to i2c port
	nop
	nop
	DEX					; decrement count
	BNE	OutLoop			; branch if not all done


;
; clock is low, data needs to be released, then the clock needs to be released then
; we need to wait for the clock to rise and get the ack bit.

GetAck
	LDA	#$01			; float data
	STA	I2CPort			; out to i2c port
	nop
	nop
	LDA	#$03			; float clock, float data
	STA	I2CPort			; out to i2c port
	nop
	nop
	LDA	#$02			; set for clock test
WaitGA
	BIT	I2CPort			; test the clock line
	BEQ	WaitGA			; wait for the clock to rise
	nop
	LDA	I2CPort			; get data
	LSR					; data bit to Cb
	nop
	LDA	#$01			; clock low, data released
	STA	I2CPort			; out to i2c port
	nop
	nop
	RTS



; input byte from 12c bus, byte is returned in A. entry should be with the clock low
; after generating a start or a previously sent byte
; exits with clock held low

ByteIn
	lda #0
	sta ByteBuff
	LDX	#$08			; 8 bits to do
	LDA	#$01			; release data
	STA	I2CPort			; out to i2c port
	nop
	nop
InLoop
	LDA	#$03			; release clock
	STA	I2CPort			; out to i2c port
	nop
	nop
	LDA	#$02			; set for clock test
WaitR1
	BIT	I2CPort			; test the clock line
	BEQ	WaitR1			; wait for the clock to rise
	nop
	nop
	LDA	I2CPort			; get data
	ROR					; bit into carry
	ROL	ByteBuff		; bit into buffer
	
	LDA	#$01			; set clock low
	STA	I2CPort			; out to i2c port
	nop
	nop
	DEX					; decrement count
	BNE	InLoop			; branch if not all done
	RTS


;;; Send Ack to tell device to increment register and send next byte

DoAck2
	LDA #0
	STA I2CPort
	nop
	nop
	LDA #2
	STA I2CPort
	nop
	nop
	LDA #0
	STA I2CPort
	nop
	nop
	RTS


;;; I2C protocol states after all bytes received a "NACK" should be send before a stop
;;; Doesnt seem to send correctly but device works as expected on multiple runs. 

DoNack
	LDA #1
	STA I2CPort
	nop
	nop
	LDA #3
	STA I2CPort
	nop
	nop
	LDA #1
	STA I2CPort
	nop
	nop
	RTS



;;; Delay routine - sometimes needed on sending data. Depends on device.
;;; LCD displays need delays between commands and data before next byte is sent.
SpinWheels
	pha
	lda #255
	sec
spin
	sbc #1
	bne spin
	pla
	rts

SpinWheels2
	pha
	lda #100
	sec
spin2
	sbc #1
	bne spin2
	pla
	rts