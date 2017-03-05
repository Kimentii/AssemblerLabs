.model small
.stack 100h
.data    

len     db 200                      ;const max size of string
res     db 0
string  db 200 dup('$')             ;string for work
number  db 'number$'                ;word to insert, '$' is end of string
.code    

shift   macro                       ;macros which shift 6 symbols
cld
mov        di, si                   ;si is pointer on begin of shift place
xor        cx, cx
aa1:
mov        bl, byte ptr [si]        ;bl is simbol from si(byte ptr mean that si points on byte)
cmp        bl, '$'                  ;compare bl and '$'
je         aa2 
inc        cx                       ;cx is size of string
inc        si
jmp        aa1
aa2:
inc        cx
mov        di, si                   ;now si points on end of string
add        di, 6                    ;make our string large on 6 symbols
aa3:                                ;this loop move string on 6 symbols in right
mov        bl, byte ptr [si]        ;si points on end of string+6
mov        byte ptr [di], bl        ;di points on end of string
dec        si
dec        di
loop       aa3
endm


copy    macro                       ;this macros wirite "number" in our string
cld                                 ;cleen flags
lea        si, number
mov        cx, 6
rep        movsb                    ;this function copy string from si to di
endm


find    macro                       ;macros finds numbers, ax is begin of number(or 0)
mov        di, si                   ;si point on begin of the string
mov        bl, 1                    ;bl if flag. If it is true then we found number
aastart:
mov        ah, byte ptr[si]
cmp        ah, 13                   ;13 is end of line
je         end_of_string
cmp        ah, ' '                  ;if ah is ' ' then 
je         parse_word               
jmp        check_symbol
parse_word:
cmp        bl, 1                    ;if bl is true then we have found number
je         find_num
mov        bl, 1
inc        si                               
mov        di, si
jmp        check_symbol
find_num:
mov        ax, di                   ;ax point on begin of number
jmp end
end_of_string:
cmp        bl, 1
je         find_num
mov        ax, 0
jmp end
check_symbol:                                 
mov        ah, byte ptr[si]
cmp        ah, '0'
jl         not_find
cmp        ah, '9'
jg         not_find
inc        si
jmp        aastart                  ;symbol is number
not_find:                         
mov        bl, 0
inc        si
jmp        aastart 
end:
endm



newline    macro                    
mov        dl,13                    ;newline symbol
mov        ah,2                     ;ah=2 is function which put symbol on the screen 
int        21h     
mov        dl,10                    ;10 symbol - start write from begin of line
mov        ah,2   
int        21h
endm



input macro                         ;input string
mov        ah,10
int        21h
endm



output macro                        ;show string
mov        ah, 9
int        21h
endm



do    macro                         ;main macros
lea        si, string
cc1:
push       si
find                                
pop        si
cmp        ax, 0                    ;ax point on begin of number
je         cc2
mov        si, di
push       di                       ;di point on beging of world "number", whick we will insert
shift        
pop        di
copy                                ;write wrold "number" before number
lea        si, string               ;we begin find numbers from begin of string
jmp        cc1
cc2:
endm


start:
mov        ax, @data
mov        ds, ax
mov        es, ax
xor        ax, ax
mov        dx, offset len
input
do
newline
mov        dx, offset string
output
mov        ah, 0                      ;wait symbol
int        16h
mov        ah, 4Ch
mov        al, 0
int        21h
end        start