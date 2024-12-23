//----------------------------------------------------------
#if BBC
    .print "Target = BBC"
    * = $8000 "Robert's Forth"        // The name will appear in the memory map when assembling
    .const osrdch=$FFE0
    .const oswrch=$FFEE
    .const ad=$70
    .const osnewl=$FFE7
    .const osfile=$FFDD
    .const osbyte=$FFF4
    .const oscli=$FFF7
    .const buffer=$500              // typed in text ends up here
    .const pad=$400
    .const brkv=$202
#endif

#if C64
    .print "Target = C64"
    BasicUpstart2(startlab)
    .const getin=$FFE4           // CHRIN
    .const oswrch=$FFD2
    .const osfile=0 // these routines don't exist on C64 and need to be replaced with custom routines
    .const osbyte=0
    .const oscli=0
    .const ad=$02
    .const buffer=$9f00            // typed in text ends up here
    .const pad=$9e00
    .const brkv=$9cfef
osrdch:     jsr getin
            cmp #0
            beq osrdch
            rts
osnewl:     lda #$D
            jsr oswrch
            lda #$A
            jmp oswrch
#endif
            .encoding "ascii"               // needed, otherwise another charset will be used
            .const VS="2.73"
            .const maxlen=80
            .const seed=ad+10               // seed for the random generator
            .const here=ad+15               // location of the first byte of free memory
            .const lwoord=ad+17             // lwoord contains the first word, used to traverse the linked list of words
            .const depth=ad+19              // depth of the stack
            .const intib=ad+21              // reading index in the input buffer
            .const state=ad+23              // state = 0 when interpreting, 1 when compiling a word
            .const base=ad+25               // numeric base for printing. i.e. 10 for decimal, 16 for hex
            .const ervek=ad+27              // location of error handling
            .const stack=0
#if BBC
start:      jmp langen
            jmp serven
//ROM type byte:
//
// b7 = ROM contains a service entry
// b6 = ROM contains a language entry
// b5 = ROM contains Tube transfer address and any other addresses after the copyright string
// b4 = ROM contains Electron key expansions
// b3-b0 = ROM CPU type
// 0 6502 BASIC           8 Z80
// 1 Turbo6502            9 32016
// 2 6502                10 -
// 3 68000               11 80186
// 4 -                   12 80286
// 5 -                   13 ARM
// 6 -                   14 -
// 7 PDP-11              15 - 
            .byte %11000010
            .byte cop-$8000
            .byte 273 // Binaire versie
#endif
rtxt:       .text "Robert's Forth"
            .byte 0
#if BBC
            .text "Versie "+VS
cop:        .byte 0
            .text "(C)"
            .text " 1988 Robert Smeets"
            .byte 0
#endif

//
// service entry
//
serven:     php
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
unniet:     pla
            tax
            pla
            tay
            pla
            plp
            rts
herstor:    .byte <romhwm
            .byte >romhwm
lstor:      .byte <defspc
            .byte >defspc
unreco:     ldx #0
unrlp:      lda ($F2),y
            cmp#'.'
            beq unpunt
            cmp uncom,X
            bne unniet
            iny
            inx
            cpx#5
            bne unrlp
unwel:      lda#142
            ldx$F4
            jmp osbyte
unpunt:     cpx#2
            bpl unwel
            bmi unniet
uncom:      .text "FORTH"
shelp:      lda ($F2),y
            cmp#32
            bne shna
            iny
            bne shelp
shna:       cmp#13
            bne unniet
            jsr osnewl
            ldx#0
shel:       lda rtxt,X    // print out the Robert's Forth string, stored at rtxt
            beq shkla
            jsr oswrch
            inx
            bne shel
shkla:      jsr osnewl
            jmp unniet
defspc:     .byte 5
            .text "SPACE"
            .byte <defspp
            .byte >defspp
spc:        lda#32
            jmp oswrch
defspp:     .byte 3
            .text "SP!"
            .byte <defdropit
            .byte >defdropit
spp:        lda#0
            sta depth
            rts
put:        jsr xadr
            lda ad
            sta stack,X
            lda ad+1
            sta stack+1,X
            inc depth
            rts
xadr:       lda depth
xxadr:      asl
            tax
            rts
defdropit:  .byte 4
            .text "DROP"
            .byte <defrat
            .byte >defrat
dropit:     lda depth           // drop the top of the stack, and retain the value in ad and ad+1
            beq serr            // stack empty, print error message
            jsr xxadr           // multiply depth by 2, to get the offset
            lda stack-2,X       // get the value on the stack and place it in ad and ad+1
            sta ad
            lda stack-1,X
            sta ad+1
            dec depth           // decrement the depth
            rts
serr:       jmp serror
defrat:     .byte 2
            .text "R@"
            .byte <defi
            .byte >defi
rat:        tsx
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
defi:       .byte 1
            .text "I"
            .byte <defrrat
            .byte >defrrat 
i:          tsx
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
defrrat:    .byte 3
            .text "RR@"
            .byte <defj
            .byte >defj     
rrat:       tsx
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
defj:       .byte 1
            .text "J"
            .byte <deffromr
            .byte >deffromr
j:          tsx
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
deffromr:   .byte 2
            .text "R>"
            .byte <deftor
            .byte >deftor
fromr:      pla
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
deftor:     .byte 2
            .text ">R"
            .byte <defpick
            .byte >defpick
tor:        jsr dropit
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
defpick:    .byte 4
            .text "PICK"
            .byte <defdup
            .byte >defdup
pick:       jsr dropit
pickwrm:    jsr xadr
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
defdup:     .byte 3
            .text "DUP"
            .byte <defover
            .byte >defover
dup:        jsr dropit
            jsr put
            jmp put
msb0:       lda#0
            sta ad+1
            rts
defover:    .byte 4
            .text "OVER"
            .byte <defswap
            .byte >defswap
over:       ldy#0
            sty ad+1
            iny
            sty ad
            jmp pickwrm
defswap:    .byte 4
            .text "SWAP"
            .byte <defdept
            .byte >defdept
swap:       jsr droptw
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
defdept:    .byte 5
            .text "DEPTH"
            .byte <defspaces
            .byte >defspaces
dept:       jsr msb0
            lda depth
            sta ad
            jmp put
defspaces: .byte 6
            .text "SPACES"
            .byte <defat
            .byte >defat
spaces:     jsr dropit
sok:        lda ad+1
            cmp#0
            bne dos
            lda ad
            cmp#0
            bne dos
            rts
