;________________________________________________________________________________________________________________________
                                         ;o͜o╚═════ஜ۩-Calculatrice-۩ஜ═════╝o͜o
                                        ;|	         IUT METZ		|
                                        ;|         1A DUT Informatique          |
                                        ;|				        |
                                        ;|          Projet Assembleur           |
                                        ;|	      Omar Elloumi		|
                                        ;|	     Younes Ghoniem		|
                                        ;|______________________________________|    
;________________________________________________________________________________________________________________________
; les valeurs autorisées sont de 0 a 65535 (FFFF)
.286
SSEG SEGMENT STACK
        DB      32 DUP ("STACK---")
SSEG ENDS

DSEG SEGMENT
        msg1 db 0Dh,0Ah, 0Dh,0Ah, 'Entrer le premier nombre: $'
        msg2 db "choisisez un operateur:    +  -  *  /  .   : $"
        msg3 db "Entrer le deuxieme nombre: $"
        msg4 db  0dh,0ah , 'resultat : $' 
        msg5 db  0dh,0ah , 'reste : $' 
        msg6 db  0dh,0ah , 'Division par 0 est impossible$' 
		DIX    DW     10             	; utilisee pour  multiplier/diviser dans SCAN_NUM & AFF_RES_NS.
        reste dw  ?
        x dw 2,"$"
        moins      DB      ?       ; on l'utilise pour le carry flag.
        ; operateur peuvent etre: '+','-','*','/','.' .
        opr db ?
        ; first and second number:
        num1 dw ?
        num2 dw ?
        sn1 DB 0
        sn2 DB 0
        rest db 0
DSEG ENDS
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
CSEG SEGMENT 'CODE'
ASSUME CS:CSEG, SS:SSEG, DS:DSEG
MAIN PROC FAR
        PUSH DS
        PUSH 0
        ;;
        mov ax,DSEG
        mov ds,ax
	;affichage de msg1: Entrer le premier nombre
	                LEA    DX, MSG1
	                MOV    AH, 09H
	                INT    21H
	; avoir un nombre signee
	; le resultat est enregistre dans cx
	                CALL   SCAN_NUM
	                CMP    MOINS,1
	                JE     S_N1
	                JMP    SUITE
	S_N1:           
	                MOV    SN1,1
	SUITE:          
	; stocker le premier nombre
	                MOV    NUM1, CX
	; nouveau ligne
	                INSERT 0DH
	                INSERT 0AH
	;pour verfier que le opr entrer est valide
        ;_______________________________________________
	VERIF:         
	;afficher le msg2: choisisez un operateur:    +  -  *  /  .   :
	                LEA    DX, MSG2
	                MOV    AH, 09H
	                INT    21H
	;avoir operateur:
	                MOV    AH, 1H
	                INT    21H
	                MOV    OPR, AL
	; nouveau ligne
	                INSERT 0DH
	                INSERT 0AH

	                CMP    OPR, '*'
	                JB     VERIF
	                CMP    OPR, '/'
	                JA     VERIF
	; afficher le message3 : Entrer le deuxieme nombre
	                LEA    DX, MSG3
	                MOV    AH, 09H
	                INT    21H
	; avoir un nombre signee
	; le resultat est enregistre dans cx

	                CALL   SCAN_NUM
	                CMP    MOINS,1
	                JE     S_N2
	                JMP    SUIT
	S_N2:           
	                MOV    SN2,1
        ;_______________________________________________
	SUIT:                   
	; stocker le deuxieme nombre
	                MOV    NUM2, CX

	; afficher le message4 : resultat
	                LEA    DX, MSG4
	                MOV    AH, 09H
	                INT    21H

        ;_______________________________________________
	; calculer:
	                CMP    OPR, '+'
	                JE     ADDITION

	                CMP    OPR, '-'
	                JE     SOUSTR

	                CMP    OPR, '*'
	                JE     MULTI

	                CMP    OPR, '/'
	                JE     DO_DIV
	                
	                CMP    OPR, '.'
	                JE     DO_PGCD
