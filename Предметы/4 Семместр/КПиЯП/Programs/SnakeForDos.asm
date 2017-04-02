;Аски коды стрелок: 48h - вверх, H 4Bh - влево, K 4Dh - вправо, M 50h - вниз, P 
.model   small 
.data                    ;Координаты змейки
snake   dw 0000h
        dw 0001h
        dw 0002h
        dw 0003h
        dw 0004h
        dw 7CCh dup('?')
tick    dw 0             ;счетчик, если змейка съела больше 5, то игра усложняется
points_num dw 0
points   db 10 dup('?')
counter db 0
.stack 100h
.code

delay proc
    push ax             
    push bx
    push cx
    mov ah,0            ;номер функции считывания часов, в cx, dx = счетчик тиков с момента сброса
    int 1Ah             ;прерывание BIOS для работы с часами
    add dx, 3           ;в секунда 18 тактов, dx - младшая часть значения
    mov bx,dx           
repeat:   
    int 1Ah             ;снова считываем время
    cmp dx,bx           ;ждем 3 такта
    jl repeat
    pop cx              
    pop bx
    pop ax
    ret
delay endp    
 
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
    mov [si], 2                  ;Атрибут символа
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
    mov ax, points_num   ;Загружаем в ах число очков
    call itos            ;Преобразуем число в строку
    mov dh, 17h          ;Координаты вывода очков
    mov dl, 0            
    lea bp, points       ;Строка для вывода
    mov cx, 5            ;Заносим в сх размер строки
    mov ax, 1303h        ;Функция 13 - выводит очки, 3 - код подфункции
    int 10h              ;Выводим строку              
    pop dx
    mov ax,0200h
    int 10h              ;Возвращаем курсор на место
    pop si
    pop cx 
    pop bp
    pop ax
    ret
show_points endp

;0FF00h - вверх, 0100h - вниз, 0FFFFh - лево, 0001h  - право (0FF00 - это "-1" для первого байта в доп. коде)
key_press proc           ;Обработка нажатия клавиши и присваивания значения СХ, отвечающему за направление головы. 
    mov ax, 0100h        ;прерывание которое проверяет готовность символа и показывает его, если он есть
    int 16h              ;устанавливается флаг ZF, если символ не готов. Символ не забирается из очереди.
    jz en                ;если нет нажатия, то выходим
    xor ah, ah           ;прерывание, которое читает следующую нажатую клавишу, символ удаляется из очереди
    int 16h              ;al - аски код символа, ah - расширенный код аски.
    cmp ah, 50h          ;Была ли нажата клавиша вниз
    jne up
    cmp cx, 0FF00h       ;Если была нажата, то проверка, не двигатеся ли змейка вверх
    je en                
    mov cx,0100h
    jmp en
up: cmp ah,48h           ;Была ли нажата клавиша вверх
    jne left
    cmp cx,0100h         ;Двигается ли змейка вниз
    je en                ;Если двигается вниз, то движение вверх невозможно
    mov cx,0FF00h        ;Не двигается вниз, значит можно двигаться вверх
    jmp en
left: cmp ah,4Bh         ;Нажата ли клавиша влево
    jne right
    cmp cx,0001h         ;Двигается ли змейка вправо
    je en                ;Если да, то движение влево невозможно
    mov cx,0FFFFh
    jmp en
right: cmp cx,0FFFFh     ;Двигается ли змейка влево
    je en                ;Если двигатеся влево то движение вправо невозможно
    mov cx,0001h
en:
    ret
key_press endp           

;************************
; SPAWN_FOOD is spawning;
; food to game field in ;
; random order.         ;
;************************

add_food proc         
    
        push    ax                          ; Saving AX register
        push    bx                          ; Saving BX register
        push    cx                          ; Saving CX register
        push    dx                          ; Saving DX register   
generate:
        mov ah, 2ch
        int 21h
big_x:  
        shr dh, 1
        cmp dh, 25d
        jge big_x
big_y:
        shr dl, 1
        cmp dl, 50h
        jge big_y
             
        mov ah, 02h
        int 10h
        
        mov ah, 08h
        int 10h
        cmp al, ' '
        jne generate
        
        mov ah, 02h
        mov dl, '$'
        int 21h
        
        pop     dx                                    
        pop     cx                          ; Getting CX
        pop     bx                          ; Getting BX
        pop     ax                          ; Getting AX
        ret                                 ; Return
        
add_food endp                    