dos:        jsr spc
            dec ad
            lda ad
            cmp#$FF
            bne sok
            dec ad+1
            jmp sok
defat:      .byte 1
            .text "@"
            .byte <defpling
            .byte >defpling
at:         jsr dropit
atwrm:      ldy#0
            lda (ad),Y
            tax
            iny
            lda (ad),Y
            sta ad+1
            txa
            sta ad
            jmp put
defpling:   .byte 1
            .text "!"
            .byte <defemit
            .byte >defemit
pling:      jsr droptw
            ldy#0
            lda ad
            sta (ad+2),Y
            lda ad+1
            iny
            sta (ad+2),Y
            rts
defemit:    .byte 4
            .text "EMIT"
            .byte <defcat
            .byte >defcat
emit:       jsr dropit
            lda ad
            jmp oswrch
defcat:     .byte 2
            .text "C@"
            .byte <defcpling
            .byte >defcpling
cat:        jsr dropit
            ldy#0
            lda (ad),Y
            sta ad
            jsr msb0
            jmp put
defcpling: .byte 2
            .text "C!"
            .byte <defvrgt
            .byte >defvrgt
cpling:     jsr droptw
            lda ad
            ldy#0
            sta (ad+2),Y
            rts
defvrgt:    .byte 1
            .text "?"
            .byte <defkey
            .byte >defkey
vrgt:       jsr at
            jmp punt
defkey:     .byte 3
            .text "KEY"
            .byte <defplus
            .byte >defplus
key:        jsr osrdch
            sta ad
            jsr msb0
            jmp put
defplus:    .byte 1
            .text "+"
            .byte <defher
            .byte >defher
plus:       jsr droptw
            lda ad
            clc
            adc ad+2
            sta ad
            lda ad+1
            adc ad+3
            sta ad+1
            jmp put
defher:     .byte 4
            .text "HERE"
            .byte <deflwoord
            .byte >deflwoord
her:        lda here
            sta ad
            lda here+1
            sta ad+1
            jmp put
deflwoord:  .byte 6
            .text "LWOORD"
            .byte <defallot
            .byte >defallot
            lda lwoord
            sta ad
            lda lwoord+1
            sta ad+1
            jmp put
defallot:   .byte 5
            .text "ALLOT"
            .byte <defquery
            .byte >defquery
allot:      jsr dropit
alloti:     lda here
            clc
            adc ad
            sta here
            lda here+1
            adc ad+1
            sta here+1
            rts
defquery:   .byte 5
            .text "QUERY"
            .byte <defmode
            .byte >defmode
query:      lda#maxlen
            sta ad+2    // ad+2,3 contain the maximum amount of characters to read
            lda#0
            sta ad+3     
            lda#<buffer
            sta ad
            lda#>buffer
            sta ad+1     // ad, ad+1 contain the buffer address
            jmp exwrm    // jump to EXPECT
tib:        lda#<buffer // put the address of buffer onto the stack
            sta ad
            lda#>buffer
            sta ad+1
            jmp put
status:     jsr spc     // prints out OK
            lda#'O'
            jsr oswrch
            lda#'K'
            jmp oswrch
defmode:    .byte 4
            .text "MODE"
            .byte <defwords
            .byte >defwords
mode:        jsr dropit  // switch screen mode
            lda#22
            jsr oswrch
            lda ad
            jmp oswrch
execute:    jmp (ad+3)
echtexec:   jsr dropit  // jump to the address on top of the stack
            lda ad
            sta ad+3
            lda ad+1
            sta ad+4
            jmp execute
defwords:   .byte 5
            .text "WORDS"
            .byte <defliteral
            .byte >defliteral
words:      jsr osnewl  // show a list of words
            lda lwoord
            sta ad+5
            lda lwoord+1
            sta ad+6
wordz:      lda ad+5
            bne wook
            lda ad+6
            bne wook
            jmp osnewl
wook:       lda#1
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
vind:       lda lwoord          // load lwoord, address of the first word and 
            sta ad+3            // store it in ad+3, ad+4
            lda lwoord+1
            sta ad+4
vindz:      lda ad+3            // if ad+3, ad+4 are zero, the end of the words is reached
            bne vook
            lda ad+4
            bne vook
            lda #0               // not found
            sta ad
            sta ad+1
            rts
vook:       ldy #0       // ad, ad+1 contain the address of a word from the input
                         // ad+2 contains the length of the word
						 // ad+3, ad+4 contain the address of the next word in the word list
            lda (ad+3),Y // grab length of word in vocabulary
            and #$7F     // blank out the top bit
            cmp ad+2     // compare against the length of the word
            beq voegel
voet:       tay          // increment y and go to word!? for comparision
            iny
            lda (ad+3),Y
            pha
            iny
            lda (ad+3),Y
            sta ad+4
            pla
            sta ad+3
            jmp vindz
voegel:     ldy #0               // length is good
voezz:      lda (ad),Y           // compare the word pointed to by ad, ad+1 with the word pointed to by
            iny                  // ad+3, ad+4
            cmp (ad+3),Y
            bne voeni
            cpy ad+2
            bne voezz
            jmp voewat
voeni:      ldy#0                // word is not equal
            lda (ad+3),Y
            and#$7F
            jmp voet
voewat:     ldy#0                // found! word is equal!? to the one in the dictionary
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
toexec:     ldy#0
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
command:    jsr comips      // execute a OS * command with OSCLI
            lda state
            bne tostcom
            ldx ad+6
            ldy ad+7
            jmp oscli
tostcom:    jmp stcom
doe:        jsr droptw      // find a word and execute it
                            // ad, ad+1 contain the address of the word
                            // ad+2, ad+3 contain the length of the word (ad+3 is zero)
            lda ad+2
            sta ad+8
            lda ad
            sta ad+6
            lda ad+1
            sta ad+7
            jsr vind        // find the word
result:     lda ad
            bne doeiet
            lda ad+1
            bne doeiet
            ldy#0           // word not found in vocabulary
            lda (ad+6),Y    // check for OS command starting with *
            cmp#'*'
            beq command
            jsr getl        // not a word, and not a OS command, must be a literal
            lda state
            bne getcom        
            rts
getcom: jmp literal
doeiet: jmp doeiets
defliteral: .byte 7
            .text "LITERAL"
            .byte <deflit
            .byte >deflit
literal:     lda#$20        // a literal was found. Add "jsr lit" to the code
            jsr czet        
            lda#<lit
            jsr czet
            lda#>lit
            jsr czet
            jmp komma        // add the literal to the code (2 bytes)
