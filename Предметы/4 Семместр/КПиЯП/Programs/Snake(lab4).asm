;���� ���� �������: 48h - �����, H 4Bh - �����, K 4Dh - ������, M 50h - ����, P 
.model   small 
.data                    ;���������� ������
snake   dw 0000h
        dw 0001h
        dw 0002h
        dw 0003h
        dw 0004h
        dw 7CCh dup('?')
tick    dw 0             ;�������, ���� ������ ����� ������ 5, �� ���� �����������
points_num dw 0
points   db 10 dup('?')
.stack 100h
.code
 
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
    mov [si], 2                  ;������� �������
    inc si
    loop write_number
    inc si
    mov [si], ' '
    pop dx
    pop bx
    pop cx 
ret
itos endp

show_points proc 
    push ax  
    push bp
    push cx 
    push si
    push dx      
    lea si, points       
    mov ax, points_num   ;��������� � �� ����� �����
    call itos            ;����������� ����� � ������
    mov dh, 17h          ;���������� ������ �����
    mov dl, 0            
    lea bp, points       ;������ ��� ������
    mov cx, 5            ;������� � �� ������ ������
    mov ax, 1303h        ;������� 13 - ������� ����, 3 - ��� ����������
    int 10h              ;������� ������              
    pop dx
    mov ax,0200h
    int 10h              ;���������� ������ �� �����
    pop si
    pop cx 
    pop bp
    pop ax
    ret
show_points endp

;0FF00h - �����, 0100h - ����, 0FFFFh - ����, 0001h  - ����� (0FF00 - ��� "-1" ��� ������� ����� � ���. ����)
key_press proc           ;��������� ������� ������� � ������������ �������� ��, ����������� �� ����������� ������. 
    mov ax, 0100h        ;���������� ������� ��������� ���������� ������� � ���������� ���, ���� �� ����
    int 16h              ;��������������� ���� ZF, ���� ������ �� �����. ������ �� ���������� �� �������.
    jz en                ;���� ��� �������, �� �������
    xor ah, ah           ;����������, ������� ������ ��������� ������� �������, ������ ��������� �� �������
    int 16h              ;al - ���� ��� �������, ah - ����������� ��� ����.
    cmp ah, 50h          ;���� �� ������ ������� ����
    jne up
    cmp cx,0FF00h        ;���� ���� ������, �� ��������, �� ��������� �� ������ �����
    je en                
    mov cx,0100h
    jmp en
up: cmp ah,48h           ;���� �� ������ ������� �����
    jne left
    cmp cx,0100h         ;��������� �� ������ ����
    je en                ;���� ��������� ����, �� �������� ����� ����������
    mov cx,0FF00h        ;�� ��������� ����, ������ ����� ��������� �����
    jmp en
left: cmp ah,4Bh         ;������ �� ������� �����
    jne right
    cmp cx,0001h         ;��������� �� ������ ������
    je en                ;���� ��, �� �������� ����� ����������
    mov cx,0FFFFh
    jmp en
right: cmp cx,0FFFFh     ;��������� �� ������ �����
    je en                ;���� ��������� ����� �� �������� ������ ����������
    mov cx,0001h
en:
    ret
key_press endp           

add_food proc         ;��������� ��� �� ������� ����
push ax
push bx
push cx
push dx             
    mov ah,0          ;����� ������� ���������� �����, � ��, dx = ������� ����� � ������� ������
    push cx
    int 1Ah           ;���������� BIOS ��� ������ � ������ 
    pop cx 
    add dh, dl
    add dl, dh
too_big_x2:
    shr dh, 1
    cmp dh, 18h
    jge too_big_x2
too_big_y2:
    shr dl, 1
    cmp dl, 50h
    jge too_big_y2 
good_num2:
    mov ax,0200h      ;����� ������� ��������� �������, ������ ���������
    int 10h
    mov ax,0800h      ;������ ������ � ������� ������� �������, al - ����������� ������(�������: bh - ����� ����� ��������)
    int 10h 
    cmp al, 20h
    jg generate
    mov ax,0200h      ;������� ������ ������� �� �����
    mov dl,0024h      ;���������� ������
    int 21h   
pop dx
    mov ax,0200h
    int 10h              ;���������� ������ �� �����
pop cx
pop bx
pop ax
    ret
add_food endp            

add_barrier proc
push ax
push bx
push cx
push dx
mov cx, 5 
generate:             
    mov ah, 0         ;����� ������� ���������� �����, � ��, dx = ������� ����� � ������� ������
    push cx
    int 1Ah           ;���������� BIOS ��� ������ � ������ 
    pop cx 
    add dh, dl
    add dl, dh