add_barrier proc
push ax
push bx
push cx
push dx
mov counter, 0 
generate2:             
        mov ah, 2ch
        int 21h
big_x2:  
        shr dh, 1
        cmp dh, 25d
        jge big_x2
big_y2:
        shr dl, 1
        cmp dl, 50h
        jge big_y2
             
        mov ah, 02h
        int 10h
        
        mov ah, 08h
        int 10h
        cmp al, ' '
        jne generate2
        
        mov ah, 02h
        mov dl, '@'
        int 21h 
inc counter
cmp counter, 5
jl generate2   
pop dx
    mov ax,0200h
    int 10h              ;Возвращаем курсор на место
pop cx
pop bx
pop ax
    ret
add_barrier endp

game_over proc        
    cmp dl,50h         ;Проверяем границы
    je exit
    cmp dl,0
    jl exit
    cmp dh,0
    jl exit
    cmp dh,19h
    je exit
    cmp al,2Ah          ;Проверяем не съела ли змейка сама себя
    je exit             
    cmp al,40h          ;Проверяем не наткнулась ли змейка на препядствие
    je exit
    jmp good
exit:                   ;Выход из игры
    mov ax,4c00h
    int 21h
good:                   ;Выход из процедуры
    ret
game_over endp   

start:
    mov ax,@data
    mov ds,ax
    mov es,ax

    mov ax,0003h        ;Функция установки видио режима, AL - режим(в данном случае 3 - текстовый режим)
    int 10h             ;Очищаем игровое поле и устанавливает видио режим

    mov cx,5            ;Функция вывода символа в текущей позиции курсора(BH = номер видио страницы, AL = символ, CX - сколько раз вывести)
    mov ax,0A2Ah        ;0A - номер прерывания, 2A - аски символа
    int 10h             ;Выводим змейку из 5 символов "*"


    mov si,8            ;Индекс координаты символа головы
    xor di,di           ;Индекс координаты символа хвоста
    mov cx,0001h        ;Будем использовать СХ для управления головой. СХ отвечает за направление головы(0001h-право)
    call add_food    
    call add_barrier
main:                   ;Основоной цикл
    call delay
    call show_points      
    call key_press
    xor bh, bh
    mov ax, [snake+si]   ;Берем координату головы из памяти
    add ax, cx           ;В АХ новая координата головы змейки
    inc si              
    inc si
    cmp si,7CAh         ;Проверяем не кончился ли массив с координатами
    jne nex
    xor si, si           ;Если кончился то используем его с начала
nex:
    mov [snake+si], ax       ;Заносим в массив координат новую координату головы змеи
    mov dx, ax               ;dh, dh - строка, колонка
    mov ax, 0200h            ;Функция установки позиции курсора
    int 10h                 ;Перемещаем курсор
    mov ax, 0800h            ;AL - прочитанный символ
    int 10h                 ;Читаем символ 
    call game_over          ;Проверка на конец игры
    mov dh,al               ;Запоминаем считанный символ
    mov ah, 02h    
    mov dl, 002Ah            ;Символ "*"
    int 21h                 ;Вывод символа '*'(сдвигаем голову на 1 символ вперед)
    cmp dh, 24h              ;Проверка на то, был ли символ перед головй змеи едой. (Съела ли змейка еду)
    jne next                 
    push cx                 ;Запоминаем СХ
    mov cx,[tick]
    inc cx                  ;Увеличивем размер змейки
    cmp cx, 5                ;Если она съела больше 5, то 
    jne exl
    xor cx,cx
    mov ax, 0200h            ;Установка курсора
    mov dx, [snake+di-2]     ;dh, dl - строка, столбец
    int 10h                 ;Перемещаем курсов в конец змейки
    mov ax, 0200h
    mov dl, 0040h            
    int 21h                 ;Выводим символ "@" - символ препядствия
exl:mov [tick],cx           ;Изменяем счетчик еды(Если СХ больше 5, то он обнуляется в строку 149)
    pop cx  
    add points_num, 1                  
    call add_food 
    call add_barrier 
    jmp main
next:
    mov ax,0200h            
    mov dx,[snake+di]       ;Берем координату хвоста змеи из массива координат
    int 10h                 ;Установка курсора в хвост змеи
    mov ax,0200h
    mov dl,0020h
    int 21h                 ;Выводим пробел, тем самым удаляя хвост
    inc di                  ;Перемещаем хвост
    inc di
    cmp di,7CAh             ;Проверка не вышли ли мы за размеры массива координат
    jne main
    xor di,di
jmp main
end start       