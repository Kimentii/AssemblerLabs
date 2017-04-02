.model small
.data
file_name db "a2.txt", 0
msg1    db 13,10,'Start dp.exe', 13, 10, '$'
err_msg    db 13,10,'Error$'
msg3    db 13,10,'dp.exe terminating. Press any key$'
fn  db 'dp.exe',0                        ;��� ������������ �����
param db 102, 101 dup('$')               ;��������� ������
;EPB(Exec Parameter Block)
env dw 0                                 ;�������� �����
cmd_of  dw offset param                  ;�������� ��������� ������
cmd_seg dw 0                             ;������� ��������� ������
fcb1    dd 0
fcb2    dd 0
Len dw $-env                             ;����� EPB
dsize dw $-file_name                     ;������ �������� ������, $ - ��� ������� ��������, msg1 - �������� ������ ������ 
 
.stack 256
.code 

open_file proc                           ;INPUT: ds is name of file    
    push ax
    push dx 
    lea dx, file_name
    mov ah, 3Dh 
    mov al, 02h                    
    int 21h	
    jc error
    mov bx,ax
    jmp all_is_good		 
error:             
    output err_msg 
all_is_good:   
    pop dx
    pop ax
ret
open_file endp

read_file proc                           ;INPUT: buffer for write, OUTPUT: buffer with file data, ax - number of bytes read
    push ax 
    push cx
    push dx
read_data:
    mov cx, 100
    mov dx, offset param	
    mov ah, 3Fh
    int 21h	
    jc read_error
    jmp end_read
read_error:
    output err_msg
end_read:
    pop dx
    pop cx
    pop ax    
ret
read_file endp

output macro str                ;output stirng
    push dx
    push ax  
    lea dx, str
    mov ah, 09h
    int 21h
    pop ax 
    pop dx
endm

start:
    mov ax,@data            ;����������� ���������� ��������
    mov ds,ax
    mov cmd_seg, ax         ;������� ������� ������ ��� �������� ���������
    push ax
    mov ah,4ah              ;������� ��������� ������� ����� ������
    mov bx, (csize/16)+256/16+(dsize/16)+20   ;����� ������ ��������� � ������ ���� ���������
    int 21h                 ;������������ ���� ������ ����� ���������  
    jc er
    call open_file
    call read_file 
    pop ax
    mov es,ax
    output msg1
    mov ax,4b00h            ;������� �������� � ������� ���������
    lea dx,fn               ;��� ��������� ��� �������
    lea bx,env              ;��������� EPB
    int 21h
    jc er                   ;���� ������, �� ������� ���������
ex: 
    output msg3
    mov ah,1                ;������� ������� ����� �������
    int 21h
    mov ax,4c00h            ;����� ���������
    int 21h
er: 
    output err_msg
    jmp ex                  ;�����
csize dw $-start            ;������ �������� ����
end start