deflit: .byte 3
            .text "LIT"
            .byte <deffind
            .byte >deffind
lit:        pla            // compiled code for literal
            clc            // grab 2 bytes after the PC and put it on the stack
            adc#1        // get the PC by retrieving it from the return stack with pla
            sta ad        // store it in x and y registers
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
            pha            // put the PC back on the return stack
            txa            // so execution will resume after the 2 byte literal
            pha
            jmp atwrm
getl:       ldy#0
            lda (ad+6),Y
            cmp #'-'
            bne getal
            lda #1                // negative number preceded by -
            clc
            adc ad+6
            sta ad+6
            lda #0
            adc ad+7
            sta ad+7
            dec ad+8
            jsr getal
            jmp negate
getal:      ldy#0
            sty ad+4
            sty ad+5
getloop:    cpy ad+8
            beq getend
            lda (ad+6),Y
            cmp#'A'
            bpl geta
            sec
            sbc#'0'
            jmp getvoeg
geta:       sec
            sbc#('A'-10)
getvoeg:    cmp base        // if one of the digits is greater than or equal to the base, it's not a number
            bcs nigetal
            pha
            iny
            tya
            pha
            lda#0
            sta ad+3
            lda base
            sta ad+2
            jsr maalwrm     // multiply the digit with the base
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
getend:     lda ad+4
            sta ad
            lda ad+5
            sta ad+1
            jsr put
            jmp skips
doeiets:    ldy#0
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
allot3:     lda#3
            clc
            adc here
            sta here
            lda here+1
            adc#0
            sta here+1
            rts
allot2:     lda#2
            clc
            adc here
            sta here
            lda#0
            adc here+1
            sta here+1
            rts
nigetal:    jmp werror
doewe:      jmp (ad)
deffind:    .byte 4
            .text "FIND"
            .byte <definterpret
            .byte >definterpret
            jsr findit              // find the word, and put the address on the stack
            jmp put
findit:     jsr skips            // find a word that is pointed to by buffer+intib. Skip spaces
            ldy intib            // current offset in the buffer
            lda buffer,Y         // grab a char
            cmp#13
            beq firet
            lda intib
            sta ad+2
            clc
            adc#<buffer
            sta ad
            lda#0
            adc#>buffer
            sta ad+1
            jsr put              // put the current location on the stack
            jsr normsk           // find the end of the word
            lda intib            // buffer+intib now points to the char after the word
            sec
            sbc ad+2             // subtract the beginning of the word
            sta ad               // ad now contains the length of the word
            jsr msb0
            jsr put              // put the length of the word on the stack
            jsr skips            // skip whitespace
            jsr droptw
            jsr vind             // find the word in the vocabulary
            lda ad               // if not found, ad and ad+1 are zero
            bne firet            // if found, ad and ad+1 contain the address of the code
            lda ad+1
            bne firet
            jmp werror
firet:      rts
definterpret: .byte 9
            .text "INTERPRET"
            .byte <defforget
            .byte >defforget
interpret:  lda #0
            sta intib
intp:       jsr skips
            ldy intib
            lda buffer,Y
            cmp #13
            beq inret
            lda intib
            sta ad+2
            clc
            adc #<buffer
            sta ad
            lda #0
            adc #>buffer
            sta ad+1      // ad, ad+1 now point to the buffer
		                  // ALL IS STILL GOOD HERE
			
			jsr put       // put the start address of the buffer on the stack
            
			
			jsr normsk    // find the end of the word
            lda intib
            sec
            sbc ad+2
            sta ad
            jsr msb0
            jsr put       // put the length on the stack
            jsr skips     // skip spaces
            jsr doe       // execute word
            jmp intp
inret:      rts
defforget:  .byte 6
            .text "FORGET"
            .byte <defstart
            .byte >defstart
forget:     jsr findit
            lda ad+3
            bne forgok
            lda ad+4
            bne forgok
            jmp werror
forgok:     lda ad+3
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
skips:      ldy intib        // skip spaces
            lda buffer,Y
            cmp#32
            bne skret
            inc intib
            jmp skips
skret:      rts
normsk:     ldy intib       // skip chars to find the end of the word
            lda buffer,Y
            cmp#32
            beq nkret
            cmp#13
            beq nkret
            inc intib
            jmp normsk
nkret:      rts
comips:     ldy intib
            lda buffer, Y
            cmp#'\'        // backslash can be used to end a command, this is used in DEF14 ERRDEF definition
            beq comir
            cmp#13
            beq comr
            inc intib
            jmp comips
comir:      lda#13
            sta buffer,Y
            inc intib
comr:       rts
//
// language entry
//
langen:     cmp#1
            beq startlab
            rts
defstart:   .byte 5
            .text "START"
            .byte <definit
            .byte >definit
startlab:    cli
            jsr init
            jmp abort
definit:    .byte 4
            .text "INIT"
            .byte <defrom
            .byte >defrom
init:       lda#<brkk
            sta brkv
            lda#>brkk
            sta brkv+1
            lda#<type 
            sta ervek
            lda#>type
            sta ervek+1
            jsr rom
            lda#0
            sta state
            sta state+1
            sta base+1
            lda #$12
            sta seed
            lda #$34
            sta seed+1
            jmp decimal
defrom:     .byte 3
            .text "ROM"
            .byte <defram
            .byte >defram
rom:        lda herstor
            sta here
            lda herstor+1
            sta here+1
            lda lstor
            sta lwoord
            lda lstor+1
            sta lwoord+1
            rts
defram:     .byte 3
            .text "RAM"
            .byte <defabort
            .byte >defabort
ram:        lda#131
            jsr osbyte
            stx here
            sty here+1
            rts
toev:        lda#126
            jsr osbyte
etxt:       .byte 0
            .byte$11
            .text "Escape"
            .byte 0
defabort:   .byte 5
            .text "ABORT"
            .byte <defquit
            .byte >defquit
abort:       jsr spp
            lda state
            beq qlp
            jsr status
            jmp qlp
defquit:    .byte 4
            .text "QUIT"
            .byte <defdblpunt
            .byte >defdblpunt
qlp:        jsr osnewl            // main query/interpret loop
            ldx#255
            txs
            jsr query
            lda #'-'
            jsr oswrch
            lda #<buffer
            sta ad
            lda #>buffer
            sta ad+1
            jsr interpret
            lda state
            bne qlp
            jsr status
            jmp qlp
