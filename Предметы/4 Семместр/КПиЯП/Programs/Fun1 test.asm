.model tiny
.code
org 100h   
start:
lea dx, massage  
mov ah, 9
int 21h
massage db dup('q') 10, 13, '$'
end start