;________________________________________________________________________________________________________________________
	ADDITION:       
	          
	                MOV    AX, NUM1
	                ADD    AX, NUM2
	                CALL   AFF_RES        	; AFFICHER LE RESULTAT

	                JMP    FIN
;________________________________________________________________________________________________________________________
	SOUSTR:         
	                MOV    AX, NUM1
	                SUB    AX, NUM2
	                CALL   AFF_RES        	; AFFICHER LE RESULTAT

	                JMP    FIN
;________________________________________________________________________________________________________________________
	MULTI:          
	                MOV    AX, NUM1
	                IMUL   NUM2           ; (dx:ax) = ax * num2.

	; dx sera ignorer (calc fonctionne uniquement avec des nombres pas tres grand).
	                JMP    FIN
;________________________________________________________________________________________________________________________
	DO_DIV:       
	; dx sera ignorer (calc fonctionne uniquement avec des nombres pas tres grand).
	                CMP    NUM2,0          	;; verifier que le denumerateur est different de 0
	                JE     IMPOSSIBLE
	                JMP    NEXTTT

	        IMPOSSIBLE:     
	                MOV    AH,9H
	                LEA    DX,MSG6
	                INT    21H
	                JMP    FIN

	        NEXTTT:         
	                MOV    DX, 0
	                MOV    AX, NUM1
	                CMP    SN1,1
	                JE     NEGATIVE_NB1
	                INC    X
	                JMP    NEXT1

	        NEGATIVE_NB1:   
	                NEG    AX
	                DEC    X

	        NEXT1:          
	                CMP    SN2,1
	                JE     NEGATIVE_NB2
	                INC    X
	                JMP    NEXT2

	        NEGATIVE_NB2:   
	                NEG    NUM2
	                DEC    X

	        NEXT2:          
	                CMP    X,1
	                JE     NEGATIF
	                CMP    X,3
	                JE     NEGATIF
	                CMP    X,0
	                JE     DIVIS
	                CMP    X,4
	                JE     DIVIS


	        NEGATIF:        
	                INSERT '-'
;________________________________________________________________________________________________________________________
	DIVIS:          
	                IDIV   NUM2            	; ax = (dx ax) / num2.
	                CMP    AX,0          	; comparer le resultat de division avec 0, si c le cas on decale par un caractere et on le retire pour eviter d'afficher -0
	                JE     SUPP_MOINS
	                JMP    NEXTT
	        SUPP_MOINS:    
	                INSERT 8              	; retour.
	                INSERT ' '            	; remplacer le moins par ' '.
	                INSERT 8              	; retour une autre fois
	        NEXTT:          
	                CMP    DX, 0
	                JNZ    AFF_RESTE

	                CALL   AFF_RES        	; AFFICHER RESULTAT
	                JMP    FIN
                
	        AFF_RESTE:      
	                CALL   AFF_RES
	                MOV    BL,DL
	                CALL   CHANGE         	;CHANGER LA FORME DU RESTE
	                LEA    DX, MSG5
	                CALL   RESULT         	;AFFICHER LE RESTE ET ON PREND COMPTE DE RETENUE
	                JMP    FIN
;________________________________________________________________________________________________________________________
	DO_PGCD:
	; but obtenir le PGCD des deux nombres.
					MOV	   AX,NUM1
			CAS0:
					CMP	   AX,0
					JE     CAS1
					CMP	   NUM2,0
					JE     CAS2
			CAS3:					;NUM1 et NUM2 diff de 0
					CMP    AX,NUM2
					JGE    SMBR1
					JL     SMBR2
			SMBR1:					;Soustraction sur le membre 1 soit num1
	                SUB    AX, NUM2
	                JMP    CAS0
	        SMBR2:
					SUB    NUM2, AX
	                JMP    CAS0
	        
			CAS1:					;NUM1 est egale a 0 resultat cest NUM2
					MOV    AX, NUM2
					CALL   AFF_RES
					JMP    FIN
					
			CAS2:					;NUM2 est egale a 0 resultat cest NUM1
					MOV    AX, NUM1
					CALL   AFF_RES
					JMP    FIN
			
					
					
