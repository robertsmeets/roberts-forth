//----------------------------------------------------------
//----------------------------------------------------------
//					Simple IRQ
//----------------------------------------------------------
//----------------------------------------------------------
			* = $4000 "Robert's Forth"		// <- The name will appear in the memory map when assembling

//VS$="2.73"
//Q%=4
//QQ%=6
//DIM ruim% &C00
//maxlen=80
//evvec=&220
//brkv=&202
//osbyte=&FFF4
//oscli=&FFF7
//osword=&FFF1
//osnewl=&FFE7
//osrdch=&FFE0
//oswrch=&FFEE
//osfile=&FFDD
//ad=&70
//			 seed=ad+10
//here=ad+15
//lwoord=ad+17
//?lwoord=0
//			 lwoord?1=0
//depth=ad+19
//intib=ad+21
//state=ad+23
//base=ad+25
//ervek=ad+27
//stack=0
//buffer=&500
//pad=&400
//PROCassem
//C$="*SAVE ROFORTH "+STR$~ruim%+" "+STR$~O%
//PRINT C$
//OSCLI(C$)
//END
//DEFPROCassem
//FOR opt%=Q%TO QQ%STEP (QQ%-Q%)
//P%=&8000
//			O%=ruim%
start:			jmp langen
			jmp serven
//EQUB &CF \ ROM type 1100 1111
//EQUB (cop-&8000)
//EQUB 273 \ Binaire versie
//.rtxt EQUS "Robert's Forth"
//EQUB 0
//EQUS "Versie "+VS$
//.cop EQUB 0
//EQUS "(C)"
// EQUS " 1988 Robert Smeets"
// EQUB 0
serven:			php
			pha
			tya
			pha
			txa
			pha
			tsx
			lda $103,x
			cmp#4
 			beq unreco
			cmp#9
			beq shelp
unniet:			pla
			tax
			pla
			tay
			pla
			plp
			rts
unreco:			ldx #0
unrl:			lda ($F2),y
			cmp#'.'
			beq unpunt
			cmp uncom,X
			bne unniet
			iny
			inx
			cpx#5
			bne unrlp
unwel:			lda#142
			ldx$F4
			jmp osbyte
unpunt:			cpx#2
			bpl unwel
			bmi unniet
uncom: EQUS"FORTH"
shelp:			lda ($F2),y
			cmp#32
			bne shna
			iny
			bne shelp
shna:			cmp#13
			bne unniet
			jsr osnewl
			ldx#0
shel:			lda rtxt,X
			beq shkla
			jsr oswrch
			inx
			bne shel
shkla:			jsr osnewl
			jmp unniet
//opt FNinitwrd
//.defspc EQUB 5
//			 EQUS "SPACE"
//			 EQUB FNL(defspp)
//			 EQUB FNH(defspp)
spc:			lda#32
			jmp oswrch
defspp:			EQUB 3
			 EQUS "SP!"
			 EQUB FNL(defdropit)
			 EQUB FNH(defdropit)
spp:			lda#0
			sta depth
			rts
put:			jsr xadr
			lda ad
			sta stack,X
			lda ad+1
			sta stack+1,X
			inc depth
			rts
xadr:			lda depth
xxadr:			asl A
			tax
			rts
defdropit:		 EQUB 4
			 EQUS "DROP"
			 EQUB FNL(defrat)
			 EQUB FNH(defrat)
dropit:			lda depth
			beq serr
			jsr xxadr
			lda stack-2,X
			sta ad
			lda stack-1,X
			sta ad+1
			dec depth
			rts
serr: jmp serror
defrat: EQUB 2
			 EQUS "R@"
			 EQUB FNL(defj)
			 EQUB FNH(defj)
rat: tsx
			txa
			clc
			adc#4
			tax
			lda$100,X
			sta ad+1
			dex
			lda$100,X
			sta ad
			jmp put
rrat: tsx
			txa
			clc
			adc#6
			tax
			lda$100,X
			sta ad+1
			dex
			lda$100,X
			sta ad
			jmp put
defj: EQUB 1
			 EQUS "J"
			 EQUB FNL(deffromr)
			 EQUB FNH(deffromr)
j: tsx
			txa
			clc
			adc#8
			tax
			lda$100,X
			sta ad+1
			dex
			lda$100,X
			sta ad
			 jmp put