//
// error handling
//
// This uses the 6502 BRK instruction.
// The  BRK instruction is followed by a sequence of bytes giving the following information:
// BRK instruction - value &00
// Fault number
// Fault message - may contain any non-zero character
// &00 to terminate message
// When the 6502 encounters a BRK instruction the operating system places the address following the BRK instruction
// in locations &FD and &FE. Thus these locations point to the "Fault number".
// The operating system then indirects via location &202. In other words control is transferred to a routine
// whose address is given in locations &202 (low byte) and &203 (high byte).
// The default routine, whose address is given at the location, prints the fault message.
// See constant brkv which points to 202
//
werrortxt:  .text "UNKNOWN WORD"
            .byte 0
crerrortxt: .text "NOT A GOOD WORD"
            .byte 0
serrortxt:  .text"STACK EMPTY"
            .byte 0
werror:     lda#<werrortxt
            sta ad
            lda#>werrortxt
            sta ad+1
            jmp perror
crerror:    lda#<crerrortxt
            sta ad
            lda#>crerrortxt
            sta ad+1
            jmp perror
serror:     lda#<serrortxt
            sta ad
            lda#>serrortxt
            sta ad+1
perror:     ldy#0
perrorp:    lda (ad),Y
            beq abo
            jsr oswrch
            iny
            jmp perrorp
abo:        jmp abort
in:         lda#<intib
            sta ad
            lda#>intib
            sta ad+1
            jmp put
voegtoe:    jsr skips
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
vlp:        lda buffer,X
            sta (here),Y
            inx
            iny
            cmp#32
            beq voegst
            cmp#13
            bne vlp
voegst:     dey
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
defdblpunt: .byte 1
            .text ":"
            .byte <defpntkomma
            .byte >defpntkomma
dblpnt:     jsr voegtoe
            lda#1
            sta state
            rts
defpntkomma: .byte $81
            .text ";"
            .byte <defcreate
            .byte >defcreate
pntkomma:   lda#$60
            jsr czet
            lda#0
            sta state
            rts
defcreate:  .byte 6
            .text "CREATE"
            .byte <defconstant
            .byte >defconstant
create:     jsr voegtoe
            lda#$20
            jsr czet
            lda#<creac 
            jsr czet
            lda#>creac
            jmp czet
creac:      pla
            clc
            adc#1
            sta ad
            pla
            adc#0
            sta ad+1
            jmp put
defconstant: .byte 8
            .text "CONSTANT"
            .byte <defstt
            .byte >defstt
constant:   jsr voegtoe
            lda#$20
            jsr czet
            lda#<constc 
            jsr czet
            lda#>constc
            jsr czet
            jmp komma
constc:     pla
            clc
            adc#1
            sta ad
            pla
            adc#0
            sta ad+1
            jmp atwrm
defstt:     .byte 5
            .text "STATE"
            .byte <defbse
            .byte >defbse
stt:        lda#<state
            sta ad
            lda#>state
            sta ad+1
            jmp put
defbse:     .byte 4
            .text "BASE"
            .byte <defnulis
            .byte >defnulis
bse:        lda#<base
            sta ad
            lda#>base
            sta ad+1
            jmp put
defnulis:   .byte 2
            .text "0="
            .byte <deftrue
            .byte >deftrue
nulis:      jsr dropit
            lda#0
            cmp ad
            bne nnul
            cmp ad+1
            bne nnul
            jmp truelab
nnul:       jmp falselab
defiss:     .byte 1
            .text "="
            .byte <defnulkl
            .byte >defnulkl
iss:        jsr droptw
            lda ad
            cmp ad+2
            bne falselab
            lda ad+1
            cmp ad+3
            bne falselab
            beq truelab
defnulkl:   .byte 2
            .text "0<"
            .byte <defnulgr
            .byte >defnulgr
nulkl:      jsr dropit
            lda ad+1
            bmi truelab
            bpl falselab
deftrue:    .byte 4
            .text "TRUE"
            .byte <deffalse
            .byte >deffalse
truelab:    ldy#0
            sty ad+1
            iny
            sty ad
            jmp put
deffalse:   .byte 5
            .text "FALSE"
            .byte <defiss
            .byte >defiss
falselab:   lda#0
            sta ad
            sta ad+1
            jmp put
defnulgr:   .byte 2
            .text "0>"
            .byte <defkl
            .byte >defkl
nulgr:      jsr dropit
            lda ad+1
            bmi falselab
            bne truelab
            lda ad
            bne truelab
            beq falselab
defkl:      .byte 1
            .text "<"
            .byte <defgr
            .byte >defgr
kl:         jsr droptw
            lda ad+1
            cmp ad+3
            beq klna
            bpl falselab
            bmi truelab
klna:       lda ad
            cmp ad+2
            bcs falselab
            bcc truelab
defgr:      .byte 1
            .text ">"
            .byte <defimmediate
            .byte >defimmediate
gr:         jsr droptw
            lda ad+1
            cmp ad+3
            beq grna
            bmi falselab
            bpl truelab
grna: lda ad
            cmp ad+2
            beq falselab
            bcs truelab
            bcc falselab
ukl: jsr droptw
            lda ad+1
            cmp ad+3
            beq klna
            bcc truelab
            bcs falselab
defimmediate: .byte 9
             .text "IMMEDIATE"
             .byte <deftprint
             .byte >deftprint
immediate: lda lwoord
            sta ad
            lda lwoord+1
            sta ad+1
            ldy#0
            lda (ad),Y
            ora#$80
            sta (ad),Y
            rts
stcom:        lda#$20           // compile an OS command for execution later
            jsr czet
            lda#<stcode
            jsr czet
            lda#>stcode
            jsr czet
            lda#0
            sta ad+2
            ldy#1
stplp:        lda (ad+6),Y
            cmp#13
            beq stprret
            sta (here),Y
            iny
            jmp stplp
stprret:    sta (here),Y
            tya
            ldy#0
            sta (here),Y
            tay
            iny
            sty ad
            jsr msb0
            jmp alloti
deftprint:  .byte $82
            .text @".\""
            .byte <deftype
            .byte >deftype
tprint:     lda state
            beq tprdoe
            lda#$20
            jsr czet
            lda#<tprintcode
            jsr czet
            lda#>tprintcode
            jsr czet
            lda#0
            sta ad+2
            ldx intib
            ldy#1
tplp:       lda buffer,X
            cmp#13
            beq tprret
            cmp#@"\"".charAt(0)
            beq tpraan
            sta (here),Y
            inc intib
            inx
            iny
            jmp tplp
