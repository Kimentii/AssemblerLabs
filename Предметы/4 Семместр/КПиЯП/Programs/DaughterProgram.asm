.model small
.stack 100h
.data        

message db 100 dup('$')
no_message db "There is no massage.", '$'

get_message proc
  push ax
  push cx
  push di
  push si
  xor cx, cx
  mov cl, es:[80h]
  cmp cl, 0
  je no_mess
  mov di, 81h  
  lea si, message
cicle1:
  mov al, es:[di]
  cmp al, 0Dh
  je end_get_message
  mov [si], al
  inc di
  inc si 
  jmp cicle1 
no_mess:
  output no_message  
end_get_message:
  pop si
  pop di
  pop cx
  pop ax 
ret
get_message endp

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
    mov ax, @data
    mov ds, ax
    call get_message 
    output message
    newline
    mov ah, 4Ch
    int 21h
end start