deffromr: EQUB 2
			 EQUS "R>"
			 EQUB FNL(deftor)
			 EQUB FNH(deftor)
fromr: pla
			tay
			pla
			tax
			pla
			sta ad
			pla
			sta ad+1
			txa
			pha
			tya
			pha
			jmp put
deftor: EQUB 2
			 EQUS ">R"
			 EQUB FNL(defpick)
			 EQUB FNH(defpick)
tor: jsr dropit
			pla
			tay
			pla
			tax
			lda ad+1
			pha
			lda ad
			pha
			txa
			pha
			tya
			pha
			rts
defpick: EQUB 4
			 EQUS "PICK"
			 EQUB FNL(defdup)
			 EQUB FNH(defdup)
pick: jsr dropit
pickwrm: jsr xadr
			txa
			sec
			sbc ad
			sec
			sbc ad
			tax
			lda stack-2,X
			sta ad
			lda stack-1,X
			sta ad+1
			jmp put
defdup: EQUB 3
			 EQUS "DUP"
			 EQUB FNL(defover)
			 EQUB FNH(defover)
dup: jsr dropit
			jsr put
			jmp put
msb0: lda#0
			sta ad+1
			rts
defover: EQUB 4
			 EQUS "OVER"
			 EQUB FNL(defswap)
			 EQUB FNH(defswap)
over: ldy#0
			sty ad+1
			iny
			sty ad
			jmp pickwrm
defswap: EQUB 4
			 EQUS "SWAP"
			 EQUB FNL(defdept)
			 EQUB FNH(defdept)
swap: jsr droptw
			lda ad
			pha
			lda ad+1
			pha
			lda ad+2
			sta ad
			lda ad+3
			sta ad+1
			jsr put
			pla
			sta ad+1
			pla
			sta ad
			jmp put
defdept: EQUB 5
			 EQUS "DEPTH"
			 EQUB FNL(defspaces)
			 EQUB FNH(defspaces)
dept: jsr msb0
			lda depth
			sta ad
			jmp put
defspaces: EQUB 6
			 EQUS "SPACES"
			 EQUB FNL(defat)
			 EQUB FNH(defat)
spaces: jsr dropit
sok: lda ad+1
			cmp#0
			bne dos
			lda ad
			cmp#0
			bne dos
			rts
dos: jsr spc
			dec ad
			lda ad
			cmp#$FF
			bne sok
			dec ad+1
			jmp sok
defat: EQUB 1
			 EQUS "@"
			 EQUB FNL(defpling)
			 EQUB FNH(defpling)
at: jsr dropit
atwrm: ldy#0
			lda (ad),Y
			tax
			iny
			lda (ad),Y
			sta ad+1
			txa
			sta ad
			jmp put
defpling: EQUB 1
			 EQUS "!"
			 EQUB FNL(defemit)
			 EQUB FNH(defemit)
pling: jsr droptw
			ldy#0
			lda ad
			sta (ad+2),Y
			lda ad+1
			iny
			sta (ad+2),Y
			rts
defemit: EQUB 4
			 EQUS "EMIT"
			 EQUB FNL(defcat)
			 EQUB FNH(defcat)
emit: jsr dropit
			lda ad
			jmp oswrch
defcat: EQUB 2
			 EQUS "C@"
			 EQUB FNL(defcpling)
			 EQUB FNH(defcpling)
cat: jsr dropit
			ldy#0
			lda (ad),Y
			sta ad
			jsr msb0
			jmp put
defcpling: EQUB 2
			 EQUS "C!"
			 EQUB FNL(defvrgt)
			 EQUB FNH(defvrgt)
cpling: jsr droptw
			lda ad
			ldy#0
			sta (ad+2),Y
			rts
defvrgt: EQUB 1
			 EQUS "?"
			 EQUB FNL(defkey)
			 EQUB FNH(defkey)
vrgt: jsr at
			jmp punt
defkey: EQUB 3
			 EQUS "KEY"
			 EQUB FNL(defplus)
			 EQUB FNH(defplus)
key: jsr osrdch
			sta ad
			jsr msb0
			jmp put
defplus: EQUB 1
			 EQUS "+"
			 EQUB FNL(defher)
			 EQUB FNH(defher)
