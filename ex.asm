

                        ;o͜o╚═════ஜ۩-Calculatrice-۩ஜ═════╝o͜o
                        ;|	           IUT METZ		|
                        ;|            1A DUT Informatique       |
                        ;|				        |
                        ;|            Projet Assembleur         |
                        ;|	        Omar Elloumi		|
                        ;|	       Younes Ghoniem		|
                        ;|______________________________________|    
        
; les valeurs autorisées sont de 0 a 65535 (FFFF)
assume ds:data, cs:code
data segment
msg1 db 0Dh,0Ah, 0Dh,0Ah, 'Entrer le premier nombre: $'
msg2 db "choisisez un operateur:    +  -  *  /     : $"
msg3 db "Entrer le deuxieme nombre: $"
msg4 db  0dh,0ah , 'resultat : $' 
msg5 db  0dh,0ah , 'reste : $' 
reste db  0,"$"
moins      DB      ?       ; on l'utilise pour le carry flag.
; operateur peuvent etre: '+','-','*','/' .
opr db '?'
; first and second number:
num1 dw ?
num2 dw ?
data ends
;;; cette macro est INSPRIRE de emu8086.inc ;;;
; cette marco ecris un caractere dans AL et avance
insert    MACRO   car
        PUSH    AX
        MOV     AL, car
        MOV     AH, 0Eh
        INT     10h     
        POP     AX
ENDM
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


org 100h
code segment 

main:
        mov ax,data
        mov ds,ax
;affichage de msg1: Entrer le premier nombre
lea dx, msg1
mov ah, 09h    
int 21h  

; avoir un nombre signee 
; le resultat est enregistre dans cx

call scan_num

; stocker le premier nombre
mov num1, cx 

; nouveau ligne
insert 0Dh
insert 0Ah


;pour verfier que le opr entrer est valide
verif:
;afficher le msg2: choisisez un operateur:    +  -  *  /     : 
lea dx, msg2
mov ah, 09h    
int 21h  

;avoir operateur:
mov ah, 1h   
int 21h
mov opr, al

; nouveau ligne
insert 0Dh
insert 0Ah


cmp opr, '*'
jb verif
cmp opr, '/'
ja verif


; afficher le message3 : Entrer le deuxieme nombre
lea dx, msg3
mov ah, 09h
int 21h  

; avoir un nombre signee 
; le resultat est enregistre dans cx

call scan_num


; stocker le deuxieme nombre
mov num2, cx 

; afficher le message4 : resultat 
lea dx, msg4
mov ah, 09h     
int 21h  


; calculer:
cmp opr, '+'
je addition

cmp opr, '-'
je soustr

cmp opr, '*'
je multi

cmp opr, '/'
je do_div


addition:

mov ax, num1
add ax, num2
call aff_res    ; afficher le resultat

jmp fin

soustr:

mov ax, num1
sub ax, num2
call aff_res    ; afficher le resultat

jmp fin


multi:

mov ax, num1
imul num2 ; (dx:ax) = ax * num2. 
call aff_res    ; afficher resultat
; dx sera ignorer (calc fonctionne uniquement avec des nombres pas tres grand).
jmp fin


do_div:
; dx sera ignorer (calc fonctionne uniquement avec des nombres pas tres grand).
mov dx, 0
mov ax, num1
idiv num2  ; ax = (dx ax) / num2.
cmp dx, 0
jnz approx
call aff_res    ; afficher resultat
jmp fin
approx:
add dl,30h
mov reste,dl
call aff_res    ; afficher resultat


lea dx, msg5
mov ah, 09h    
int 21h 
lea dx, reste
mov ah, 09h    
int 21h  
jmp fin
;;; scan_num est INSPRIRE de emu8086.inc ;;;

; avoir un nombre signee 
; le resultat est enregistre dans cx
SCAN_NUM        PROC    
        PUSH    DX
        PUSH    AX
        PUSH    SI

        MOV     CX, 0

        ; remettre le flag
        MOV     CS:moins, 0

chiffre_suivant:
        ; obdixir le caractère du clavier
        ; et le mettre dans AL
        MOV     AH, 00h
        INT     16h
        ; et l'afficher
        MOV     AH, 0Eh
        INT     10h

        ; verifier si il y a le signe moins 
        CMP     AL, '-'
        JE      set_minus

        ; verifier si le caractere taper c'est l'entrer 
        ; si c'est le cas on a fini la saisie, sinon on passe a la verification suivante
        CMP     AL, 0Dh  
        JNE     non_entrer
        JMP     fin_saisie
non_entrer:
        CMP     AL, 8                   ; verifier si le touche de retour est taper
        JNE     verif_retour            
        MOV     DX, 0                   ; si c'est le cas, on retire le chiffre precedent 
        MOV     AX, CX                  ; division:
        DIV     CS:dix                  ; AX = DX:AX / 10 (DX-rem).
        MOV     CX, AX
        insert    ' '                     ; position claire
        insert    8                       ; retour une autre fois
        JMP     chiffre_suivant