tpraan:     inc intib
tprret:     dey
            tya
            ldy#0
            sta (here),Y
            tay
            iny
            sty ad
            jsr msb0
            jmp alloti
tprdoe:     ldx intib
            lda buffer,X
            cmp#13
            beq tprdr
            cmp#@"\"".charAt(0)
            beq tprdr
            jsr oswrch
            inc intib
            jmp tprdoe
tprdr:      inc intib
            rts
tprintcode: pla
            clc
            adc#1
            sta ad
            pla
            adc#0
            sta ad+1
            ldy#0
            lda (ad),Y
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
stcode:     pla
            clc
            adc#1
            sta ad
            pla
            adc#0
            sta ad+1
            ldy#0
            lda (ad),Y
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
deftype:    .byte 4
            .text "TYPE"
            .byte <defcls
            .byte >defcls
type:       jsr droptw
typwrm:     lda ad
            clc
            adc ad+2
            sta ad+2
            lda ad+1
            adc ad+3
            sta ad+3
            ldy#0
tyloop:     lda ad
            cmp ad+2
            bne tyhup
            lda ad+1
            cmp ad+3
            bne tyhup
            rts
tyhup:      lda (ad),Y
            jsr oswrch
            clc
            lda#1
            adc ad
            sta ad
            lda#0
            adc ad+1
            sta ad+1
            jmp tyloop
defcls:     .byte 3
            .text "CLS"
            .byte <defexpect
            .byte >defexpect
cls:        lda#12             // clear screen
            jmp oswrch
droptw:     jsr dropit
            lda ad
            sta ad+2
            lda ad+1
            sta ad+3
            jmp dropit
defexpect: .byte 6
            .text "EXPECT"
            .byte <defkomma
            .byte >defkomma
//    EXPECT       addr +n --                    M,83
//           Receive characters and store each into memory.  The transfer
//           begins at addr proceeding towards higher addresses one byte
//           per character until either a "return" is received or until
//           +n characters have been transferred.  No more than +n
//           characters will be stored.  The "return" is not stored into
//           memory.  No characters are received or transferred if +n is
//           zero.  All characters actually received and stored into
//           memory will be displayed, with the "return" displaying as a
//           space.
expect:     jsr droptw
exwrm:      lda ad             // ad, ad+1   contain the buffer address
            sta ad+4           // ad+2, ad+3 contain the max characters to read
            clc
            adc ad+2           // ad+4, ad+5 contain the buffer address (copy of ad, ad+1)
            sta ad+2
            lda ad+1
            sta ad+5
            adc ad+3
            sta ad+3          // now ad+2, ad+3 contain the address of the last readable char
exloop:     lda ad            // check if we reached the max
            cmp ad+2
            bne exhup
            lda ad+1
            cmp ad+3
            beq exrut         // read the max, go to exrut
exhup:      lda#0
            sta intib
            jsr osrdch        // read a character from the keyboard
            cmp#13            // newline?
            beq exret
            cmp#27            // escape?
            beq exesc
            cmp#127           // delete?
            beq exdel
            cmp#32            // less than 32? Special character, ignore
            bcc exloop
            cmp#128           // 128 or more? Special character, ignore
            bcs exloop
            jsr oswrch       // echo the character
            ldy#0
            sta (ad),Y       // store the char in the buffer
            lda#1            // increment ad, ad+1
            clc
            adc ad
            sta ad
            lda#0
            adc ad+1
            sta ad+1
            jmp exloop
exesc:      jmp toev
exret:      jsr spc
exrut:      ldy#0
            lda#13
            sta (ad),Y
            rts
exdel:      lda ad
            cmp ad+4
            bne exdoedel
            lda ad+1
            cmp ad+5
            beq exloop
exdoedel:   sec
            lda ad
            sbc#1
            sta ad
            lda ad+1
            sbc#0
            sta ad+1
            lda#127
            jsr oswrch
            jmp exloop
defkomma:   .byte 1
            .text ","
            .byte <defckomma
            .byte >defckomma
komma:      jsr dropit
komwrm:     ldy#0
            lda ad
            sta (here),Y
            iny
            lda ad+1
            sta (here),Y
            jmp allot2
defckomma:  .byte 2
            .text "C,"
            .byte <defeenplus
            .byte >defeenplus
ckomma:     jsr dropit
ckomwrm:    lda ad
czet:       ldy#0
            sta (here),Y
allotl:     ldx#1
            stx ad
            jsr msb0
            jmp alloti
defeenplus: .byte 2
            .text "1+"
            .byte <defeenmin
            .byte >defeenmin
eenplus:    jsr dropit
eenpluswrm: lda#0
            sec
            adc ad
            sta ad
            lda#0
            adc ad+1
            sta ad+1
            jmp put
defeenmin: .byte 2
            .text "1-"
            .byte <deftweeplus
            .byte >deftweeplus
eenmin: jsr dropit
            lda ad
            clc
            sbc#0
            sta ad
            lda ad+1
            sbc#0
            sta ad+1
            jmp put
deftweeplus: .byte 2
            .text "2+"
            .byte <deftweemin
            .byte >deftweemin
tweeplus:   jsr dropit
            lda#1
            sec
            adc ad
            sta ad
            lda#0
            adc ad+1
            sta ad+1
            jmp put
deftweemin: .byte 2
            .text "2-"
            .byte <defnegate
            .byte >defnegate
tweemin:    jsr dropit
            lda ad
            clc
            sbc#1
            sta ad
            lda ad+1
            sbc#0
            sta ad+1
            jmp put
defnegate: .byte 6
            .text "NEGATE"
            .byte <defmin
            .byte >defmin
negate: jsr dropit
negwrm: lda ad
            eor#$FF
            sta ad
            lda ad+1
            eor#$FF
            sta ad+1
            jmp eenpluswrm
defmin: .byte 1
            .text "-"
            .byte <defmaal
            .byte >defmaal
min: jsr droptw                // subtract
            lda ad
            sec
            sbc ad+2
            sta ad
            lda ad+1
            sbc ad+3
            sta ad+1
            jmp put
maalwrm:    lda#0
            sta ad
            sta ad+1
maloop:     lda ad+2
            bne maok
            lda ad+3
            bne maok
            rts
maok:       lda ad+2
            and#1
            beq masch
            lda ad
            clc
            adc ad+4
            sta ad
            lda ad+1
            adc ad+5
            sta ad+1
masch:      lsr ad+3
            ror ad+2
            asl ad+4
            rol ad+5
            jmp maloop