plus: jsr droptw
			lda ad
			clc
			adc ad+2
			sta ad
			lda ad+1
			adc ad+3
			sta ad+1
			jmp put
defher: EQUB 4
			 EQUS "HERE"
			 EQUB FNL(defallot)
			 EQUB FNH(defallot)
her: lda here
			sta ad
			lda here+1
			sta ad+1
			jmp put
defallot: EQUB 5
			 EQUS "ALLOT"
			 EQUB FNL(defquery)
			 EQUB FNH(defquery)
allot: jsr dropit
alloti: lda here
			clc
			adc ad
			sta here
			lda here+1
			adc ad+1
			sta here+1
			rts
defquery: EQUB 5
			 EQUS "QUERY"
			 EQUB FNL(defmode)
			 EQUB FNH(defmode)
query: lda#maxlen
			sta ad+2
			lda#0
			sta ad+3
			lda#FNL(buffer)
			sta ad
			lda#FNH(buffer)
			sta ad+1
			jmp exwrm
tib: lda#FNL (buffer) 
			sta ad
			lda#FNH(buffer)
			sta ad+1
			jmp put
status: jsr spc
			lda#'O'
			jsr oswrch
			lda#'K'
			 jmp oswrch
defmode: EQUB 4
			 EQUS "MODE"
			 EQUB FNL(defwords)
			 EQUB FNH(defwords)
mode: jsr dropit
			lda#22
			jsr oswrch
			lda ad
			jmp oswrch
defwords: EQUB 5
			 EQUS "WORDS"
			 EQUB FNL(defliteral)
			 EQUB FNH(defliteral)
words: jsr osnewl
			jsr osnewl
			lda lwoord
			sta ad+5
			lda lwoord+1
			sta ad+6
wordz: lda ad+5
			bne wook
			lda ad+6
			bne wook
			jsr osnewl
			jmp osnewl
wook: lda#1
			clc
			adc ad+5
			sta ad
			lda#0
			adc ad+6
			sta ad+1
			ldy#0
			lda (ad+5),Y
			and #$7F
			pha
			sta ad+2
			sty ad+3
			jsr typwrm
			jsr spc
			ldy#0
			pla
			tay
			iny
			lda (ad+5),Y
			pha
			iny
			lda (ad+5),Y
			sta ad+6
			pla
			sta ad+5
			jmp wordz
vind: lda lwoord
			sta ad+3
			lda lwoord+1
			sta ad+4
vindz: lda ad+3
			bne vook
			lda ad+4
			bne vook
			lda#0
			sta ad
			sta ad+1
			rts
vook: ldy#0
			lda (ad+3),Y
			and #$7F
			cmp ad+2
			beq voegel
voet: tay
			iny
			lda (ad+3),Y
			pha
			iny
			lda (ad+3),Y
			sta ad+4
			pla
			sta ad+3
			jmp vindz
voegel: ldy#0
voezz:			lda (ad),Y
			iny
			cmp (ad+3),Y
			bne voeni
			cpy ad+2
			bne voezz
			jmp voewat
voeni: ldy#0
			lda (ad+3),Y
			and#$7F
			jmp voet
voewat: ldy#0
			lda (ad+3),Y
			and#$7F
			clc
			adc ad+3
			sta ad
			lda ad+4
			adc#0
			sta ad+1
			lda ad
			clc
			adc#3
			sta ad
			lda ad+1
			adc#0
			sta ad+1
			rts
command: jsr comips
			lda state
			bne tostcom
			ldx ad+6
			ldy ad+7
			jmp oscli
tostcom: jmp stcom
doe: jsr droptw
			lda ad+2
			sta ad+8
			lda ad
			sta ad+6
			lda ad+1
			sta ad+7
			jsr vind
			lda ad
			bne doeiet
			lda ad+1
			bne doeiet
			ldy#0
			lda (ad+6),Y
			cmp#'*'
			beq command
			jsr getl
			lda state
			bne getcom
			rts
getcom: jmp literal
doeiet: jmp doeiets
defliteral: EQUB 7
			 EQUS "LITERAL"
			 EQUB FNL(deflit)
			 EQUB FNH(deflit)
literal: 		lda#$20
			jsr czet
			lda#FNL(lit)
			jsr czet
			lda#FNH(lit)
			jsr czet
			jmp komma
