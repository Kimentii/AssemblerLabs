.model small
.stack 100h
.data    
    
my_file db 128 dup(0)
buffer db 1030 dup('$') 
ERROR_STR db "ERROR", '$' 
size_of_line dw 0
reverse_line db 100 dup('$')
newline_str db 0Dh, 0Ah
last_sector_flg db 0

get_name proc
  push ax
  push cx
  push di
  push si
  xor cx, cx
  mov cl, es:[80h]
  cmp cl, 0
  je end_get_name
  mov di, 82h  
  lea si, my_file
cicle1:
  mov al, es:[di]
  cmp al, 0Dh
  je end_get_name
  mov [si], al
  inc di
  inc si
  jmp cicle1 
end_get_name:
  pop si
  pop di
  pop cx
  pop ax 
ret
get_name endp

clear_buf proc
    push cx
    push si
    lea si, buffer
    mov cx, 20
cicleCB:
    mov [si], '$'
    inc si
    loop cicleCB
    pop si
    pop cx
    ret
clear_buf endp 

open_file proc                         ;INPUT: dx is name of file   
    push ax
    push dx
    mov ah, 3Dh 
    mov al, 02h                    
    int 21h	
    jc error
    mov bx,ax
    jmp all_is_good		 
error:             
    call show_error 
all_is_good:   
    pop dx
    pop ax
ret
open_file endp  

read_file proc                         ;INPUT: buffer for write, OUTPUT: buffer with file data, ax - number of bytes read
    ;push ax 
    push cx
    push dx
read_data:
    mov cx, 16
    mov dx, offset buffer	
    mov ah, 3Fh
    int 21h	
    jc read_error
    jmp end_read
read_error:
    call show_error 
end_read:
    pop dx
    pop cx
    ;pop ax    
ret
read_file endp

write_file proc 
    push ax
    push dx
    push cx
    mov ah, 40h
    lea dx, reverse_line
    mov cx, size_of_line
    jcxz zero_line
    int 21h
zero_line:  
    mov ah, 40h
    lea dx, newline_str
    mov cx, 2
    int 21h 
    pop cx
    pop dx
    pop ax
ret
write_file endp

close_file macro 
    push ax
    mov ah,3Eh
    int 21h   
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

proc show_error
    pusha 
    newline
    output ERROR_STR
    newline
    popa
ret
show_error endp 
   
   
size_of_line_p proc       
    push si 
    mov size_of_line, 0
new_symbol:
    cmp [si], 0Dh
    je end_of_line 
    cmp [si], '$'
    je end_of_line
    inc si
    inc size_of_line
    jmp new_symbol 
end_of_line:
    pop si
ret
size_of_line_p endp

get_reverse_str proc 
    push cx
    push di
    call size_of_line_p 
    lea di, reverse_line
    add di, size_of_line
    dec di 
    mov cx, size_of_line
    jcxz end_get
    cld                         ;set DF flag to 0
one_more_symbol:
    lodsb
    mov [di], al
    dec di
    loop one_more_symbol
end_get:
    inc si
    inc si
    pop di
    pop cx  
ret
get_reverse_str endp 

main proc
    mov last_sector_flg, 0
analyze:
    cmp last_sector_flg, 0
    je new_sector
    jmp end_main
set_last_sector_flg:
    mov last_sector_flg, 1
    inc ax                                  ;just because, guy, just because
    jmp next_task
new_sector:
    call clear_buf
    call read_file 
    output buffer
    cmp ax, 16
    jl set_last_sector_flg
    cmp ax, 0
    je stop_main  
next_task: 
    xor cx, cx
    mov dx, ax
    neg dx
    mov ah, 42h
    mov al, 01h
    int 21h
    lea si, buffer
new_line:
    call get_reverse_str
    cmp [si], '$'
    je analyze
    call write_file
    jmp new_line
end_main:
    call write_file
stop_main:    
    ret
main endp

start:                             
    mov ax, @data
    mov ds, ax  
    call get_name
    mov dx, offset my_file 
    call open_file
    call main
    close_file
exit:
    mov ah, 4Ch
    int 21h
end start   