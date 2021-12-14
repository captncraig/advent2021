.var chrin=$ffe4
.var screenmem=$0400
.var cls=$e544
.var black=$0
.var white=$1
.var border=$d020
.var bg=$d021
.var txtcol=$0286
.var gens=$02

.var generations=screenmem+(40*16)+13
.var total_flash=screenmem+(40*17)+15
.var total_flash_100=screenmem+(40*18)+22
.var sync_gen=screenmem+(40*19)+15
.var colormem=$d800
.var colordiff=(colormem-screenmem)

BasicUpstart2(start)
*=$2000
start:
jsr cls

jsr print_sync
jsr print_gen
jsr print_total
jsr print_100

//normalize chars to actual integers
ldx #00
sub48:
    lda cells,x
    beq runsim
    sec
    sbc #48
    sta cells,x
    inx
    jmp sub48

// this is the main loop!
runsim:
    ldx gens
    cpx #100
    bne run2
    lda #1
    sta done100
    colorcounter(total_flash_100,7)
run2:
    inx
    stx gens
    inccounter(generations)
    jsr incsync
    jsr run_gen
    jsr checksync
    jsr printcells
    jsr delay
    jmp runsim
    
// run a single generation
run_gen:
// first increment all cells
ldx #0
inc_all:
    jsr incr_1
    inx
    cpx #144
    bne inc_all
// now process flash stack until empty
flash_all:
    ldx flash_sp
    beq flash_done
    dex
    stx flash_sp
    stx scratch
    //increment total counter (2 bytes)
    jsr incflash
    ldx scratch
    // now load flash target
    lda flashers,x 
    sta scratch
    lda #0
    sta flashers,x
    lda scratch
    //tl
    sec;sbc #13
    tax;jsr incr_1
    // top
    clc;adc #1
    tax;jsr incr_1
    // tr
    clc;adc #1
    tax;jsr incr_1
    // r
    clc;adc #12
    tax;jsr incr_1
    // l
    sec;sbc #2
    tax;jsr incr_1
    // bl
    clc;adc #12
    tax;jsr incr_1
    // b
    clc;adc #1
    tax;jsr incr_1
    // br
    clc;adc #1
    tax;jsr incr_1
    jmp flash_all
flash_done:
    ldx #0
clr_flashed:
    cpx #144
    beq cleared
    lda cells,x
    inx
    cmp #$f0
    beq clr_flashed
    cmp #10
    bcc clr_flashed
    lda #0
    dex
    sta cells,x
    inx
    jmp clr_flashed
cleared:
    rts

// incr_1 increments a single cell. If it moves to exactly 10, it will add it to the flash stack. index from x
incr_1:
    sta scratch
    lda cells,x
    cmp #$f0
    beq incr_1_0
    clc
    adc #1
    sta cells,x
    cmp #10
    bne incr_1_0
    // add to flash stack if exactly 10
    ldy flash_sp
    txa
    sta flashers,y
    iny
    sty flash_sp
incr_1_0:
    lda scratch
    rts

incflash:
    inccounter(total_flash)
    ldx done100
    bne incflash_ex
    inccounter(total_flash_100)
incflash_ex:
    rts

incsync:
    ldx nsync
    bne incsync_final
    inccounter(sync_gen)
    rts

incsync_final:
    colorcounter(sync_gen,13)
    rts



// printcells subroutine to render output
printcells:
    ldx #0
pc0:
    .for(var row=0;row<12;row++){
        .for(var col=0; col<12; col++){
            .var screenaddr=screenmem+(40*row)+col
            .var cell = cells+(12*row)+col
            lda cell
            clc
            tax
            adc #48
            sta screenaddr
            .var coloraddr = $D800+(40*row)+col
            lda #0
            cpx #0
            bne c2
            lda #3
            c2:
            sta coloraddr
        }
    }
    rts

checksync:
    .for(var row=1;row<11;row++){
        .for(var col=1; col<11; col++){
            .var cell = cells+(12*row)+col
            lda cell
            beq okfornow
            jmp nope
            okfornow:
            nop
        }
    }
    yep:
    lda #1
    sta nsync
    nope:
    rts
// data section
*=$820
cells:
// example
//.text "             5483143223  2745854711  5264556173  6141336146  6357385478  4167524645  2176841721  6882881134  4846848554  5283751526             "
// mine
.text "             4871252763  8533428173  7182186813  2128441541  3722272272  8751683443  3135571153  5816321572  2651347271  7788154252             "
.byte 0
flashers: .fill 101, 0
flash_sp: .byte 0
scratch: .byte 0
total: .byte 0,0
total_gens: .byte 0,0

done100: .byte 0
nsync: .byte 0

gen_text: .text "current gen: ";.byte 0
tot_text: .text "total flashes: ";.byte 0
after_text: .text "after generation 100: ";.byte 0
sync_text: .text "first synced: ";.byte 0

// print string at $fb,$fc at screenbuffer row x (fd,fe used for adde)
print_str:
    // screen buffer addr base
    lda #((screenmem) & $00ff)
    sta $fd
    lda #((screenmem) >> 8)
    sta $fe
    //add 40 for each row
findrow:
    cpx #0
    beq foundrow
    dex
    lda $fd
    clc; adc #40;sta $fd
    lda $fe; adc #0;sta $fe
    jmp findrow
foundrow:
    ldy #0
pstr_0:
    lda ($fb),y
    beq pstr_1
    sta ($fd),y
    iny
    jmp pstr_0
pstr_1:
    rts

.macro initcounter(addr){
    lda #48
    sta addr
    sta addr+1
    sta addr+2
    sta addr+3
}
.macro inccounter(addr){
    .for(var p=3;p>=0;p--){
        ldx addr+p
        inx
        stx addr+p
        cpx #58
        bne outro
        ldx #48
        stx addr+p
    }
    outro:
}
.macro colorcounter(addr,color){
    lda #color
    sta addr+colordiff
    sta addr+colordiff+1
    sta addr+colordiff+2
    sta addr+colordiff+3
}


print_total:
    lda #(tot_text & $00ff)
    sta $fb
    lda #(tot_text >> 8)
    sta $fc
    ldx #17
    jsr print_str
    initcounter(total_flash)
    rts


print_gen:
    lda #(gen_text & $00ff)
    sta $fb
    lda #(gen_text >> 8)
    sta $fc
    ldx #16
    jsr print_str
    initcounter(generations)
    colorcounter(generations,2)
    rts


print_100:
    lda #(after_text & $00ff)
    sta $fb
    lda #(after_text >> 8)
    sta $fc
    ldx #18
    jsr print_str
    initcounter(total_flash_100)
    colorcounter(total_flash,1)
    rts

print_sync:
    lda #(sync_text & $00ff)
    sta $fb
    lda #(sync_text >> 8)
    sta $fc
    ldx #19
    jsr print_str
    initcounter(sync_gen)
    colorcounter(sync_gen,4)
    rts

delay:
rts
ldx #5
ldy #5
delay_0:
    cpx #0
    beq delay_1
    dex
    .for(var row=0;row<12;row++){
        nop
    }
    jmp delay_0
delay_1:
    cpy #0
    beq delay_2
    dey
    ldx #255
    jmp delay_0
delay_2:
rts