deflit: EQUB 3
			 EQUS "LIT"
			 EQUB FNL(definterpret)
			 EQUB FNH(definterpret)
lit: pla
			clc
			adc#1
			sta ad
			tax
			pla
			adc#0
			sta ad+1
			tay
			txa
			clc
			adc#1
			tax
			tya
			adc#0
			pha
			txa
			pha
			jmp atwrm
getl: ldy#0
			lda (ad+6),Y
			cmp#'-'
			bne getal
			lda#1
			clc
			adc ad+6
			sta ad+6
			lda #0
			adc ad+7
			sta ad+7
			dec ad+8
			jsr getal
			jmp negate
getal: ldy#0
			sty ad+4
			sty ad+5
getloop: cpy ad+8
			beq getend
			lda (ad+6),Y
			cmp#'A'
			bpl geta
			sec
			sbc#'0'
			jmp getvoeg
geta: sec
			sbc#('A'-10)
getvoeg: cmp base
			bcs nigetal
			pha
			iny
			tya
			pha
			lda#0
			sta ad+3
			lda base
			sta ad+2
			jsr maalwrm
			lda ad
			sta ad+4
			lda ad+1
			sta ad+5
			pla
			tay
			pla
			clc
			adc ad+4
			sta ad+4
			lda#0
			adc ad+5
			sta ad+5
			jmp getloop
getend: lda ad+4
			sta ad
			lda ad+5
			sta ad+1
			jsr put
			jmp skips
doeiets: ldy#0
			lda (ad+3),Y
			and#$80
			bne doewe
			lda state
			beq doewe
			ldy#0
			lda#$20
			sta (here),Y
			iny
			lda ad
			sta (here),Y
			lda ad+1
			iny
			sta (here),Y
allot3: lda#3
			clc
			adc here
			sta here
			lda here+1
			adc#0
			sta here+1
			rts
allot2: lda#2
			clc
			adc here
			sta here
			lda#0
			adc here+1
			sta here+1
			rts
nigetal: jmp werror
doewe: jmp(ad)
findit: jsr skips
			ldy intib
			lda buffer,Y
			cmp#13
			beq firet
			lda intib
			sta ad+2
			clc
			adc#FNL(buffer)
			sta ad
			lda#0
			adc#FNH(buffer)
			sta ad+1
			jsr put
			jsr normsk
			lda intib
			sec
			sbc ad+2
			sta ad
			jsr msb0
			jsr put
			jsr skips
			jsr droptw
			jsr vind
			lda ad
			bne firet
			lda ad+1
			bne firet
			jmp werror
firet: rts
definterpret: EQUB 9
			 EQUS "INTERPRET"
			 EQUB FNL(defforget)
			 EQUB FNH(defforget)
interpret: lda#0
			sta intib
intp: jsr skips
			ldy intib
			lda buffer,Y
			cmp#13
			beq inret
			lda intib
			sta ad+2
			clc
			adc#FNL(buffer)
			sta ad
			lda#0
			adc#FNH (buffer)
			sta ad+1
			jsr put
			jsr normsk
			lda intib
			sec
			sbc ad+2
			sta ad
			jsr msb0
			jsr put
			jsr skips
			jsr doe
			jmp intp
inret: rts
defforget: EQUB 6
			 EQUS "FORGET"
			 EQUB FNL(defstart)
			 EQUB FNH(defstart)
forget: jsr findit
			lda ad+3
			bne forgok
			lda ad+4
			bne forgok
			jmp werror
forgok: lda ad+3
			sta here
			lda ad+4
			sta here+1
			lda ad
			sec
			sbc#2
			sta ad
			lda ad+1
			sbc#0
			sta ad+1
			ldy#0
			lda (ad),Y
			sta lwoord
			iny
			lda (ad),Y
			sta lwoord+1
			rts
skips: ldy intib
			lda buffer,Y
			cmp#32
			bne skret
			inc intib
			jmp skips
skret: rts
normsk: ldy intib
			lda buffer,Y
			cmp#32
			beq nkret
			cmp#13
			beq nkret
			inc intib
			jmp normsk
nkret: rts
comips: ldy intib
			lda buffer, Y
			cmp#'\'
			beq comir
			cmp#13
			beq comr
			inc intib
			jmp comips
comir: lda#13
			sta buffer,Y
			inc intib