too_big_x:
    shr dh, 1
    cmp dh, 18h
    jge too_big_x
too_big_y:
    shr dl, 1
    cmp dl, 50h
    jge too_big_y 
good_num:
    mov ax,0200h      ;����� ������� ��������� �������
    int 10h
    mov ax,0800h      ;������ ������ � ������� ������� �������, al - ����������� ������(�������: bh - ����� ����� ��������)
    int 10h 
    cmp al, 20h
    jg generate
    mov ax,0200h      ;������� ������ ������� �� �����
    mov dl,0040h      ;���������� ������
    int 21h 
loop generate   
pop dx
    mov ax,0200h
    int 10h              ;���������� ������ �� �����
pop cx
pop bx
pop ax
    ret
add_barrier endp

game_over proc        
    cmp dl,50h         ;��������� �������
    je exit
    cmp dl,0
    jl exit
    cmp dh,0
    jl exit
    cmp dh,19h
    je exit
    
    cmp al,2Ah          ;��������� �� ����� �� ������ ���� ����
    je exit             
    cmp al,40h          ;��������� �� ���������� �� ������ �� �����������
    je exit
    jmp good
exit:                   ;����� �� ����
    mov ax,4c00h
    int 21h
good:                   ;����� �� ���������
    ret
game_over endp   

start:
    mov ax,@data
    mov ds,ax
    mov es,ax

    mov ax,0003h        ;������� ��������� ����� ������, AL - �����(� ������ ������ 3 - ��������� �����)
    int 10h             ;������� ������� ���� � ������������� ����� �����

    mov cx,5            ;������� ������ ������� � ������� ������� �������(BH = ����� ����� ��������, AL = ������, CX - ������� ��� �������)
    mov ax,0A2Ah        ;0A - ����� ����������, 2A - ���� �������
    int 10h             ;������� ������ �� 5 �������� "*"


    mov si,8            ;������ ���������� ������� ������
    xor di,di           ;������ ���������� ������� ������
    mov cx,0001h        ;����� ������������ �� ��� ���������� �������. �� �������� �� ����������� ������(0001h-�����)
    call add_food    
    call add_barrier
main:                   ;��������� ����
    call show_points      
    call key_press
    xor bh, bh
    mov ax, [snake+si]   ;����� ���������� ������ �� ������
    add ax, cx           ;� �� ����� ���������� ������ ������
    inc si              
    inc si
    cmp si,7CAh         ;��������� �� �������� �� ������ � ������������
    jne nex
    xor si, si           ;���� �������� �� ���������� ��� � ������
nex:
    mov [snake+si], ax       ;������� � ������ ��������� ����� ���������� ������ ����
    mov dx, ax               ;dh, dh - ������, �������
    mov ax, 0200h            ;������� ��������� ������� �������
    int 10h                 ;���������� ������
    mov ax, 0800h            ;AL - ����������� ������
    int 10h                 ;������ ������ 
    call game_over          ;�������� �� ����� ����
    mov dh,al               ;���������� ��������� ������
    mov ah, 02h    
    mov dl, 002Ah            ;������ "*"
    int 21h                 ;����� ������� '*'(�������� ������ �� 1 ������ ������)
    cmp dh, 24h              ;�������� �� ��, ��� �� ������ ����� ������ ���� ����. (����� �� ������ ���)
    jne next               
    call add_barrier  
    push cx                 ;���������� ��
    mov cx,[tick]
    inc cx                  ;���������� ������ ������
    cmp cx, 5                ;���� ��� ����� ������ 5, �� 
    jne exl
    xor cx,cx
    mov ax, 0200h            ;��������� �������
    mov dx, [snake+di-2]     ;dh, dl - ������, �������
    int 10h                 ;���������� ������ � ����� ������
    mov ax, 0200h
    mov dl, 0040h            
    int 21h                 ;������� ������ "@" - ������ �����������
exl:mov [tick],cx           ;�������� ������� ���(���� �� ������ 5, �� �� ���������� � ������ 149)
    pop cx
    add points_num, 1                  
    call add_food
    jmp main
next:
    mov ax,0200h            
    mov dx,[snake+di]       ;����� ���������� ������ ���� �� ������� ���������
    int 10h                 ;��������� ������� � ����� ����
    mov ax,0200h
    mov dl,0020h
    int 21h                 ;������� ������, ��� ����� ������ �����
    inc di                  ;���������� �����
    inc di
    cmp di,7CAh             ;�������� �� ����� �� �� �� ������� ������� ���������
    jne main
    xor di,di
jmp main
end start       