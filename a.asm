include console.inc

COMMENT *

   Программа для обработки текстов

*

.const
    MAX_LEN equ 1024
    MAX_CHAR equ 256
    
.data
    Num1 dw MAX_CHAR dup (0)
    Num2 dw MAX_CHAR dup (0)
    Max1 dw -1
    Max2 dw -1
    K db 4
    Len1 dd 0
    Len2 dd 0
    LenTask1 dd 0
    LenTask2 dd 0

.data?
    Text1 db MAX_LEN dup (?)
    Text2 db MAX_LEN dup (?)
    
.code

;procedure TextInput(var Text : array[1..MAX_LEN] of char; var LenTask : integer)
TextInput proc
;ebx - адрес первого элемента
;eax - количество элементов
;flag - [ebp - 4] 
;cnt - [ebp - 8]
    push ebp
    mov ebp, esp
    sub esp, 4
    sub esp, 4
    push eax
    push ebx
    push ecx
    mov eax, 0
    mov ebx, [ebp + 8];адрес начала Text
    flag equ dword ptr [ebp - 4]
    cnt equ dword ptr [ebp - 8]
    mov flag, 0
    mov cnt, 0
Input:
    cmp eax, 514; проверка на длину
    ja Continue 
    inchar cl; ввод символа
    cmp flag, 1; введен ли до этого '\'
    jne NotEntSlBef
    mov [ebx], cl;до этого введен символ экранирования
    add ebx, 1
    add eax, 1
    mov flag, 0
    mov cnt, 0
    jmp Input
NotEntSlBef:
    ;до этого не был введен символ эканирования
    cmp cl, '\'
    jne NotEntSl
    ;введен '\'
    mov flag, 1 
    jmp Input
NotEntSl:
    ;введен не '\'
    cmp cl, '_'
    jne NotUndr
    ;введено '_'
    cmp cnt, 2
    je Continue ;конец ввода
    mov cnt, 1
    jmp AddChar
NotUndr:
    cmp cl, '@'
    jne NotAt
    ;введен '@'
    cmp cnt, 1
    jne NotAt
    mov cnt, 2
    jmp AddChar
NotAt:
    mov cnt, 0
AddChar:
    ;добавление в Text
    mov [ebx], cl
    add ebx, 1
    add eax, 1
    jmp Input
    
Continue:
    sub eax, 2
    mov ebx, [ebp + 12]
    mov [ebx], eax;длина
    pop ecx
    pop ebx
    pop eax
    mov esp, ebp
    pop ebp
    ret 8
TextInput endp


;procedure CountLength(var Text : array [1..MAX_LEN] of char; var Len : integer; var LenTask1 : integer)
CountLength proc
;edx - ответ
;ebx - адрес начала массива Text
;ecx - Len
    push ebp
    mov ebp, esp
    sub esp, 1024;порождение временного массива для подсчета частот
    push eax
    push ebx
    push ecx
    push edx
    push esi
    push edi
    
    mov ecx, MAX_CHAR
    mov ebx, ebp
    sub ebx, 4
    ;обнуление массива частот
Clear:  
    mov dword ptr [ebx], 0
    sub ebx, 4
    loop Clear

    mov edx, 0
    mov ebx, [ebp + 8];адрес начала Text
    mov esi, [ebp + 12]
    mov ecx, [esi]; Len
    
Cycle:
    mov al, [ebx];очередной символ
    mul K  ;подсчет адреса для занесения в массив частот
    neg ax
    movsx esi, ax
    add esi, ebp
    mov edi, [esi]
    add edi, 1
    mov dword ptr [esi], edi
    cmp [esi], edx
    jbe ContLoop
    mov edi, [esi]
    mov dword ptr edx, edi
ContLoop:
    add ebx, 1
    loop Cycle
    
    mov ecx, [ebp + 16]
    mov [ecx], edx; занесение в ответ получившейся длины
    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    pop eax
    mov esp, ebp
    pop ebp
    ret 12
CountLength endp


;procedure Processing1(var Text : array[1..MAX_LEN] of char; Len : integer);
Processing1 proc
;ebx - адрес начала массива
;ecx - длина текста
    push ebp
    mov ebp, esp
    push eax
    push ebx
    push ecx
    mov ecx, [ebp + 12];Len
    mov ebx, [ebp + 8];адрес начала Text
Cycle1:
    movzx ax, byte ptr [ebx];очередной символ
    cmp ax, 'A'
    jb ContCycl1
    cmp ax, 'Z'
    ja LowLet
    ;заглавная буква
    neg ax
    add ax, 'A'
    add ax, 'Z'
    mov [ebx], al;замена на симметричную букву
    jmp ContCycl1
LowLet:
    ;возможно строчная буква
    cmp ax, 'a'
    jb ContCycl1
    cmp ax, 'z'
    ja RusLet
    ;точно строчная буква
    neg ax
    add ax, 'a'
    add ax, 'z'
    mov [ebx], al
    jmp ContCycl1