comr: rts
langen: cmp#1
			beq start
			rts
defstart: EQUB 5
			 EQUS "START"
			 EQUB FNL(definit)
			 EQUB FNH(definit)
start: cli
			jsr init
			jmp abort
definit: EQUB 4
			 EQUS "INIT"
			 EQUB FNL(defrom)
			 EQUB FNH(defrom)
init: lda#FNL(brkk) 
			sta$202
			lda#FNH (brkk) 
			sta$203
			lda#FNL(type)
			sta ervek
			lda#FNH(type)
			sta ervek+1
			lda#FNL(defspc)
			sta lwoord
			lda #FNH(defspc)
			sta lwoord+1
			jsr ram
			lda#0
			sta state
			sta state+1
			sta base+1
			jmp decimal
defrom: EQUB 3
			 EQUS "ROM"
			 EQUB FNL(defram)
			 EQUB FNH(defram)
rom: lda herstor
			sta here
			lda herstor+1
			sta here+1
			rts
defram: EQUB 3
			 EQUS "RAM"
			 EQUB FNL(defabort)
			 EQUB FNH(defabort)
ram: lda#131
			jsr osbyte
			stx here
			sty here+1
			rts
toev: lda#126
			jsr osbyte
etxt: EQUB 0
			EQUB$11
			EQUS"Escape"
			EQUB 0
defabort: EQUB 5
			 EQUS "ABORT"
			 EQUB FNL(defquit)
			 EQUB FNH(defquit)
abort: jsr spp
defquit: EQUB 4
			 EQUS "QUIT"
			 EQUB FNL(defdblpunt)
			 EQUB FNH(defdblpunt)
quit: 
qlp: jsr osnewl
			ldx#255
			txs
			jsr query
			jsr interpret
			lda state
			bne qlp
			jsr status
			jmp qlp
serror:
			EQUB 0
			EQUB 0
			EQUS"Stapel leeg"
			EQUB 0
werror:
			EQUB 0
			EQUB 0
			EQUS"Woord onbekend"
			EQUB 0
in: lda#FNL(intib)
			sta ad
			lda#FNH(intib)
			sta ad+1
			jmp put
voegtoe:
voegwrm: jsr skips
			lda intib
			sta ad+2
			jsr normsk
			lda intib
			sec
			sbc ad+2
			cmp#0
			beq crerror
			sta ad+3
			ldy#0
			sta (here),Y
			iny
			ldx ad+2
vlp: lda buffer,X
			sta (here),Y
			inx
			iny
			cmp#32
			beq voegst
			cmp#13
			bne vlp
voegst: dey
			lda lwoord
			sta (here), Y
			iny
			lda lwoord+1
			sta (here),Y
			lda here
			sta lwoord
			lda here+1
			sta lwoord+1
			iny
			tya
			pha
			pla
			clc
			adc here
			sta here
			lda#0
			adc here+1
			sta here+1
			rts
crerror: EQUB 0
			EQUB 0
			EQUS"Geen goed woord"
			EQUB 0
defdblpunt: EQUB 1
			 EQUS ":"
			 EQUB FNL(defpntkomma)
			 EQUB FNH(defpntkomma)
dblpnt: jsr voegtoe
			lda#1
			sta state
			rts
defpntkomma:		EQUB $81
			 EQUS ";"
			 EQUB FNL(defcreate)
			 EQUB FNH(defcreate)
pntkomma:		lda#$60
			jsr czet
			lda#0
			sta state
			rts
defcreate: EQUB 6
			 EQUS "CREATE"
			 EQUB FNL(defconstant)
			 EQUB FNH(defconstant)
create: jsr voegtoe
			lda#$20
			jsr czet
			lda#FNL(creac) 
			jsr czet
			lda#FNH(creac)
			jmp czet
creac: pla
			clc
			adc#1
			sta ad
			pla
			adc#0
			sta ad+1
			jmp put
defconstant: EQUB 8
			 EQUS "CONSTANT"
			 EQUB FNL(defstt)
			 EQUB FNH(defstt)
constant: jsr voegtoe
			lda#$20
			jsr czet
			lda#FNL(constc) 
			jsr czet
			lda#FNH (constc)
			jsr czet
			jmp komma
constc: pla
			clc
			adc#1
			sta ad
			pla
			adc#0
			sta ad+1
			jmp atwrm