defmaal:    .byte 1
            .text "*"
            .byte <defupunt
            .byte >defupunt
maal:       jsr droptw
            lda ad
            sta ad+4
            lda ad+1
            sta ad+5
            jsr maalwrm
            jmp put
defupunt: .byte 2
             .text "U."
             .byte <defpunt
             .byte >defpunt
upunt: jsr dropit
upuntwrm:        lda#$FF
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
puntdone:   dex
            bne puntnext
            lda ad+2
            ldy ad
            bne puntnbit
            ldy ad+1
            bne puntnbit
puntout:    cmp#10
            bcc puntadd
            adc#6
puntadd:    adc#48
            jsr oswrch
            pla
            bpl puntout
puntexit:   jmp spc
defpunt:    .byte 1
            .text "."
            .byte <defdecimal
            .byte >defdecimal
punt:       jsr dropit
            lda ad+1
            bpl upuntwrm
            lda #'-'
            jsr oswrch
            lda ad
            eor #$FF
            clc
            adc #1
            sta ad
            lda ad+1
            eor #$FF
            adc #0
            sta ad+1
            jmp upuntwrm
defdecimal: .byte 7
            .text "DECIMAL"
            .byte <deferv
            .byte >deferv
decimal:    lda#10
bazep:      sta base
            lda#0
            sta base+1
            rts
brkk:       lda$FD            // target for the break vector, when an error happens
            clc
            adc#1
            sta ad
            lda$FE
            adc#0
            sta ad+1
            jsr put
            ldy#0
brklp:      lda (ad),Y
            beq brkla
            iny
            bne brklp
brkla:      sty ad
            jsr msb0
            jsr put
            jsr brkin
            jmp abort
brkin:      jmp (ervek)
deferv:     .byte 5
            .text "ERVEK"
            .byte <defdp
            .byte >defdp
erv:        lda#<ervek
            sta ad
            lda#>ervek
            sta ad+1
            jmp put
defdp: .byte 2
             .text "DP"
             .byte <defexit
             .byte >defexit
dp:            lda#<here
            sta ad
            lda#>here
            sta ad+1
            jmp put
defexit: .byte 4
             .text "EXIT"
             .byte <defabs
             .byte >defabs
exit:            lda#$60
            jmp czet
defabs: .byte 3
             .text "ABS"
             .byte <defand
             .byte >defand
abs: jsr dropit
            lda ad+1
            bpl absrt
            jmp negwrm
absrt: jmp put
defand: .byte 3
             .text "AND"
             .byte <defor
             .byte >defor
and: jsr droptw
            lda ad
            and ad+2
            sta ad
            lda ad+1
            and ad+3
            sta ad+1
            jmp put
defor: .byte 2
             .text "OR"
             .byte <defxor
             .byte >defxor
or:                jsr droptw
            lda ad
            ora ad+2
            sta ad
            lda ad+1
            ora ad+3
            sta ad+1
            jmp put
defxor: .byte 3
             .text "XOR"
             .byte <deftick
             .byte >deftick
xor: jsr droptw
            lda ad
            eor ad+2
            sta ad
            lda ad+1
            eor ad+3
            sta ad+1
            jmp put
deftick: .byte 1
             .text "'"
             .byte <defdocode
             .byte >defdocode
tick: jsr findit
tiok: lda ad
            clc
            adc#3
            sta ad
            lda ad+1
            adc#0
            sta ad+1
            jsr put
            lda state
            beq ticklr
            jmp literal
ticklr: rts
defdocode: .byte 4
             .text "(DO)"
             .byte <defplusloopcode
             .byte >defplusloopcode
docode: jsr droptw
            pla
            tax
            pla
            tay
            lda ad+1
            pha
            lda ad
            pha
            lda ad+3
            pha
            lda ad+2
            pha
            tya
            pha
            txa
            pha
            rts
defplusloopcode: .byte 7
             .text "(+LOOP)"
             .byte <defloopcode
             .byte >defloopcode
plusloopcode: jsr dropit
            pla
            tax
            pla
            tay
            pla
            clc
            adc ad
            sta ad+2
            pla
            adc ad+1
            jmp looprest
defloopcode: .byte 6
             .text "(LOOP)"
             .byte <defhex
             .byte >defhex
loopcode: pla
            tax
            pla
            tay
            pla
            clc
            adc#1
            sta ad+2
            pla
            adc#0
looprest: sta ad+3
            pla
            sta ad
            pla
            sta ad+1
            lda ad+3
            cmp ad+1
            beq loopna
            bmi loopvlg
loopkla: txa
            clc
            adc#3
            tax
            tya
            adc#0
            pha
            txa
            pha
            rts
loopna: lda ad+2
            cmp ad
            bcs loopkla
loopvlg: lda ad+1
            pha
            lda ad
            pha
            lda ad+3
            pha
            lda ad+2
            pha
            tya
            pha
            txa
            pha
            rts
defhex: .byte 3
             .text "HEX"
             .byte <defrnd
             .byte >defrnd
hex: lda#16
            jmp bazep
defrnd: .byte 3
             .text "RND"
             .byte <defhcompile
             .byte >defhcompile
rnd:            ldy#$20
rndnext:         lda seed+2
            lsr
            lsr
            lsr
            eor seed+4
            ror
            rol seed
            rol seed+1
            rol seed+2
            rol seed+3
            rol seed+4
            dey
            bne rndnext
            lda seed
            sta ad
            lda seed+1
            sta ad+1
            jmp put
sed: jsr droptw
            lda ad
            sta seed
            sta seed+4
            lda ad+1
            sta seed+1
            lda ad+2
            sta seed+2
            lda ad+3
            sta seed+3
            rts
defhcompile: .byte $89
             .text "[COMPILE]"
             .byte <defcompile
             .byte >defcompile
hcompile:   jsr findit
            jsr put
            lda#$20
            jsr czet        
            jmp komma
defcompile: .byte $87
            .text "COMPILE"
            .byte <defsave
            .byte >defsave
compile:    jsr findit
            jsr put
            lda#$20
            jsr czet
            lda#<compcode
            jsr czet
            lda#>compcode
            jsr czet
            jmp komma
compcode: lda#$20
            jsr czet
            pla
            clc
            adc#1
            sta ad+2
            sta ad
            pla
            adc#0
            sta ad+1
            sta ad+3
            jsr atwrm
            jsr komma
            lda ad+2
            clc
            adc#1
            tax
            lda ad+3
            adc#0
            pha
            txa
            pha
            rts
