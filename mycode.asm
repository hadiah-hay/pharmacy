.model small
.stack 100h

.data
names    db 'Panadol$$$','Brufen$$$$','Amoxil$$$$' ;extra $ make each work 10 bytes
diseases db 'fever$$$$$','pain$$$$$$','infection$'
qty      db 10,5,8
price    db 5,10,20

input    db 10 dup('$')         ;allows a 10 byte input (duplicates $ 10 times)

msg1  db 'Enter disease (lowercase): $'
msg2  db 'Medicine found: $'
msg3  db 'Quantity: $'
msg4  db 'Price: $'
msg5  db 'Buy it? (y/n): $'
msg6  db 'No medicine found for this disease.$'
msg7  db 'Sorry, out of stock.$'
msg8  db 'Purchased! Total paid: $'
msg9  db 'Remaining quantity: $'
msg10 db 'Thank you, goodbye.$'
crlf  db 13,10,'$'              ;clears line (endl)

.code
main:
    mov ax, @data
    mov ds, ax

    lea dx, msg1 ;asks a disease
    mov ah, 9
    int 21h

    lea di, input    ;takes input
    mov cx, 0
read:                ;loop start
    mov ah, 1        ;inputs characters
    int 21h
    cmp al, 13       ;enter key?
    je done_read     ;if yes end loop
    mov [di], al     ;if no store in buffer
    inc di           ;move to next buffer location
    inc cx           ;keep count
    cmp cx, 9        ;max 9 letters
    jne read         ;restarts the loop
done_read:
    lea dx, crlf    
    mov ah, 9
    int 21h

    mov bx, 0      ;checks from first medicine
search:
    cmp bx, 3     
    je notfound    ;ends loop if bx reaches 3

    mov al, bl     
    mov cl, 10
    mul cl               ;each word is 10 byte so now ax holds the total byte of whichever entry loop is on (2 entry ax=20)
    lea si, diseases     ;diseases are iterated until the one corresponding to the disease is reached
    add si, ax           
    lea di, input        ;gets the input in di    
    mov cx, 10           ;starts another loop to compare di to the current disease in si
cmp_loop:
    mov al, [si]
    cmp al, [di]
    jne next
    inc si
    inc di
    loop cmp_loop
    jmp found
next:
    inc bx
    jmp search

notfound:
    lea dx, msg6
    mov ah, 9
    int 21h
    jmp exit

; ---- medicine found ----
found:
    lea dx, msg2
    mov ah, 9
    int 21h

    mov al, bl
    mov cl, 10
    mul cl
    lea dx, names
    add dx, ax          ; dx points to the medicine name
    mov ah, 9
    int 21h
    lea dx, crlf
    mov ah, 9
    int 21h

    ; show quantity
    lea dx, msg3
    mov ah, 9
    int 21h
    mov al, qty[bx]
    mov ah, 0
    call print_num
    lea dx, crlf
    mov ah, 9
    int 21h

    ; show price
    lea dx, msg4
    mov ah, 9
    int 21h
    mov al, price[bx]
    mov ah, 0
    call print_num
    lea dx, crlf
    mov ah, 9
    int 21h

    ; out of stock?
    mov al, qty[bx]
    cmp al, 0
    je outstock

    ; ---- ask to buy ----
    lea dx, msg5
    mov ah, 9
    int 21h
    mov ah, 1
    int 21h
    cmp al, 'y'
    jne bye

    lea dx, crlf
    mov ah, 9
    int 21h

    ; decrease quantity by 1
    mov al, qty[bx]
    dec al
    mov qty[bx], al

    ; show total paid (1 unit)
    lea dx, msg8
    mov ah, 9
    int 21h
    mov al, price[bx]
    mov ah, 0
    call print_num
    lea dx, crlf
    mov ah, 9
    int 21h

    ; show remaining quantity
    lea dx, msg9
    mov ah, 9
    int 21h
    mov al, qty[bx]
    mov ah, 0
    call print_num
    lea dx, crlf
    mov ah, 9
    int 21h
    jmp bye

outstock:
    lea dx, msg7
    mov ah, 9
    int 21h
    jmp exit

bye:
    lea dx, crlf
    mov ah, 9
    int 21h
    lea dx, msg10
    mov ah, 9
    int 21h

exit:
    mov ah, 4Ch
    int 21h

; ---- prints the number in ax ----
print_num proc
    push bx
    push cx
    push dx
    mov cx, 0
    mov bx, 10
pn1:
    mov dx, 0
    div bx              ; ax = ax / 10, dx = remainder
    push dx
    inc cx
    cmp ax, 0
    jne pn1
pn2:
    pop dx
    add dl, '0'
    mov ah, 2
    int 21h
    loop pn2
    pop dx
    pop cx
    pop bx
    ret
print_num endp

end main