defstt: EQUB 5
			 EQUS "STATE"
			 EQUB FNL(defbse)
			 EQUB FNH(defbse)
stt: lda#FNL(state)
			sta ad
			lda#FNH(state)
			sta ad+1
			jmp put
defbse: EQUB 4
			 EQUS "BASE"
			 EQUB FNL(defnulis)
			 EQUB FNH(defnulis)
bse: lda#FNL(base)
			sta ad
			lda#FNH(base)
			sta ad+1
			jmp put
defnulis: EQUB 2
			 EQUS "0="
			 EQUB FNL(deftrue)
			 EQUB FNH(deftrue)
nulis: jsr dropit
			lda#0
			cmp ad
			bne nnul
			cmp ad+1
			bne nnul
			jmp true
nnul: jmp false
defiss: EQUB 1
			 EQUS "="
			 EQUB FNL(defnulkl)
			 EQUB FNH(defnulkl)
iss: jsr droptw
			lda ad
			cmp ad+2
			bne false
			lda ad+1
			cmp ad+3
			bne false
			beq true
defnulkl: EQUB 2
			 EQUS "0<"
			 EQUB FNL(defnulgr)
			 EQUB FNH(defnulgr)
nulkl: jsr dropit
			lda ad+1
			bmi true
			bpl false
deftrue: EQUB 4
			 EQUS "TRUE"
			 EQUB FNL(deffalse)
			 EQUB FNH(deffalse)
true: ldy#0
			sty ad+1
			iny
			sty ad
			jmp put
deffalse: EQUB 5
			 EQUS "FALSE"
			 EQUB FNL(defiss)
			 EQUB FNH(defiss)
false: lda#0
			sta ad
			sta ad+1
			jmp put
defnulgr: EQUB 2
			 EQUS "0>"
			 EQUB FNL(defkl)
			 EQUB FNH(defkl)
nulgr: jsr dropit
			lda ad+1
			bmi false
			bne true
			lda ad
			bne true
			beq false
defkl: EQUB 1
			 EQUS "<"
			 EQUB FNL(defgr)
			 EQUB FNH(defgr)
kl: jsr droptw
			lda ad+1
			cmp ad+3
			beq klna
			bpl false
			bmi true
klna: lda ad
			cmp ad+2
			bcs false
			bcc true
defgr: EQUB 1
			 EQUS ">"
			 EQUB FNL(defimmediate)
			 EQUB FNH(defimmediate)
gr: jsr droptw
			lda ad+1
			cmp ad+3
			beq grna
			bmi false
			bpl true
grna: lda ad
			cmp ad+2
			beq false
			bcs true
			bcc false
ukl: jsr droptw
			lda ad+1
			cmp ad+3
			beq klna
			bcc true
			bcs false
defimmediate: EQUB 9
			 EQUS "IMMEDIATE"
			 EQUB FNL(deftype)
			 EQUB FNH(deftype)
immediate: lda lwoord
			sta ad
			lda lwoord+1
			sta ad+1
			ldy#0
			lda(ad),Y
			ora#&80
			sta(ad),Y
			rts
stcom: lda#&20
			jsr czet
			lda#FNL(stcode) 
			jsr czet
			lda#FNH(stcode)
			jsr czet
			lda#0
			sta ad+2
			ldy#1
stplp: lda(ad+6),Y
			cmp#13
			beq stprret
			sta(here),Y
			iny
			jmp stplp
stprret: sta(here),Y
			tya
			ldy#0
			sta(here),Y
			tay
			iny
			sty ad
			jsr msb0
			jmp allot
tprint: lda state
			beq tprdoe
			lda#&20
			jsr czet
			lda#FNL(tprintcode)
			jsr czet
			lda#FNH (tprintcode)
			jsr czet
			lda#0
			sta ad+2
			ldx intib
			ldy#1
tplp: lda buffer,X
			cmp#13
			beq tprret
			cmp#ASC""""
			beq tpraan
			sta(here),Y
			inc intib
			inx
			iny
			jmp tplp
tpraan: inc intib
tprret: dey
			 tya
			ldy#0
			sta(here),Y
			tay
			iny
			sty ad
			jsr msb0
			jmp alloti
tprdoe: ldx intib
			lda buffer,X
			cmp#13
			beq tprdr
			cmp#ASC""""
			beq tprdr
			jsr oswrch
			inc intib
			jmp tprdoe