verif_retour:
        ; verifier s'il est compose que avec des chiffres
        CMP     AL, '0'
        JAE     ok_AE_0
        JMP     suppr_non_chiff
ok_AE_0:        
        CMP     AL, '9'
        JBE     verifer ; si le chiffre a passer tout les tests avec succes donc c'est verifier
suppr_non_chiff:       
        insert    8       ; retour.
        insert    ' '     ; remplacer le caractere par ' '.
        insert    8       ; retour une autre fois        
        JMP     chiffre_suivant        
verifer:
        ; multiplier CX par 10 
        PUSH    AX
        MOV     AX, CX
        MUL     CS:dix                  ; DX:AX = AX*10
        MOV     CX, AX
        POP     AX

        ; verifier si le nombre est tres grand
        ; (il faut que le resultat est de 16 bits)
        CMP     DX, 0
        JNE     t_grand1

        ; convertir en decimale
        SUB     AL, 30h

        ; ajouter AL a CX:
        MOV     AH, 0
        MOV     DX, CX      ; sauvegarde, au cas où le résultat serait trop grand.
        ADD     CX, AX
        JC      t_grand2    ; jump si le nombre est grand (jump if carry).

        JMP     chiffre_suivant

set_minus:
        MOV     CS:moins, 1
        JMP     chiffre_suivant

t_grand2:
        MOV     CX, DX      ; restaurer la valeur de sauvegarde avant d'ajouter.
        MOV     DX, 0       ; DX était nul avant la sauvegarde
t_grand1:
        MOV     AX, CX
        DIV     CS:dix  ; reverse last DX:AX = AX*10, make AX = DX:AX / 10
        MOV     CX, AX
        insert    8       ; retour.
        insert    ' '     ; remplacer le caractere par ' '.
        insert    8       ; retour une autre fois             
        JMP     chiffre_suivant 
        
        
fin_saisie:
        ; verifier si le flag est a 0 ou 1
        ; si 0 on arrete 
        ;sinon NEG CX, (négation de cx)
        CMP     CS:moins, 0
        JE      non_moins
        NEG     CX
non_moins:      
        ;; recuperer les donnees
        POP     SI
        POP     AX
        POP     DX
        RET

SCAN_NUM        ENDP



; cette procedure affiche le nombre dans AX
; utiliser avec aff_res_NS pour afficher les nombres non signee:
aff_res       PROC   
        PUSH    DX
        PUSH    AX

        CMP     AX, 0           
        JNZ     not_zero

        insert    '0'
        JMP     printed

not_zero:
        ; valeur Absolu si c'est negative
        CMP     AX, 0
        JNS     positive
        NEG     AX

        insert    '-'

positive:
        CALL    aff_res_NS
printed:
        POP     AX
        POP     DX
        RET
aff_res       ENDP

; cette procedure affiche les nombres non signee
aff_res_NS   PROC   
        PUSH    AX
        PUSH    BX
        PUSH    CX
        PUSH    DX

        ; flag to prevent printing zeros before number:
        MOV     CX, 1

        ; (result of "/ 10000" is always less or equal to 9).
        MOV     BX, 10000       ; 2710h - divider.

        ; AX zero?
        CMP     AX, 0
        JZ      afficher_zero

begin_print:

        ; verifier si le diviseur est egale a 0:
        CMP     BX,0
        JZ      end_print
         ; pour eviter d'ecrire des 0 avant le nombre:
        CMP     CX, 0
        JE      calc
        ; si AX<BX alors le resultat de division sera zero
        ; donc il faut qu'on essaye a chaque fois 
        CMP     AX, BX
        JB      skip
calc:
        MOV     CX, 0   ; set flag.
        MOV     DX, 0   ; initialiser le reste a 0
        DIV     BX      ; AX = DX:AX / BX   (DX=le reste).

        ; on commence a afficher le dernier chiffre
        ; AH est toujourds ZERO, donc c'est ignorer
        ADD     AL, 30h    ; convertir a ASCII code.
        insert    AL


        MOV     AX, DX  ; stocker le reste de derniere division

skip:
        ;BX=BX/10
        PUSH    AX
        MOV     DX, 0
        MOV     AX, BX
        DIV     CS:dix  ; AX = DX:AX / 10   (DX=le reste).
        MOV     BX, AX
        POP     AX

        JMP     begin_print
        
afficher_zero:
        insert    '0'
        
end_print:
        POP     DX
        POP     CX
        POP     BX
        POP     AX
        RET

aff_res_NS   ENDP

dix  DW      10      ; utilisee pour  multiplier/diviser dans SCAN_NUM & aff_res_NS.


fin:
mov ah,4ch
int 21h

code ends

end main

