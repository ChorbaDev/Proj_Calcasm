assume ds:data, cs:code
;;segment de donnee 
data segment
    a db 20,?,20 dup ("$")
    b db 20,?,20 dup ("$")
   ; x db ?,"$"
    op db ?,"$"
    res db 5 dup ("$")
    msgA db "Entrer Le premier nombre :$"
    msgB db "Entrer Le deuxieme nombre :$"
    msgOP db "Choisi l'operation: $"
    
data ends
;;pour sauter un ligne
CRLF MACRO
	MOV AH,02H
	MOV DL,0DH
	int 21H
	mov DL,0AH
	int 21H
	ENDM
;;segment du code
org 100h
code segment 

main:
    mov ax,data
    mov ds,ax
nombre1:
CRLF ;; retour a la ligne
;;affichage msgA
    mov ah,9h
    lea dx,msgA
    int 21h
;;lire A
    mov ah,0ah 
    lea dx,a
    int 21h
;;verifier que A n'est composer que des chiffres 
        mov cl,a+1  ;; stocker nombre de caractere taper dans cl
        ;sub cl,30h  ;; ajouter 30h a cl car en compare en hexa
        cmp cl,0h  ;; comparer cl avec 0 (verifier que le nombre taper est non vide)
        je nombre1  ;; si nombre taper est vide on saisie 'a' de nouveau
        cmp cl,4h  ;; comparer cl avec 4 (verifier que le nombre taper est maximum de 4 chiffres)
        jg nombre1  ;; si nombre de chiffres >4 on saisie 'a' de nouveau
        lea si,a+2  ;; stocker l'adresse de a en si (octet 1 pour longuer max,octer 2 pour nombre taper, reste c'est les caracteres taper)
    boucle1 :    
        cmp cl,01h  ;; comparer cl avec 1   
        jb nombre2  ;; si cl<1 donc la 'a' est valid et il faut saisir la deuxieme nb
        mov al,[si] ;; stocker la [si] dans al
        cmp al,30h  ;; comparer le chiffre dans la position si avec 0 
        jb nombre1  ;; si al<0 donc ce n'est pas un chiffre et il faut saisir le nombre de nouveau
        cmp al,39h  ;; comparer le chiffre dans la position si avec 9
        ja nombre1  ;; si al>9 donc ce n'est pas un chiffre et il faut saisir le nombre de nouveau
        sub al,30h
        mov [SI],al
        dec cl      ;; cl=cl-1 (decrementer le compteur)
        inc si      ;; si=si+1 (passer au caractere suivant)
        jmp boucle1  ;; si le chiffre actuelle est valide, on passe de nouveau les memes etapes pour le caractere suivant

nombre2:   
CRLF ;; retour a la ligne
 ;;affichage msgB
    mov ah,9h
    lea dx,msgB
    int 21h
 ;;lire B
    mov ah,0ah 
    lea dx,b
    int 21h
;;verifier que A n'est composer que des chiffre 
        mov cl,b+1  ;; stocker nombre de caractere taper dans cl
        add cl,30h  ;; ajouter 30h a cl car en compare en hexa
        cmp cl,30h  ;; comparer cl avec 0 (verifier que le nombre taper est non vide)
        je nombre2  ;; si nombre taper est vide on saisie 'b' de nouveau
        cmp cl,34h  ;; comparer cl avec 4 (verifier que le nombre taper est maximum de 4 chiffres)
        jg nombre2  ;; si nombre de chiffres >4 on saisie 'b' de nouveau
        lea si,b+2  ;; stocker l'adresse de a en si (octet 1 pour longuer max,octer 2 pour nombre taper, reste c'est les caracteres taper)
    boucle2 :    
        cmp cl,31h  ;; comparer cl avec 1   
        jb operation  ;; si cl<1 donc 'b' est valid et il faut saisir l'operateur
        mov al,[si] ;; stocker la [si] dans al
        cmp al,30h  ;; comparer le chiffre dans la position si avec 0 
        jb nombre2  ;; si al<0 donc ce n'est pas un chiffre et il faut saisir le nombre de nouveau
        cmp al,39h  ;; comparer le chiffre dans la position si avec 9
        ja nombre2  ;; si al>9 donc ce n'est pas un chiffre et il faut saisir le nombre de nouveau
        dec cl      ;; cl=cl-1 (decrementer le compteur)
        inc si      ;; si=si+1 (passer au caractere suivant)
        jmp boucle2  ;; si le chiffre actuelle est valide, on passe de nouveau les memes etapes pour le caractere suivant
operation:
CRLF ;; retour a la ligne  
 ;;affichage msgOP
    mov ah,9h
    lea dx,msgOP
    int 21h
;;lire op
    mov ah,1h
    int 21h
    mov op,al
;; verifier que op est dans /,+,-,*
cmp op,2bh 
je addition
cmp op,2ah
je multi
cmp op,2dh
je soustr
cmp op,2fh
je division
jmp operation



;;a+b
addition:

jmp affiche 
;;a*b
multi:
jmp affiche 
;;a-b
soustr:
jmp affiche  
;;a/b
division:
jmp affiche 

affiche:
 CRLF ;; retour a la ligne   
  mov ah,9h
  lea dx,res
  int 21h
  ;

;;fin du programme
fin :  
    mov ah,4ch
    int 21h

code ends 
end main