tprdr: inc intib
			rts
tprintcode: pla
			clc
			adc#1
			sta ad
			pla
			adc#0
			sta ad+1
			ldy#0
			lda(ad),Y
			sta ad+2
			lda#0
			sta ad+3
			lda ad
			clc
			adc#1
			sta ad
			lda ad+1
			adc#0
			sta ad+1
			lda ad
			pha
			lda ad+1
			pha
			lda ad+2
			pha
			jsr typwrm
			pla
			sta ad+2
			pla
			sta ad+1
			pla
			clc
			adc ad+2
			sta ad
			lda ad+1
			adc#0
			sta ad+1
			jmp (ad)
stcode: pla
			clc
			adc#1
			sta ad
			pla
			adc#0
			sta ad+1
			ldy#0
			lda(ad),Y
			sta ad+2
			lda ad
			clc
			adc#1
			sta ad
			lda ad+1
			adc#0
			sta ad+1
			lda ad
			pha
			lda ad+1
			pha
			lda ad+2
			pha
			ldx ad
			ldy ad+1
			jsr oscli
			pla
			sta ad+2
			pla
			sta ad+1
			pla
			clc
			adc ad+2
			sta ad
			lda ad+1
			adc#0
			sta ad+1
			 jmp (ad)
deftype: EQUB 4
			 EQUS "TYPE"
			 EQUB FNL(defcls)
			 EQUB FNH(defcls)
type: jsr droptw
typwrm: lda ad
			clc
			adc ad+2
			sta ad+2
			lda ad+1
			adc ad+3
			sta ad+3
			ldy#0
tyloop: lda ad
			cmp ad+2
			bne tyhup
			lda ad+1
			cmp ad+3
			bne tyhup
			rts
tyhup: lda(ad),Y
			jsr oswrch
			clc
			lda#1
			adc ad
			sta ad
			lda#0
			adc ad+1
			sta ad+1
			jmp tyloop
defcls: EQUB 3
			 EQUS "CLS"
			 EQUB FNL(defexpect)
			 EQUB FNH(defexpect)
cls: lda#12
			jmp oswrch
droptw: jsr dropit
			lda ad
			sta ad+2
			lda ad+1
			sta ad+3
			jmp dropit
defexpect: EQUB 6
			 EQUS "EXPECT"
			 EQUB FNL(defkomma)
			 EQUB FNH(defkomma)
expect: jsr droptw
exwrm: lda ad
			sta ad+4
			clc
			adc ad+2
			sta ad+2
			lda ad+1
			sta ad+5
			adc ad+3
			sta ad+3
exloop: lda ad
			cmp ad+2
			bne exhup
			lda ad+1
			cmp ad+3
			bne exhup
exrt: jmp exrut
exhup: lda#0
			sta intib
			jsr osrdch
			 cmp#13
			beq exret
			cmp#27
			beq exesc
			cmp#127
			beq exdel
			jsr oswrch
			cmp#32
			bcc exloop
			cmp#128
			bcs exloop
			ldy#0
			sta(ad),Y
			lda#1
			clc
			adc ad
			sta ad
			lda#0
			adc ad+1
			sta ad+1
			jmp exloop
exesc: jmp toev
exret: jsr spc
exrut: ldy#0
			lda#13
			sta(ad),Y
			rts
exdel: lda ad
			cmp ad+4
			bne exdoedel
			lda ad+1
			cmp ad+5
			beq exloop
exdoedel: sec
			lda ad
			sbc#1l
			sta ad
			lda ad+1l
			sbc#0
			sta ad+1
			lda#127
			jsr oswrch
			jmp exloop
defkomma: EQUB 1
			 EQUS ","
			 EQUB FNL(defckomma)
			 EQUB FNH(defckomma)
komma: jsr dropit
komwrm: ldy#0
			lda ad
			sta(here),Y
			iny
			lda ad+1
			sta(here),Y
			jmp allot2
defckomma: EQUB 2
			 EQUS "C,"
			 EQUB FNL(defnegate)
			 EQUB FNH(defnegate)
ckomma: jsr dropit
ckomwrm: lda ad
czet: ldy#0
			sta(here),Y
allotl: ldx#1l
			stx ad
			jsr msb0
			jmp alloti
eenplus: jsr dropit
eenpluswrm: lda#0
			sec
			adc ad
			sta ad
			lda#0
			adc ad+1
			sta ad+1
			jmp put
defnegate: EQUB 6
			 EQUS "NEGATE"
			 EQUB FNL(defmin)
			 EQUB FNH(defmin)
negate: jsr dropit
negwrm: lda ad
			eor#&FF
			sta ad
			lda ad+1
			eor#&FF
			sta ad+1
			jmp eenpluswrm
defmin: EQUB 3
			 EQUS "MIN"
			 EQUB FNL(defmaal)
			 EQUB FNH(defmaal)
min: jsr droptw
			lda ad
			sec
			sbc ad+2
			sta ad
			lda ad+1
			sbc ad+3
			sta ad+1
			jmp put
maalwrm: lda#0
			sta ad
			sta ad+1
maloop: lda ad+2
			bne maok
			lda ad+3
			bne maok
			rts
maok: lda ad+2
			and#1
			beq masch
			lda ad
			clc
			adc ad+4
			sta ad
			lda ad+1
			adc ad+5
			sta ad+1
masch: lsr ad+3
			ror ad+2
			asl ad+4
			rol ad+5
			jmp maloop
defmaal: EQUB 1
			 EQUS "*"
			 EQUB FNL(defupunt)
			 EQUB FNH(defupunt)
maal: jsr droptw
			lda ad
			sta ad+4
			lda ad+1
			sta ad+5
			jsr maalwrm
			jmp put
defupunt: EQUB 2
			 EQUS "U."
			 EQUB FNL(defpunt)
			 EQUB FNH(defpunt)
upunt: jsr dropit
upuntwrm: lda#&FF
puntnbit: pha
			lda#0
			sta ad+2
			sta ad+3
			ldx#16
puntnext: asl ad
			rol ad+1
			rol ad+2
			rol ad+3
			lda ad+2
			sec
			sbc base
			tay
			lda ad+3
			sbc#0
			bcc puntdone
			inc ad
			sty ad+2
			sta ad+3
puntdone: dex
			bne puntnext
			lda ad+2
			ldy ad
			bne puntnbit
			ldy ad+1
			bne puntnbit
puntout: cmp#10
			bcc puntadd
			 adc#6
puntadd: adc#48
			jsr oswrch
			pla
			bpl puntout
puntexit: jmp spc
defpunt: EQUB 1
			 EQUS "."
			 EQUB FNL(defdecimal)
			 EQUB FNH(defdecimal)
punt: jsr dropit
			lda ad+1
			bpl upuntwrm
			 lda#ASC"-"
			jsr oswrch
			lda ad
			 eor#&FF
			clc
			adc#1
			sta ad
			lda ad+1
			eor#&FF
			adc#0
			sta ad+1
			jmp upuntwrm
defdecimal: EQUB 7
			 EQUS "DECIMAL"
			 EQUB FNL(defdp)
			 EQUB FNH(defdp)
decimal: lda#10
bazep: sta base
			lda#0
			sta base+1
			rts
brkk: lda&FD
			clc
			adc#1
			sta ad
			lda&FE
			adc#0
			sta ad+1
			jsr put
			ldy#0
brklp: lda(ad),Y
			beq brkla
			iny
			bne brklp
brkla: sty ad
			jsr msb0
			jsr put
			jsr brkin
			jmp abort
brkin: jmp (ervek)
erv: lda#FNL(ervek)
			sta ad
			lda#FNH(ervek)
			sta ad+1
			jmp put
defdp: EQUB 2
			 EQUS "DP"
			 EQUB FNL(defexit)
			 EQUB FNH(defexit)
dp: lda#FNL (here) 
			sta ad
			 lda#FNH(here)
			sta ad+1
			jmp put
defexit: EQUB 4
			 EQUS "EXIT"
			 EQUB 0
			 EQUB 0
exit: lda#&60
			jmp czet
//]
//NEXT
// ENDPROC
//DEFFNL(X%)=X%MOD256
//DEFFNH(X%)=X%DIV256
//DEFPROCP
//P%=P%+2
// O%=O%+2
//ENDPROC
//DEFFNinitwrd
//herstor=P%
//PROCP
//lstor=P%
//		PROCP
// =opt%
