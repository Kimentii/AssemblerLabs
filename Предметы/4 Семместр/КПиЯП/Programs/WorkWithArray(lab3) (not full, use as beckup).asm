;программа считывает одно число(после числа пробел), преобразует его в число и выводи в строку c числами 
;Программа может выполнять: возведение в квадрат, инверсия
;Числа надо вводить до 255
;si это куда нужно вписывать число
.model small
.stack 100h
.data     
string db 200 dup('$')  
array db 200 dup('$') 
num_size dw '?'
choise db '?'
welcome db "Enter string:", 10, 13, '$'
your_string db "Your string is:", 10, 13, '$'
enter_choise db "Enter your choise('^' is squaring, 'i' is inversion): ", 10, 13, "$"
minus db '0'

make_choise macro chs           ;выбор функции
    push ax
    mov ah, 01h
    int 21h
    mov chs, al
    pop ax
endm

newline macro                   ;перевод курсора на новую линию
    push dx
    push ax
    mov dl, 13
    mov ah, 02h
    int 21h
    mov dl, 10
    int 21h
    pop ax
    pop dx
endm

input macro str                 ;ввод строки
    push dx
    push ax        
    lea dx, str
    mov ah, 0Ah
    int 21h
    pop ax 
    pop dx
endm
                                    
output macro str                ;вывод строки
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
    cmp [di], '-'
    jne next_char
    mov minus, 1
    inc di
    dec cx
next_char:
    mul bl                      ;multiply AL on BL, result in AX
    mov dl, [di]
    sub dl, 30h
    add ax, dx
    inc di
    loop next_char
    pop dx
    pop bx
    pop cx
    pop di
ret
stoi endp
       
itos proc                        ;ax is number, si is string for write
    push cx
    push bx
    push dx 
    mov cx, 5                    ;число может получиться максимум 5  символов
    xor bx, bx 
    mov bx, 10
new_symbol: 
    xor dx, dx
    div bx 
    add dx, 30h
    push dx
    loop new_symbol
    mov cx, 5
write_number:
    pop dx
    mov [si], dx
    inc si
    loop write_number
    inc si
    mov [si], ' '
    pop dx
    pop bx
    pop cx 
ret
itos endp

find proc                         ;поиск числа
    push di
    push cx
    push bx
    push dx
    push ax 
    lea dx, string+2
    lea di, string+2 
new_number:
    mov num_size, 0
count:
    mov bl, [di]
    cmp bl, 13
    je end_find
    cmp bl, ' '
    je end_number
    inc num_size
    inc di
    jmp count     
end_number:
    mov ax, num_size
    inc di
    push di
    mov di, dx 
    call stoi
    cmp choise, '^'
    je  squaring_ch
    cmp choise, 'i'
    je  inversion_ch  
squaring_ch:
    call squaring
    call itos
    jmp end_choise
inversion_ch:
    call inversion
end_choise:
    pop di
    mov dx, di 
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
    mul al
ret
squaring endp 

inversion proc                     ;процедура инверсии
    push cx
    push bx
    push dx
    cmp minus, 1
    jne positiv
    dec num_size
    mov cx, num_size
    mov [si], '-'
    inc si
    xor bx, bx 
    mov bx, 10
    mov minus, 0
    jmp new_numeral 
positiv: 
    mov cx, num_size
    xor bx, bx 
    mov bx, 10
new_numeral: 
    xor dx, dx
    div bx
    push dx
    loop new_numeral
    mov cx, num_size
invers:
    mov bl, 10
    pop dx
    sub bl, dl
    add bl, 30h
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
    input string
    newline
    output your_string
    output string+2
    newline
    output enter_choise 
    make_choise choise
    newline
    call find
    output array
    mov ah, 4Ch
    int 21h
end start