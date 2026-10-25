.model small
.stack 100h

.data
; every name and disease is exactly 10 bytes, padded with '$'
names    db 'Panadol$$$','Brufen$$$$','Amoxil$$$$'
diseases db 'fever$$$$$','pain$$$$$$','infection$'
qty      db 10,5,8
price    db 5,10,20

input    db 10 dup('$')

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
crlf  db 13,10,'$'

.code
main:
    mov ax, @data
    mov ds, ax

    ; ---- ask for disease ----
    lea dx, msg1
    mov ah, 9
    int 21h

    lea di, input
    mov cx, 0
read:
    mov ah, 1
    int 21h
    cmp al, 13          ; Enter key?
    je done_read
    mov [di], al
    inc di
    inc cx
    cmp cx, 9           ; max 9 letters
    jne read
done_read:
    lea dx, crlf
    mov ah, 9
    int 21h

    ; ---- search medicines (bx = medicine number 0..2) ----
    mov bx, 0
search:
    cmp bx, 3
    je notfound

    mov al, bl
    mov cl, 10
    mul cl              ; ax = bx * 10
    lea si, diseases
    add si, ax
    lea di, input
    mov cx, 10
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