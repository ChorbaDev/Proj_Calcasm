

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
        msg1 db 0Dh,0Ah, 0Dh,0Ah, 'Entrez le premier nombre: $'
        msg2 db "choisisez un operateur:    +  -  *  /     : $"
        msg3 db "Entrez le deuxieme nombre: $"
        msg4 db  0dh,0ah , 'resultat : $' 
        msg5 db  0dh,0ah , 'reste : $' 
        msg6 db  0dh,0ah , 'Division par 0 est impossible$' 
        reste dw  ?
        x dw 2,"$"
        moins      DB      ?       ; on l'utilise pour le carry flag.
        ; operateurs peuvent etre: '+','-','*','/' .
        opr db ?
        ; premier et deuxieme nb:
        num1 dw ?
        num2 dw ?
        sn1 DB 0
        sn2 DB 0
        rest db 0
data ends
;;; cette macro est INSPRIREE de emu8086.inc ;;;
; cette marco ecrit un caractere dans AL et avance
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
;affichage de msg1: Entrez le premier nombre
lea dx, msg1
mov ah, 09h    
int 21h  

; avoir un nombre signe 
; le resultat est enregistre dans cx

call scan_num
cmp CS:moins,1
je s_n1
jmp suite
s_n1: 
mov sn1,1
suite:
; stocker le premier nombre
mov num1, cx 

; nouvelle ligne
insert 0Dh
insert 0Ah


;pour verfier que l opr entrer est valide
verif:
;afficher le msg2: choisisez un operateur:    +  -  *  /     : 
lea dx, msg2
mov ah, 09h    
int 21h  

;avoir operateur:
mov ah, 1h   
int 21h
mov opr, al

; nouvelle ligne
insert 0Dh
insert 0Ah


cmp opr, '*'
jb verif
cmp opr, '/'
ja verif


; afficher le message3 : Entrez le deuxieme nombre
lea dx, msg3
mov ah, 09h
int 21h  

; avoir un nombre signe 
; le resultat est enregistre dans cx

call scan_num
cmp CS:moins,1
je s_n2
jmp suit
s_n2: 
mov sn2,1
suit:
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
; a supprimer ;;;;;;;;;;;;;; DO NOT FORGET;;;;;;;;;;;;;;
cmp sn1,1
je decc
inc x
jmp nxt
decc:
dec x
nxt:
cmp sn2,1
je decc2
inc x
jmp nxt2
decc2:
dec x
nxt2:
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
; dx sera ignore (calc fonctionne uniquement avec des nombres pas tres grand).
jmp fin


do_div:
; dx sera ignore (calc fonctionne uniquement avec des nombres pas tres grand).
cmp num2,0  ;; verifier que le denumerateur est different de 0
je impossible
jmp nexttt

impossible:
mov ah,9h
lea dx,msg6
int 21h
jmp fin

nexttt:
mov dx, 0
mov ax, num1
cmp sn1,1
je negative_nb1
inc x
jmp next1

negative_nb1:
neg ax
dec x

next1:
cmp sn2,1
je negative_nb2
inc x
jmp next2

negative_nb2:
neg num2
dec x

next2:
cmp x,1
je negatif
cmp x,3
je negatif
cmp x,0
je divis
cmp x,4
je divis


negatif:
insert '-'

divis:
idiv num2  ; ax = (dx ax) / num2.
cmp ax,0 ; comparer le resultat de la division avec 0, si c est le cas on decale par un caractere et on le retire pour eviter d'afficher -0
je supp_moins       
jmp nextt
supp_moins:
        insert    8       ; retour.
        insert    ' '     ; remplacer le moins par ' '.
        insert    8       ; retour une autre fois    
nextt:
        cmp dx, 0
        jnz aff_reste

call aff_res    ; afficher resultat
jmp fin

aff_reste:      ;afficher le reste de la division
call aff_res  
mov BL,DL
CALL CHANGE    ;changer la forme du reste 
lea dx, msg5
CALL RESULT     ;afficher le reste et on prend compte la retenue
jmp fin

;;; scan_num est INSPRIRE de emu8086.inc ;;;

; avoir un nombre signe 
; le resultat est enregistre dans cx
SCAN_NUM        PROC    
        ;Sauvgarder les registres 
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

        ; verifier s il y a le signe moins 
        CMP     AL, '-'
        JE      set_minus

        ; verifier si le caractere tape c'est entrer 
        ; si c'est le cas on a fini la saisie, sinon on passe a la verification suivante
        CMP     AL, 0Dh  
        JNE     non_entrer
        JMP     fin_saisie
non_entrer:
        CMP     AL, 8                   ; verifier si le touche de retour est tapee
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
        JBE     verifer ; si le chiffre a passe tout les tests avec succes donc c'est verifie
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
        ; (il faut que le resultat soit de 16 bits)
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


CHANGE PROC
    MOV AH,0
    MOV AL,BL

    MOV BL,10
    DIV BL

    MOV BL,AL
    MOV BH,AH

    ADD BH,30H      ; convertir en code ascii
    MOV rest,BH

    MOV AH,0
    MOV AL,BL
    MOV BL,10
    DIV BL

    MOV BL,AL
    MOV BH,AH

    ADD BH,30h      ; convertir en code ascii
    ADD BL,30h     ; convertir en code ascii

    RET
CHANGE ENDP
RESULT PROC

    MOV AH,09H
    INT 21H

    MOV DL,BL
    MOV AH,02H
    INT 21H

    MOV DL,BH
    MOV AH,02H
    INT 21H

    MOV DL,rest
    MOV AH,02H
    INT 21H

    RET
RESULT ENDP
; cette procedure affiche le nombre dans AX
; utiliser avec aff_res_NS pour afficher les nombres non signes:
aff_res       PROC   
        PUSH    DX
        PUSH    AX

        CMP     AX, 0           
        JNZ     not_zero

        insert    '0'
        JMP     printed

not_zero:
        ; valeur Absolu si c'est negatif
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

; cette procedure affiche les nombres non signes
aff_res_NS   PROC   
        PUSH    AX
        PUSH    BX
        PUSH    CX
        PUSH    DX

        ; flag pour empecher d afficher des zeros avant le nbr:
        MOV     CX, 1

        MOV     BX, 10000       

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