;________________________________________________________________________________________________________________________
	;scan_num est INSPRIRE de emu8086.inc 
	;avoir un nombre signee
	;le resultat est enregistre dans cx
SCAN_NUM PROC
	;Sauvgarder les registres
	                PUSH   DX
	                PUSH   AX
	                PUSH   SI

	                MOV    CX, 0

	; remettre le flag
	                MOV    MOINS, 0

	CHIFFRE_SUIVANT:
	; obtenir le caractère du clavier
	; et le mettre dans AL
	                MOV    AH, 00h
	                INT    16h
	; et l'afficher
	                MOV    AH, 0Eh
	                INT    10h

	; verifier si il y a le signe moins
	                CMP    AL, '-'
	                JE     SET_MINUS

	; verifier si le caractere taper c'est l'entrer
	; si c'est le cas on a fini la saisie, sinon on passe a la verification suivante
	                CMP    AL, 0Dh
	                JNE    NON_ENTRER
	                JMP    FIN_SAISIE
	NON_ENTRER:     
	                CMP    AL, 8          	; verifier si le touche de retour est taper
	                JNE    VERIF_RETOUR
	                MOV    DX, 0          	; si c'est le cas, on retire le chiffre precedent
	                MOV    AX, CX         	; division:
	                iDIV    dix         	; AX = DX:AX / 10 (DX-rem).
	                MOV    CX, AX
	                INSERT ' '            	; position claire
	                INSERT 8              	; retour une autre fois
	                JMP    CHIFFRE_SUIVANT
	VERIF_RETOUR:   
	; verifier s'il est compose que avec des chiffres
	                CMP    AL, '0'
	                JAE    ok_AE_0
	                JMP    SUPPR_NON_CHIFF
	ok_AE_0:        
	                CMP    AL, '9'
	                JBE    VERIFER         	; si le chiffre a passer tout les tests avec succes donc c'est verifier
	SUPPR_NON_CHIFF:
	                INSERT 8              	; retour.
	                INSERT ' '            	; remplacer le caractere par ' '.
	                INSERT 8              	; retour une autre fois
	                JMP    CHIFFRE_SUIVANT
	VERIFER :        
	; multiplier CX par 10
	                PUSH   AX
	                MOV    AX, CX
	                iMUL    dix         	; DX:AX = AX*10
	                MOV    CX, AX
	                POP    AX

	; verifier si le nombre est tres grand
	; (il faut que le resultat est de 16 bits)
	                CMP    DX, 0
	                JNE    T_GRAND1

	; convertir en decimale
	                SUB    AL, 30h

	; ajouter AL a CX:
	                MOV    AH, 0
	                MOV    DX, CX         	; sauvegarde, au cas où le résultat serait trop grand.
	                ADD    CX, AX
	                JC     T_GRAND2       	; jump si le nombre est grand (jump if carry).

	                JMP    CHIFFRE_SUIVANT

	SET_MINUS:      
	                MOV    moins, 1
	                JMP    CHIFFRE_SUIVANT

	T_GRAND2:       
	                MOV    CX, DX         	; restaurer la valeur de sauvegarde avant d'ajouter.
	                MOV    DX, 0          	; DX était nul avant la sauvegarde
	T_GRAND1:       
	                MOV    AX, CX
	                iDIV    dix         	; reverse last DX:AX = AX*10, make AX = DX:AX / 10
	                MOV    CX, AX
	                INSERT 8              	; retour.
	                INSERT ' '            	; remplacer le caractere par ' '.
	                INSERT 8              	; retour une autre fois
	                JMP    CHIFFRE_SUIVANT
        
        
	FIN_SAISIE:     
	; verifier si le flag est a 0 ou 1
	; si 0 on arrete
	;sinon NEG CX, (négation de cx)
	                CMP    MOINS, 0
	                JE     NON_MOINS
	                NEG    CX
	NON_MOINS:      
	;; recuperer les donnees
	                POP    SI
	                POP    AX
	                POP    DX
	                RET

SCAN_NUM ENDP
;________________________________________________________________________________________________________________________
;pour changer le format du reste de ascii vers decimale
CHANGE PROC
	                MOV    AH,0
	                MOV    AL,BL

	                MOV    BL,10
	                DIV    BL

	                MOV    BL,AL
	                MOV    BH,AH

	                ADD    BH,30H         	; convert to ascii code
	                MOV    rest,BH

	                MOV    AH,0
	                MOV    AL,BL
	                MOV    BL,10
	                DIV    BL

	                MOV    BL,AL
	                MOV    BH,AH

	                ADD    BH,30h         	; convert to ascii code
	                ADD    BL,30h         	; covert to ascii code

	                RET
CHANGE ENDP
;________________________________________________________________________________________________________________________
;pour afficher le reste apres convertir en format decimale
RESULT PROC

	                MOV    AH,09H
	                INT    21H

	                MOV    DL,BL
	                MOV    AH,02H
	                INT    21H

	                MOV    DL,BH
	                MOV    AH,02H
	                INT    21H

	                MOV    DL,rest
	                MOV    AH,02H
	                INT    21H
	                RET
RESULT ENDP
;________________________________________________________________________________________________________________________
	; cette procedure affiche le nombre dans AX
	; utiliser avec AFF_RES_NS pour afficher les nombres non signee:
AFF_RES PROC
	                PUSH   DX
	                PUSH   AX

	                CMP    AX, 0
	                JNZ   NOT_ZERO

	                INSERT '0'
	                JMP    PRINTED

	NOT_ZERO:       
	; valeur Absolu si c'est negative
	                CMP    AX, 0
	                JNS    POSITIVE
	                NEG    AX

	                INSERT '-'

	POSITIVE:       
	                CALL   AFF_RES_NS
	PRINTED:        
	                POP    AX   ;res
	                POP    DX   ;retenue
	                RET
AFF_RES ENDP
;________________________________________________________________________________________________________________________
	; cette procedure affiche les nombres non signee
AFF_RES_NS PROC
	                PUSH   AX
	                PUSH   BX
	                PUSH   CX
	                PUSH   DX

	; flag to prevent printing zeros before number:
	                MOV    CX, 1

	                MOV    BX, 10000

	; AX zero?
	                CMP    AX, 0
	                JZ     AFFICHER_ZERO

	BEGIN_PRINT:    

	; verifier si le diviseur est egale a 0:
	                CMP    BX,0
	                JZ     END_PRINT
	; pour eviter d'ecrire des 0 avant le nombre:
	                CMP    CX, 0
	                JE     CALC
	; si AX<BX alors le resultat de division sera zero
	; donc il faut qu'on essaye a chaque fois
	                CMP    AX, BX
	                JB     SKIP
	CALC:           
	                MOV    CX, 0          	; set flag.
	                MOV    DX, 0          	; initialiser le reste a 0
	                DIV    BX             	; AX = DX:AX / BX   (DX=le reste).

	; on commence a afficher le dernier chiffre
	; AH est toujourds ZERO, donc c'est ignorer
	                ADD    AL, 30h        	; convertir a ASCII code.
	                INSERT AL


	                MOV    AX, DX         	; stocker le reste de derniere division

	SKIP:           
	;BX=BX/10
	                PUSH   AX
	                MOV    DX, 0
	                MOV    AX, BX
	                iDIV    dix         	; AX = DX:AX / 10   (DX=le reste).
	                MOV    BX, AX
	                POP    AX

	                JMP    BEGIN_PRINT
        
	AFFICHER_ZERO:  
	                INSERT '0'
        
	END_PRINT:      
	                POP    DX
	                POP    CX
	                POP    BX
	                POP    AX
	                RET
AFF_RES_NS ENDP
;________________________________________________________________________________________________________________________
fin:
RET
MAIN ENDP
CSEG ENDS
        END MAIN
