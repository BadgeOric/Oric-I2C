5 BTT=4 :MEM=#6000 :IR=4:IS=4
10 REM Simple Receiver of characters over I2C
15 CLS : PRINT "Setting up assembly"
20 GOSUB 5000
100 REM SETUP ZP VARIABLES FOR I2C MODULE
110 POKE 7,IS:REM ADDRESS IF I2C SLAVE (SET TO #4 IN ARDUINO CODE -CAN BE CHANGED)
120 POKE 8,IR:REM ADDRESS OF I2C SLAVE FOR READ EVENTS (CAN BE SAME AS IN #7 OR DIFFERENT DEPENDING ON DEVICE)
130 POKE 9,0:REM DELAY FLAG BETWEEN SENDING BYTES - 0 = NO DELAY.
150 TEXT:CLS
160 PRINT "Press R to Receive or S to Send"
170 A$=KEY$
180 IF A$="" THEN GOTO 170
190 IF A$="S" THEN GOTO 1000
200 IF A$<>"R" THEN GOTO 210
210 PRINT "HIRES (H) OR TEXT (T)";T$
220 A$=KEY$
240 IF A$="H" THEN MEM=#A000:HIRES:ST=1:GOTO 270
250 IF A$="T" THEN MEM=#6000:ST=0:GOTO 270
260 GOTO 220
270 INPUT "No of Bytes to receive:";BR$
280 LS=VAL(BR$)
290 CLS:PRINT "Working!"
300 FOR I=0 TO LS STEP BTT
310 DOKE 0,MEM+I
320 POKE 3,BTT:POKE 4,0:POKE 5,1:POKE 6,BTT
330 CALL #4000
340 WAIT 2
350 NEXT I
360 IF ST=0 THEN GOSUB 500
380 GOSUB 2000
390 TEXT
400 GOTO 150
500 TEXT:CLS
510 M1=#6000:M2=#BB82+40:COUNT=0:CT=0
520 FOR I=0 TO LS
530 IF PEEK(M1)<32ORPEEK(M1)>127THENM2=M2-1:CT=CT-1:COUNT=COUNT-1:GOTO 550
540 POKE M2,PEEK(M1)
550 M1=M1+1 : CT=CT+1
560 COUNT=COUNT+1
570 IF COUNT=38 THEN M2=M2+2:COUNT=0
580 M2=M2+1
590 NEXT I
600 RETURN
700 HIRES
710 M1=#6000:M2=#A000
720 FOR I=0TOLS
730 POKE M2,PEEK(M1)
740 M1=M1+1
750 M2=M2+1
760 NEXT I
770 RETURN
1000 CLS
1010 PRINT"Send String(S) or Memory(M)"
1020 A$=KEY$
1030 IF A$="S" THEN GOTO 1100
1040 IF A$="M" THEN GOTO 1500
1050 GOTO 1020
1100 CLS
1110 INPUT "Input Text to Send:";TS$
1120 DOKE 0,#6000
1130 FOR I=0TOLEN(TS$)-1
1140 POKE #6000+I,ASC(MID$(TS$,I+1,1))
1150 NEXT I
1160 FOR I=0TOLEN(TS$)-1 STEP BTT
1170 DOKE 0,#6000+I
1180 POKE 3,BTT:POKE 4,0:POKE 5,0: POKE 6,BTT
1190 CALL #4000
1200 NEXT I
1210 GOSUB 2000
1220 GOTO 150
1230 END
1500 INPUT "Enter Start Address:";SA$
1510 INPUT "Enter End Address:";EA$
1520 FOR I=VAL(SA$) TO VAL(EA$)-VAL(SA$) STEP BTT
1530 DOKE 0,I
1540 POKE 3,BTT:POKE 4,0:POKE 5,0: POKE 6,BTT
1550 CALL #4000
1560 NEXT I
1570 PRINT "Done Sending"
1580 GOSUB 2000
1590 GOTO 150
1600 END
2000 WAIT 1000
2010 PRINT "PRESS ANY KEY"
2020 A$=KEY$
2030 IF A$="" THEN GOTO 2020
2040 RETURN
4999 END
5000 ST=#4000
5010 EN=0
5030 REPEAT
5040 READ A$
5050 EN=EN+1
5060 UNTIL A$="END"
5070 EN=EN-1
5100 RESTORE
5110 FOR I= ST TO ST+EN-1
5120 READ J
5130 POKE I,J
5140 NEXT I
5160 RETURN
5199 END5200 REM data 
5210 DATA 120,169,255,141,3,3,141,1
5220 DATA 3,234,234,32,167,64,169,0
5230 DATA 133,4,165,5,208,9,32,42
5240 DATA 64,32,132,64,76,37,64,32
5250 DATA 87,64,32,202,64,32,167,64
5260 DATA 88,96,173,1,3,234,234,9
5270 DATA 1,141,1,3,234,234,169,3
5280 DATA 141,1,3,234,234,169,1,44
5290 DATA 1,3,240,251,169,2,44,1
5300 DATA 3,240,251,32,189,64,165,7
5310 DATA 42,32,242,64,176,81,96,173
5320 DATA 1,3,9,1,141,1,3,234
5330 DATA 234,169,3,141,1,3,234,234
5340 DATA 169,1,44,1,3,240,251,169
5350 DATA 2,44,1,3,240,251,32,189
5360 DATA 64,165,8,42,9,1,32,242
5370 DATA 64,176,36,96,32,189,64,230
5380 DATA 4,160,0,177,0,32,242,64
5390 DATA 176,21,165,9,208,3,32,152
5400 DATA 65,200,208,2,230,1,198,3
5410 DATA 208,233,198,4,208,229,96,169
5420 DATA 0,141,1,3,234,234,169,2
5430 DATA 141,1,3,234,234,169,3,141
5440 DATA 1,3,234,234,96,141,1,3
5450 DATA 234,234,169,0,141,1,3,234
5460 DATA 234,96,160,0,198,3,32,62
5470 DATA 65,165,3,201,1,165,4,233
5480 DATA 0,32,108,65,165,2,145,0
5490 DATA 200,208,2,230,1,165,3,208
5500 DATA 227,198,4,165,4,201,255,208
5510 DATA 219,96,133,2,162,8,169,0
5520 DATA 38,2,42,141,1,3,234,234
5530 DATA 9,2,141,1,3,234,234,169
5540 DATA 2,44,1,3,240,251,173,1
5550 DATA 3,41,1,141,1,3,234,234
5560 DATA 202,208,219,169,1,141,1,3
5570 DATA 234,234,169,3,141,1,3,234
5580 DATA 234,169,2,44,1,3,240,251
5590 DATA 234,173,1,3,74,234,169,1
5600 DATA 141,1,3,234,234,96,169,0
5610 DATA 133,2,162,8,169,1,141,1
5620 DATA 3,234,234,169,3,141,1,3
5630 DATA 234,234,169,2,44,1,3,240
5640 DATA 251,234,234,173,1,3,106,38
5650 DATA 2,169,1,141,1,3,234,234
5660 DATA 202,208,224,96,169,0,141,1
5670 DATA 3,234,234,169,2,141,1,3
5680 DATA 234,234,169,0,141,1,3,234
5690 DATA 234,96,169,1,141,1,3,234
5700 DATA 234,169,3,141,1,3,234,234
5710 DATA 169,1,141,1,3,234,234,96
5720 DATA 72,169,255,56,233,1,208,252
5730 DATA 104,96,72,169,100,56,233,1
5740 DATA 208,252,104,96

9999 DATA "END"
10000 INPUT "ENTER START ADDRESS";DR$
10010 SA = VAL(DR$)
10020 INPUT "ENTER LINE";LI$
10030 LM=VAL(LI$)
10040 FOR K=0 TO LM
10050 PRINT HEX$(SA+K*8);": ";
10060 FOR M=0 TO 7
10070 C=SA+K*8+M
10070 PRINT HEX$(PEEK(C));"";
10080 NEXT M
10085 PRINT
10090 NEXT K
10999 END
