include console.inc

COMMENT *

   ��������� ��� ��������� �������

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
;ebx - ����� ������� ��������
;eax - ���������� ���������
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
    mov ebx, [ebp + 8];����� ������ Text
    flag equ dword ptr [ebp - 4]
    cnt equ dword ptr [ebp - 8]
    mov flag, 0
    mov cnt, 0
Input:
    cmp eax, 514; �������� �� �����
    ja Continue 
    inchar cl; ���� �������
    cmp flag, 1; ������ �� �� ����� '\'
    jne NotEntSlBef
    mov [ebx], cl;�� ����� ������ ������ �������������
    add ebx, 1
    add eax, 1
    mov flag, 0
    mov cnt, 0
    jmp Input
NotEntSlBef:
    ;�� ����� �� ��� ������ ������ ������������
    cmp cl, '\'
    jne NotEntSl
    ;������ '\'
    mov flag, 1 
    jmp Input
NotEntSl:
    ;������ �� '\'
    cmp cl, '_'
    jne NotUndr
    ;������� '_'
    cmp cnt, 2
    je Continue ;����� �����
    mov cnt, 1
    jmp AddChar
NotUndr:
    cmp cl, '@'
    jne NotAt
    ;������ '@'
    cmp cnt, 1
    jne NotAt
    mov cnt, 2
    jmp AddChar
NotAt:
    mov cnt, 0
AddChar:
    ;���������� � Text
    mov [ebx], cl
    add ebx, 1
    add eax, 1
    jmp Input
    
Continue:
    sub eax, 2
    mov ebx, [ebp + 12]
    mov [ebx], eax;�����
    pop ecx
    pop ebx
    pop eax
    mov esp, ebp
    pop ebp
    ret 8
TextInput endp


;procedure CountLength(var Text : array [1..MAX_LEN] of char; var Len : integer; var LenTask1 : integer)
CountLength proc
;edx - �����
;ebx - ����� ������ ������� Text
;ecx - Len
    push ebp
    mov ebp, esp
    sub esp, 1024;���������� ���������� ������� ��� �������� ������
    push eax
    push ebx
    push ecx
    push edx
    push esi
    push edi
    
    mov ecx, MAX_CHAR
    mov ebx, ebp
    sub ebx, 4
    ;��������� ������� ������
Clear:  
    mov dword ptr [ebx], 0
    sub ebx, 4
    loop Clear

    mov edx, 0
    mov ebx, [ebp + 8];����� ������ Text
    mov esi, [ebp + 12]
    mov ecx, [esi]; Len
    
Cycle:
    mov al, [ebx];��������� ������
    mul K  ;������� ������ ��� ��������� � ������ ������
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
    mov [ecx], edx; ��������� � ����� ������������ �����
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
;ebx - ����� ������ �������
;ecx - ����� ������
    push ebp
    mov ebp, esp
    push eax
    push ebx
    push ecx
    mov ecx, [ebp + 12];Len
    mov ebx, [ebp + 8];����� ������ Text
Cycle1:
    movzx ax, byte ptr [ebx];��������� ������
    cmp ax, 'A'
    jb ContCycl1
    cmp ax, 'Z'
    ja LowLet
    ;��������� �����
    neg ax
    add ax, 'A'
    add ax, 'Z'
    mov [ebx], al;������ �� ������������ �����
    jmp ContCycl1
LowLet:
    ;�������� �������� �����
    cmp ax, 'a'
    jb ContCycl1
    cmp ax, 'z'
    ja RusLet
    ;����� �������� �����
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
;ebx - ����� ������
;ecx - �������
;eax - ������� �����
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
    mov ebx, [ebp + 8]  ;����� ������ Text
    mov eax, ecx    ;Len
    
    
Cycle2:
    mov dl, [ebx]   ;��������� ������
    cmp dl, 'A'
    jb ContCycl2
    cmp dl, 'Z'
    jbe OK
    cmp dl, 128
    jb ContCycl2
    cmp dl, 159
    ja ContCycl2
OK:    ;���� ��������� �����
    mov edi, [ebp + 8]
    add edi, eax    ;����� ���������� ��������
    mov esi, ecx ;�������
    add eax, 1  ;����� �������������
Shift:
    ;����� ������
    mov dh, [edi]
    add edi, 1
    mov [edi], dh
    sub edi, 2
    sub esi, 1
    cmp esi, 0
    ja Shift
    
    add ebx, 1
    mov [ebx], dl;����������
ContCycl2:
    add ebx, 1
    loop Cycle2
    
    mov ebx, [ebp + 12]
    mov [ebx], eax; ���������� �����
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
    
    ConsoleTitle "��������� �������"
    ;�������������� ���������
    outstrln "������ ����!"
    ;����
    outstrln "�������, ����������, ������ � ������ �����"
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
    
    ;������� ���� 
    push offset LenTask1
    push offset Len1
    push offset Text1[0]
    call CountLength
    
    push offset LenTask2
    push offset Len2
    push offset Text2[0]
    call CountLength
    
    outstrln "������ �������: ������ ���� ��������� ���� ������������� �� � ��������"
    outstrln "������ �������: �������� ������ ��������� ��������� ����� ������"
    
    ;��������� �������
    mov eax, LenTask1
    cmp eax, LenTask2
    jb Var2
    outstrln "������ ����� ���������� �� ������� �������, ������ - �� �������"
    
    push Len1
    push offset Text1[0]
    call Processing1
    
    push offset Len2
    push offset Text2[0]
    call Processing2
    
    jmp Write
    
Var2:
    outstrln "������ ����� ���������� �� ������� �������, ������ - �� �������"
    push Len2
    push offset Text2[0]
    call Processing1
    
    push offset Len1
    push offset Text1[0]
    call Processing2

    ;�����
    
Write:
    outstr "����� ������� ������: "
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
    outstr "����� ������� ������: "
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
    outstrln "��� ����� �������� ������"
  
Finish:
   inchar al
   exit
   end Start
