.model tiny   
.code       
org 100h  
   
newline    macro  
mov        dl,13
mov        ah,2                     ;ah=2 is function which put symbol on the screen 
int        21h
endm        

start: 
mov ah, 9   
lea dx, massage
int 21h         
newline   
lea dx, massage
mov ah, 9
int 21h
mov ah, 4Ch
int 21h  
ret  
massage db "Hello world", 10, 13, '$' 
end start