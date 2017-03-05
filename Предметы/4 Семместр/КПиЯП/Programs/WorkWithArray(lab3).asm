;программа считывает одно число(после числа пробел), преобразует его в число, измен€ет его, выводит в строку c числами 
;ѕрограмма может выполн€ть: возведение в квадрат, инверси€, вз€тие модул€
;„исла надо вводить до 255
;si это куда нужно вписывать новый массив
.model small
.stack 100h
.data     
string db 200 dup('$')          ;input string
array db 200 dup('$')           ;output string
num_size dw '?'                 ;size of number
choise db '?'                   ;symbol of function
welcome db "Enter string:", 10, 13, '$'
your_string db "Your string is:", 10, 13, '$'
enter_choise db "Enter your choise('^' is squaring, 'i' is inversion, 'm' is modul): ", 10, 13, "$"
minus db 0                     ;minus flag

make_choise macro chs           ;input choise
    push ax
    mov ah, 01h                 ;input symbol in al
    int 21h
    mov chs, al
    pop ax
endm

newline macro                   ;make newline
    push dx
    push ax
    mov dl, 13                  ;13 is askii of '\n'
    mov ah, 02h
    int 21h
    mov dl, 10                  ;10 is askii of begin of string
    int 21h
    pop ax
    pop dx
endm

input macro str                 ;input string
    push dx
    push ax        
    lea dx, str
    mov ah, 0Ah
    int 21h
    pop ax 
    pop dx
endm
                                    
output macro str                ;output stirng
    push dx
    push ax  
    lea dx, str
    mov ah, 09h
    int 21h
    pop ax 
    pop dx
endm

stoi proc near                  ;input: AX is size of number, DI is string. output: AX is number
    push di
    push cx
    push bx
    push dx
    mov cx, ax
    mov bl, 10
    xor ax, ax
    xor bh, bh
    cmp [di], '-'               ;if number is negative
    jne next_char
    mov minus, 1                ;push minus flag true
    inc di
    dec cx
next_char:
    mul bl                      ;multiply AL on BL, result in AX
    mov dl, [di]                ;take new askii code of symbol
    sub dl, 30h                 ;make it  numeral
    add ax, dx                  ;add our numeral to number
    inc di
    loop next_char
    pop dx
    pop bx
    pop cx
    pop di
ret
stoi endp
       
itos proc                        ;input: AX is number, output: SI is string with number
    push cx
    push bx
    push dx 
    mov cx, 5                    ;it can't be more than 5 numerlas
    xor bx, bx 
    mov bx, 10
new_symbol: 
    xor dx, dx
    div bx                       ;rest in AX, integer part in AX 
    add dx, 30h                  ;make from numeral symbol
    push dx
    loop new_symbol
    mov cx, 5
write_number:
    pop dx                       ;take symbol
    mov [si], dx                 ;put it in the string
    inc si
    loop write_number
    inc si
    mov [si], ' '
    pop dx
    pop bx
    pop cx 
ret
itos endp

find proc                         ;find of number
    push di
    push cx
    push bx
    push dx
    push ax 
    lea dx, string+2
    lea di, string+2 
new_number:
    mov num_size, 0
count:                            ;count number of numerals in number
    mov bl, [di]
    cmp bl, 13                    ;is it end of string?
    je end_find                   
    cmp bl, ' '                   ;is it end of number?
    je end_number
    inc num_size
    inc di
    jmp count     
end_number:
    mov ax, num_size              
    inc di
    push di
    mov di, dx                    ;DX is begin of number
    call stoi                     ;make from string number
    cmp choise, '^'               ;choice of function
    je  squaring_ch
    cmp choise, 'i'
    je  inversion_ch
    cmp choise, 'm'
    je  modul_ch
squaring_ch:
    call squaring
    call itos
    jmp end_choise
inversion_ch:
    call inversion  
    jmp end_choise
modul_ch:
    call itos
end_choise:
    pop di                         ;DI point on new number
    mov dx, di                     ;now DX point on new number too
    jmp new_number
end_find:
    pop ax
    pop dx
    pop bx
    pop cx
    pop di 
ret
find endp

squaring proc                      ;возведение в квадрат
    mul al                         ;AL*AL, result in AX
ret
squaring endp 

inversion proc                     ;inversion
    push cx
    push bx
    push dx
    cmp minus, 1
    jne positiv
    dec num_size
    mov [si], '-'                  ;push minus is the string
    inc si
    mov minus, 0
positiv: 
    mov cx, num_size
    xor bx, bx 
    mov bx, 10
new_numeral: 
    xor dx, dx
    div bx                          ;AX/BX, result in DX
    push dx
    loop new_numeral
    mov cx, num_size
invers:
    mov bl, 10
    pop dx
    sub bl, dl                      ;in BL is inverse number
    add bl, 30h                     ;make from number symbol
    mov [si], bl
    inc si
    loop invers
    mov [si], ' '
    inc si
    pop dx
    pop bx
    pop cx 
ret
inversion endp

start:                             
    mov ax, @data
    mov ds, ax
    lea si, array
    output welcome
    input string                    ;input stirng
    newline
    output your_string              
    output string+2
    newline
    output enter_choise 
    make_choise choise              ;making choise
    newline
    call find
    output array
    mov ah, 4Ch
    int 21h
end start