defsave: .byte 4
             .text "SAVE"
             .byte <defsaveready
             .byte >defsaveready
save:        jsr saveready
            lda#<buffer
            clc
            adc intib
            sta pad
            lda#>buffer
            adc#0
            sta pad+1           // pad and pad+1 point to the target filename
            lda#$FF
            sta pad+4
            sta pad+5
            sta pad+8
            sta pad+9
            sta pad+$C
            sta pad+$D
            sta pad+$10
            sta pad+$11
            lda#0
            sta pad+2            // pad+2,3,4,5 contain the load address $FFFF8000
            sta pad+6            // pad+6,7,8,9 contain the execution address $FFFF8000
            sta pad+$A           // pad+$A,$B,$C,$d contain the start address $FFFF1900
            lda#$80                 
            sta pad+3
            sta pad+7
            lda #$19              // this assumes the ROM contents have been moved to 1900
            sta pad+$B
            lda here
            sta pad+$E            // pad+$E,$F,$10,$11 contain end address: here (top 16 bits all set: $FFFFhhhh)
            lda here+1
            sbc #($80 - $19 -1)
            sta pad+$F
            jsr normsk
            lda#0                // function code 0, meaning SAVE
            ldx#<pad             // x and y point to pad, which contains the control block for OSFILE
            ldy#>pad
            jmp osfile
defsaveready: .byte 9
             .text "SAVEREADY"
             .byte <defrot
             .byte >defrot
saveready:    lda here            // save HERE and LWOORD in herstor and lstor as preparation for save
            sta herstor
            lda here+1
            sta herstor+1
            lda lwoord
            sta lstor
            lda lwoord+1
            sta lstor+1
            rts
defrot: .byte 3
             .text "ROT"
             .byte <defleave
             .byte >defleave
rot: jsr droptw
            lda ad
            pha
            lda ad+1
            pha
            jsr dropit
            lda ad
            sta ad+4
            lda ad+1
            sta ad+5
            pla
            sta ad+1
            pla
            sta ad
            jsr put
            lda ad+2
            sta ad
            lda ad+3
            sta ad+1
            jsr put
            lda ad+4
            sta ad
            lda ad+5
            sta ad+1
            jmp put
defleave: .byte 5
             .text "LEAVE"
             .byte <deftwee
             .byte >deftwee
leave: pla
            tax
            pla
            tay
            pla
            pla
            pla
            sta ad+2
            pla
            sta ad+3
            pha
            lda ad+2
            pha
            lda ad+3
            pha
            lda ad+2
            pha
            tya
            pha
            txa
            pha
            rts
deftwee: .byte 1
             .text "2"
             .byte <defdrie
             .byte >defdrie
twee: lda#2
mbput: sta ad
            jsr msb0
            jmp put
defdrie: .byte 1
             .text "3"
             .byte <defdeel
             .byte >defdeel
drie: lda#3
            bne mbput
deelo:        jsr droptw
            lda ad+1
            bpl dpos
            lda #1
            sta ad+6      //  store 1 for negative in ad+6
            lda ad
            eor #$FF
            sta ad
            lda ad+1
            eor #$FF
            sta ad+1
            lda ad
            clc
            adc #1
            sta ad
            lda ad+1
            adc #0
            sta ad+1
            jmp dpass
dpos:        lda #0
            sta ad+6      // store 0 for positive in ad+6
dpass:        lda ad+3
            bpl dpos2
            lda #1
            sta ad+7      // store 1 for negative in ad+7
            lda ad+2
            eor #$FF
            sta ad+2
            lda ad+3
            eor #$FF
            sta ad+3
            lda ad+2
            clc
            adc #1
            sta ad+2
            lda ad+3
            adc #0
            sta ad+3
            jmp dpass2
dpos2:        lda #0
            sta ad+7      // store 0 for positive in ad+7
dpass2:        lda#0
            sta ad+4
            sta ad+5
            ldx#16        // step through this loop 16 times
dlnext:        asl ad        // ad and ad+1 contains the dividend
            rol ad+1      // ad+2 and ad+3 contain the divisor
            rol ad+4      // ad+4 and ad+5 contain the modulo
            rol ad+5
            lda ad+4      // try to subtract ad+2,3 from ad+4,5
            sec
            sbc ad+2
            tay
            lda ad+5
            sbc ad+3
            bcc dldone    // if the result is negative, no subtraction is done and the loop starts again
            inc ad        // positive result. Store in ad+4,5 and increment ad
            sty ad+4
            sta ad+5
dldone:        dex
            bne dlnext
            lda ad+6
            eor ad+7
            beq dlrts
            lda ad     // one of the flags is 1. negate again
            eor #$FF
            sta ad
            lda ad+1
            eor #$FF
            sta ad+1
            sec
            lda ad
            adc #0
            sta ad
            lda ad+1
            adc #0
            sta ad+1
            lda ad+4
            eor #$FF
            sta ad+4
            lda ad+5
            eor #$FF
            sta ad+5
            sec
            lda ad+4
            adc #0
            sta ad+4
            lda ad+5
            adc #0
            sta ad+5
dlrts:        rts
defdeel: .byte 1
             .text "/"
             .byte <defmod
             .byte >defmod
deel: jsr deelo
            jmp put
defmod: .byte 3
             .text "MOD"
             .byte <defbranch0
             .byte >defbranch0
mod: jsr deelo
            lda ad+4
            sta ad
            lda ad+5
            sta ad+1
            jmp put
deelmod: jsr deelo
            lda ad
            pha
            lda ad+1
            pha
            lda ad+4
            sta ad
            lda ad+5
            sta ad+1
            jsr put
            pla
            sta ad+1
            pla
            sta ad
            jmp put
vrdup: jsr dropit
            jsr put
            lda ad
            bne vrnk
            lda ad+1
            bne vrnk
            rts
vrnk: jmp dup
defbranch0: .byte 7
             .text "0BRANCH"
             .byte <defcall
             .byte >defcall
branch0: jsr dropit
            lda ad
            bne bra
            lda ad+1
            bne bra
            rts
bra: pla
            clc
            adc#3
            tax
            pla
            adc#0
            pha
            txa
            pha
            rts
defcall: .byte 4
             .text "CALL"
             .byte <defpad
             .byte >defpad
call: jsr droptw
            lda ad
            pha
            jsr dropit
            ldx ad
            ldy ad+1
            pla
            jsr calli
            pha
            stx ad
            sty ad+1
            jsr put
            pla
            sta ad
            lda#0
            sta ad+1
            jmp put