RusLet:
    cmp ax, 128
    jb ContCycl1
    cmp ax, 159
    ja RusLowLet
    neg ax
    add ax, 128
    add ax, 159
    mov [ebx], al
    jmp ContCycl1
RusLowLet:
    cmp ax, 160
    jb ContCycl1
    cmp ax, 239
    ja ContCycl1
    neg ax
    add ax, 160
    add ax, 239
    mov [ebx], al
    
ContCycl1:
    add ebx, 1
    dec ecx
    cmp ecx, 0
    ja Cycle1

    pop ecx
    pop ebx
    pop eax
    mov esp, ebp
    pop ebp
    ret 8
Processing1 endp


;procedure Processing2(var Text : array[1..MAX_LEN] of char;  var Len : integer);
Processing2 proc
;ebx - адрес текста
;ecx - счетчик
;eax - текущая длина
    push ebp
    mov ebp, esp
    sub esp, 4
    push eax
    push ebx
    push ecx
    push edx
    push edi
    push esi

    mov eax, [ebp + 12]
    mov ecx, [eax]  ;Len
    mov ebx, [ebp + 8]  ;адрес начала Text
    mov eax, ecx    ;Len
    
    
Cycle2:
    mov dl, [ebx]   ;очередной символ
    cmp dl, 'A'
    jb ContCycl2
    cmp dl, 'Z'
    jbe OK
    cmp dl, 128
    jb ContCycl2
    cmp dl, 159
    ja ContCycl2
OK:    ;если заглавная буква
    mov edi, [ebp + 8]
    add edi, eax    ;адрес последнего элемента
    mov esi, ecx ;счетчик
    add eax, 1  ;длина увеличивается
Shift:
    ;сдвиг вправо
    mov dh, [edi]
    add edi, 1
    mov [edi], dh
    sub edi, 2
    sub esi, 1
    cmp esi, 0
    ja Shift
    
    add ebx, 1
    mov [ebx], dl;удваивание
ContCycl2:
    add ebx, 1
    loop Cycle2
    
    mov ebx, [ebp + 12]
    mov [ebx], eax; обновление длины
    pop esi
    pop edi
    pop edx
    pop ecx
    pop ebx
    pop eax
    mov esp, ebp
    pop ebp
    ret 8
Processing2 endp


Start:
    ClrScr 
    
    ConsoleTitle "Обработка текстов"
    ;приветственное сообщение
    outstrln "Добрый день!"
    ;ввод
    outstrln "Введите, пожалуйста, первый и второй текст"
    push offset Len1
    push offset Text1[0]
    call TextInput
    
    cmp Len1, 0
    je Error
    cmp Len1, 511
    ja Error
    
    push offset Len2
    push offset Text2[0]
    call TextInput
    
    cmp Len2, 0
    je Error
    cmp Len2, 511
    ja Error
    
    ;подсчет длин 
    push offset LenTask1
    push offset Len1
    push offset Text1[0]
    call CountLength
    
    push offset LenTask2
    push offset Len2
    push offset Text2[0]
    call CountLength
    
    outstrln "Первое правило: замена всех латинских букв симметричными им в алфавите"
    outstrln "Второе правило: удвоение каждой заглавной латинской буквы текста"
    
    ;обработка текстов
    mov eax, LenTask1
    cmp eax, LenTask2
    jb Var2
    outstrln "Первый текст изменяется по первому правилу, второй - по второму"
    
    push Len1
    push offset Text1[0]
    call Processing1
    
    push offset Len2
    push offset Text2[0]
    call Processing2
    
    jmp Write
    
Var2:
    outstrln "Первый текст изменяется по второму правилу, второй - по первому"
    push Len2
    push offset Text2[0]
    call Processing1
    
    push offset Len1
    push offset Text1[0]
    call Processing2

    ;вывод
    
Write:
    outstr "Длина первого текста: "
    outintln LenTask1
    outstrln """"""""
    mov ebx, 0
    mov ecx, Len1
    mov edx, Len1
    sub edx, 3
Out1:
    cmp ebx, edx
    ja ContOut1
    cmp Text1[ebx], '"'
    jne ContOut1
    cmp Text1[ebx + 1], '"'
    jne ContOut1
    cmp Text1[ebx + 2], '"'
    jne ContOut1
    outchar '\'
ContOut1:
    ConsoleMode
    outchar Text1[ebx]
    ConsoleMode
    add ebx, 1
    sub ecx, 1
    cmp ecx, 0
    jne Out1
    outstrln """"""""
    
    outstrln
    outstr "Длина второго текста: "
    outintln LenTask2
    outstrln """"""""
    mov ebx, 0
    mov ecx, Len2
Out2: 
    ConsoleMode
    outchar Text2[ebx]
    ConsoleMode
    add ebx, 1
    loop Out2
    outstrln """"""""
    jmp Finish
    
Error:
    outstrln "При вводе допущена ошибка"
  
Finish:
   inchar al
   exit
   end Start