calli: jmp (ad+2)
osc: jsr dropit
            ldx ad
            ldy ad+1
            jmp oscli
defpad: .byte 3
             .text "PAD"
             .byte <deftweemaal
             .byte >deftweemaal
padad: lda#<pad
            sta ad
            lda#>pad
            sta ad+1
            jmp put
deftweemaal: .byte 2
             .text "2*"
             .byte <deftweedeel
             .byte >deftweedeel
tweemaal: jsr dropit
            asl ad
            rol ad+1
            jmp put
deftweedeel: .byte 2
             .text "2/"
             .byte <defcmove
             .byte >defcmove
tweedeel: jsr dropit
            lsr ad+1
            ror ad
            jmp put
dropdr: jsr dropit
            lda ad
            sta ad+4
            lda ad+1
            sta ad+5
            jsr dropit
            lda ad
            sta ad+2
            lda ad+1
            sta ad+3
            jmp dropit
defcmove: .byte 5
             .text "CMOVE"
             .byte <defdoes
             .byte >defdoes
cmove: jsr dropdr
cmowrm: lda ad+1
            cmp ad+3
            beq cmna
            bcc cmoveop
            bcs cmoveneer
cmna: lda ad
            cmp ad+2
            bcs cmoveneer
cmoveop: lda ad+4
            clc
            adc ad
            sta ad
            lda ad+5
            adc ad+1
            sta ad+1
            lda ad
            sec
            sbc#1
            sta ad
            lda ad+1
            sbc#0
            sta ad+1
            lda ad+2
            clc
            adc ad+4
            sta ad+2
            lda ad+3
            adc ad+5
            sta ad+3
            lda ad+2
            sec
            sbc#1
            sta ad+2
            lda ad+3
            sbc#0
            sta ad+3
            ldy#0
cmdlp: lda ad+4
            bne cmdok
            lda ad+5
            bne cmdok
            rts
cmdok: jsr cmhup
            dey
            cpy#$FF
            bne cmdlp
            dec ad+1
            dec ad+3
            jmp cmdlp
cmoveneer: ldy#0
cmnlp: lda ad+4
            bne cmnok
            lda ad+5
            bne cmnok
            rts
cmnok: jsr cmhup
            iny
            bne cmnlp
            inc ad+1
            inc ad+3
            jmp cmnlp
cmhup: lda (ad),Y
            sta (ad+2),Y
            lda ad+4
            sec
            sbc#1
            sta ad+4
            lda ad+5
            sbc#0
            sta ad+5
            rts
plusuit: jsr droptw
            ldy#0
            lda (ad+2),Y
            clc
            adc ad
            sta (ad+2),Y
            iny
            lda (ad+2),Y
            adc ad+1
            sta (ad+2),Y
            rts
defdoes: .byte 5
             .text "DOES>"
             .byte <defdrop
             .byte >defdrop
does: lda#$20
            jsr czet
            lda#<doeseen
            jsr czet
            lda#>doeseen
            jsr czet
            lda#$20
            jsr czet
            lda#<doestwee
            jsr czet
            lda#>doestwee
            jmp czet
doeseen: ldy#0
            lda (lwoord),Y
            and#$7F
            clc
            adc lwoord
            sta ad
            lda lwoord+1
            adc#0
            sta ad+1
            lda ad
            clc
            adc#4
            sta ad
            lda ad+1
            adc#0
            sta ad+1
            pla
            clc
            adc#1
            ldy#0
            sta (ad),Y
            iny
            pla
            adc#0
            sta (ad),Y
            rts
doestwee: pla
            tax
            pla
            tay
            pla
            clc
            adc#1
            sta ad
            pla
            adc#0
            sta ad+1
            tya
            pha
            txa
            pha
            jmp put
dad: lda#ad
            sta ad
            jsr msb0
            jmp put
defdrop: .byte 4
             .text "DROP"
             .byte <defword
             .byte >defword
drop: lda depth
            beq serj
            dec depth
vrrt: rts
serj: jmp serror
vresc: lda$FF
            and#$80
            beq vrrt
            jmp toev
rdrop: pla
            tax
            pla
            tay
            pla
            pla
            tya
            pha
            txa
            pha
            rts
rp: pla
            tay
            pla
            ldx#255
            txs
            pha
            tya
            pha
            rts
defword: .byte 4
             .text "WORD"
             .byte <defhexdump
             .byte >defhexdump
/* WORD           char -- addr                  181
     Receive  characters  from the input stream until the  non-zero
     delimiting  character  is encountered or the input  stream  is
     exhausted,  ignoring leading delimiters.   The characters  are
     stored  as  a  packed string with the character count  in  the
     first  character position.   The actual delimiter  encountered
     (char  or  null)  is stored at the end of  the  text  but  not
     included  in the count.   If the input stream was exhausted as
     WORD is called,  then a zero length will result.   The address
     of the beginning of this packed string is left on the stack. */
word: jsr dropit
            lda ad
            pha
            jsr padad
            pla
            sta ad
            ldx intib
worlp:        lda buffer,X
            cmp#13
            beq worret
            cmp ad
            beq worret
            inx
            bne worlp
worret:     lda#<buffer
            clc
            adc intib
            sta ad
            lda#>buffer
            adc#0
            sta ad+1
            lda#<(pad+1)
            sta ad+2
            lda#>(pad+1)
            sta ad+3
            txa
            sec
            sbc intib
            sta pad
            sta ad+4
            lda#0
            sta ad+5
            lda buffer,X
            cmp#13
            beq worsla
            inx
worsla:     stx intib
            jsr cmowrm
            jmp skips
defhexdump: .byte 7                // print a hexdump starting with the address 
            .text "HEXDUMP"        // of the top of the stack for 16 bytes
            .byte 0
            .byte 0
hexdump:    jsr dropit
hexdumpi:   ldy#0
hexloop:    lda (ad),Y
            tax
            and #$f0                // grab the higher nibble
            lsr
            lsr
            lsr
            lsr
            jsr hpuntout
            txa
            and #$f                 // lower nibble
            jsr hpuntout
            jsr spc
            iny
            cpy #17
            bne hexloop
            lda #$D
            jsr oswrch
            lda #$A
            jsr oswrch
            rts
hpuntout:   cmp#10
            bcc hpuntadd      // less than 10
            adc#('A' - 11)    // since carry = 1, we add one less
            jmp oswrch
hpuntadd:   adc#'0'
            jmp oswrch
romhwm:
