;________________________________________________________________________________________________________________________
                                         ;o͜o╚═════ஜ۩-CALculatrice-۩ஜ═════╝o͜o
                                        ;|	         IUT METZ					|
                                        ;|         1A DUT Informatique          |
                                        ;|				       					|
                                        ;|          ProJEt Assembleur           |
                                        ;|	      Omar Elloumi					|
                                        ;|	     Younes Ghoniem					|
                                        ;|______________________________________|    
;________________________________________________________________________________________________________________________
; les vALeurs autorisées sont de 0 a 65535 (FFFF)
.286
SSEG SEGMENT STACK
        DB      32 DUP ("STACK---")
SSEG ENDS
;________________________________________________________________________________________________________________________
DSEG SEGMENT
		msg0  DB  "_______________________________$"
        msg1  DB  "Entrer le premier nombre: $"
        msg2  DB  "choisisez un operateur:$"
		op_b  DB  "Operation de Bases : $"
        op_bb DB  "(+) (-) (*) (/)$"
        op_s  DB  "Operation Supplementaire :$"
        op_pg DB  "PGCD : (.)$"
        op_pp DB  "PPCM : (,)$"
        msg3  DB  "Entrer le deuxieme nombre: $"
        msg4  DB  "resultat : $" 
        msg5  DB  "reste : $" 
        msg6  DB  "Division par 0 est impossible$" 
		 msg7 db  "Taper o/O pour recommencer: $"
		DIX   DW  10  ; utilisee pour  multiplier/diviser dans SCAN_NUM & AFF_RES_NS.
        reste DW  ?
        x     DW  ?
		v     DW  0
        moins DB  ?    ; on l'utilise pour le carry flag.
        opr   DB  ?	   ; operateur peuvent etre: '+','-','*','/','.',',' .
        num1  DW  ?
        num2  DW  ?
        sn1   DB  0
        sn2   DB  0
        rest  DB  0
		flag  DB  0

DSEG ENDS
;________________________________________________________________________________________________________________________
; cette marco ecris un caractere dans AL et avance
insert    MACRO   car
          PUSH    AX
          MOV     AL, car
          MOV     AH, 0Eh
          INT     10h     
          POP     AX
ENDM
;________________________________________________________________________________________________________________________
CSEG SEGMENT 'CODE'
ASSUME CS:CSEG, SS:SSEG, DS:DSEG
MAIN PROC FAR

        PUSH 	DS
        PUSH	0
        MOV 	AX,DSEG
        MOV 	DS,AX
					INSERT 0DH
	                INSERT 0AH
					 LEA    DX, MSG0
	                MOV    AH, 09H
	                INT    21H
					INSERT 0DH
	                INSERT 0AH

	;affichage de msg1: Entrer le premier nombre
	                LEA    DX, MSG1
	                MOV    AH, 09H
	                INT    21H
	; avoir un nombre signee
	; le resultat est enregistre dans CX
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

	;pour verfier que le opr entrer est vALide
;________________________________________________________________________________________________________________________
	VERIF:         
    	            INSERT 0DH

	                INSERT 0AH       
	;afficher le msg2: choisisez un operateur:    +  -  *  /  .  , :
                    LEA    DX, op_b
	                MOV    AH, 09H
	                INT    21H
	                INSERT 0DH
	                INSERT 0AH
                    LEA    DX, op_bb
	                MOV    AH, 09H
	                INT    21H
	                INSERT 0DH
	                INSERT 0AH
                    LEA    DX, op_s
	                MOV    AH, 09H
	                INT    21H
	                INSERT 0DH
	                INSERT 0AH
                    LEA    DX, op_pp
	                MOV    AH, 09H
	                INT    21H
	                INSERT 0DH
	                INSERT 0AH
                  
                  LEA    DX, op_pg

	                MOV    AH, 09H
	                INT    21H
	                INSERT 0DH
	                INSERT 0AH
                    LEA    DX, MSG2
	                MOV    AH, 09H
	                INT    21H
;lire un caractere du clavier 
	                MOV    AH, 1H
	                INT    21H
	                MOV    OPR, AL
;verif si l'operateur entre *.../
	                CMP    OPR, '*'

	                JB     INTer_verif
	                CMP    OPR, '/'
	                JA     INTer_verif
					JMP    next_nb
			INTer_verif:
					JMP	   VERIF
	next_nb:
	                INSERT 0DH
	                INSERT 0AH
	; afficher le message3 : Entrer le deuxieme nombre
	                LEA    DX, MSG3
	                MOV    AH, 09H
	                INT    21H
	; avoir un nombre signee
	; le resultat est enregistre dans CX
	                CALL   SCAN_NUM
	                CMP    MOINS,1
	                JE     S_N2
	                JMP    SUIT
	S_N2:           
	                MOV    SN2,1
;_____________________________________________________________________________________________________________
	SUIT:                   
	; stocker le deuxieme nombre
	                MOV    NUM2, CX

	; afficher le message4 : resultat
	                LEA    DX, MSG4
	                MOV    AH, 09H
	                INT    21H

 ;_______________________________________________
	; cALculer:
	                CMP    OPR, '+'
	                JE     ADDITION

	                CMP    OPR, '-'
	                JE     SOUSTR

	                CMP    OPR, '*'
	                JE     MULTI

	                CMP    OPR, '/'
	                JE     DO_DIV
	                
	                CMP    OPR, '.'
	                JE     INTer_DO_PGCD
INTer_DO_PGCD:
	JMP     DO_PGCD
					CMP    OPR, ','
	                JE     INTer_DO_PPCM
INTer_DO_PPCM:
	JMP     DO_PPCM

;________________________________________________________________________________________________________________________
ADDITION:            
	                MOV    AX, NUM1
	                ADD    AX, NUM2
	                CALL   AFF_RES        ; AFFICHER LE RESULTAT
					CALL   recommence
;________________________________________________________________________________________________________________________
SOUSTR:         
	                MOV    AX, NUM1
	                SUB    AX, NUM2
	                CALL   AFF_RES        ; AFFICHER LE RESULTAT
					CALL   recommence
;________________________________________________________________________________________________________________________
MULTI:          
	                MOV    AX, NUM1

	                IMUL   NUM2           ; (dx:AX) = AX * num2.
					CALL   AFF_RES        ; AFFICHER LE RESULTAT
					CALL   recommence
	               		  ; dx sera ignorer (cALc fonctionne uniquement avec des nombres pas tres grand).

;________________________________________________________________________________________________________________________
DO_DIV:       
MOV X,2
	; dx sera ignorer (cALc fonctionne uniquement avec des nombres pas tres grand).
	                CMP    NUM2,0          	;; verifier que le denumerateur est different de 0
	                JE     IMPOSSIBLE
	                JMP    NEXTTT

	        IMPOSSIBLE:     
	                MOV    AH,9H
	                LEA    DX,MSG6
	                INT    21H
	                CALL   recommence

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
	                CMP    X,2
	                JE     NEGATIF
	                CMP    X,0
	                JE     DIVIS
	                CMP    X,4
	                JE     DIVIS
	        NEGATIF:        
	                INSERT '-'
;________________________________________________________________________________________________________________________
	DIVIS:          
	                IDIV   NUM2            	; AX = (dx AX) / num2.
	                CMP    AX,0          	; comparer le resultat de division avec 0, si c le cas on decALe par un caractere et on le retire pour eviter d'afficher -0
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
	                CALL   recommence
	        AFF_RESTE:      
					CMP	   X,2
					JE	   A_REGLER
					JMP    DEJA_REGLER
			A_REGLER:
					CMP    sn1,1
					JE	   TYPE1
					JMP    DEJA_REGLER
			TYPE1:
					INC    AX
					CALL   AFF_RES
					MOV    DH,00h
					SUB	   NUM2,DX
					MOV    DX,NUM2
					MOV    BL,DL
					JMP	   prt_reste
			DEJA_REGLER:
	                CALL   AFF_RES
	                MOV    BX,DX
			prt_reste:		
	                CALL   CHANGE         	;CHANGER LA FORME DU RESTE
					INSERT 0DH
	                INSERT 0AH
					LEA    DX, MSG5
	                CALL   RESULT         	;AFFICHER LE RESTE ET ON PREND COMPTE DE RETENUE
	                CALL   recommence
;________________________________________________________________________________________________________________________
	DO_PGCD:
	; but obtenir le PGCD des deux nombres.
					CALL	VER_NEG
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
	        
			CAS1:					;NUM1 est egALe a 0 resultat cest NUM2
					MOV    AX, NUM2
					CALL   AFF_RES
					CALL   recommence
					
			CAS2:					;NUM2 est egALe a 0 resultat cest NUM1
					MOV    AX, NUM1
					CALL   AFF_RES
					CALL   recommence

;________________________________________________________________________________________________________________________
;but obtenir le PPCM de deux nombres
	DO_PPCM:
					CALL	VER_NEG
					MOV	   AX, NUM1			
					MOV    BX, NUM2
			ETA0:								;ETA0 etape initiALe tant que num1!=num2 ALors si num1>num2 eta1 sinon si num1<num2 eta2
					CMP		AX, BX
					JE		ETAF
					JG		ETA1
					JL		ETA2

			ETA1:								;ETA1 BX+=NUM2
					ADD		BX, NUM2
					JMP		ETA0
			ETA2:								;ETA2 AX+=NUM2
					ADD		AX, NUM1
					JMP		ETA0		
			ETAF:
												; lorsque NUM1=NUM2 après la boucle ALors AX est le resultat
					CALL   AFF_RES
					CALL   recommence	
;________________________________________________________________________________________________________________________
VER_NEG PROC
					CMP		SN1,1
					JE		NEG1
					JMP		CNT
			NEG1:
					NEG		NUM1
			CNT:
					CMP		SN2,1
					JE		NEG2
					JMP		FIN_VER_NEG
			NEG2:
					NEG		NUM2

			FIN_VER_NEG:
					RET
VER_NEG ENDP			
					
;________________________________________________________________________________________________________________________
	;scan_num est INSPRIRE de emu8086.inc 
	;avoir un nombre signee

	;le resultat est enregistre dans CX
SCAN_NUM        PROC    
        			;Sauvgarder les registres 
					PUSH    DX
					PUSH    AX
					PUSH    SI
					MOV     CX,0
					INSERT  0DH
					INSERT  0AH
					; remettre le flag
					MOV     moins, 0

			chiffre_suivant:
					;obtenir le caractère du clavier
					;et le mettre dans AL
					MOV     AH,00h
					INT     16h
					;verifier si cx est 0 donc si on tape le retour il faut initialiser le flag a 0
					CMP 	CX,0
					JNE 	aff
					CMP 	AL,8
					JNE 	aff
					MOV 	moins,0
					;afficher le caractere taper
			aff:
					MOV     AH, 0Eh
					INT     10h
					; verifier si le charactere taper est -
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
					iDIV    dix                  ; AX = DX:AX / 10 (DX-rem).
					MOV     CX, AX
					insert  ' '                     ; position claire
					insert  8                       ; retour une autre fois
					JMP     chiffre_suivant
			verif_retour:
					; verifier s'il est compose que avec des chiffres
					CMP     AL, '0'
					JAE     ok_AE_0
					JMP     suppr_non_chiff
			ok_AE_0:        
					CMP     AL, '9'
					JBE     verifier ; si le chiffre a passer tout les tests avec succes donc c'est verifier
			suppr_non_chiff:       
					insert  8       ; retour.
					insert  ' '     ; remplacer le caractere par ' '.
					insert  8       ; retour une autre fois        
					JMP     chiffre_suivant        
			verifier:
					; multiplier CX par 10 
					PUSH    AX
					MOV     AX, CX
					IMUL    dix                  ; DX:AX = AX*10
					MOV     CX, AX
					POP     AX
					; verifier si le nombre est tres grand
					; (il faut que le resultat soit de 16 bits)
					CMP     DX, 0
					JNE     t_grand1

					; convertir en decimaLe
					SUB     AL, 30h

					; ajouter AL a CX:
					MOV     AH, 0
					MOV     DX, CX      ; sauvegarde, au cas où le résultat serait trop grand.
					ADD     CX, AX
					JC      t_grand2    ; jump si le nombre est grand (jump if carry).
					JMP     chiffre_suivant

			set_minus:
					CMP		 moins,1
					JE 		suppr_non_chiff
					CMP 	CX,0
					JNE 	suppr_non_chiff
					MOV     moins, 1
					JMP     chiffre_suivant
			t_grand2:
					MOV     CX, DX      ; restaurer la vALeur de sauvegarde avant d'ajouter.
					MOV     DX, 0       ; DX était nul avant la sauvegarde
			t_grand1:
					MOV     AX, CX
					IDIV    dix  ; reverse last DX:AX = AX*10, make AX = DX:AX / 10
					MOV     CX, AX
					insert  8       ; retour.
					insert  ' '     ; remplacer le caractere par ' '.
					insert  8       ; retour une autre fois             
					JMP     chiffre_suivant 
			fin_saisie:
					; verifier si le flag est a 0 ou 1
					; si 0 on arrete 
					;sinon NEG CX, (négation de CX)
					CMP     moins, 0
					JE      non_moins
					NEG     CX
			non_moins:      
					;; recuperer les donnees
					POP     SI
					POP     AX
					POP     DX
					INSERT 0DH
					INSERT 0AH
					RET
SCAN_NUM        ENDP
;________________________________________________________________________________________________________________________
recommence proc 
                    INSERT 0DH
	                INSERT 0AH
                    MOV AH,9H
                    LEA DX,msg7
                    INT 21H

                    MOV ah,1h
                    INT 21h 
                    
                    CMP AL,'O'
                    JB  fin_rec
                    CMP AL,'O'
                    JE  rec
					CMP AL,'o'
					JE  rec
					JMP fin_rec
			    rec: 
					CALL main
				fin_rec:
					MOV ah,4ch
					INT 21h
recommence endp

;________________________________________________________________________________________________________________________
;pour changer le format du reste de ascii vers decimale
CHANGE PROC
	                MOV    AH,BH
	                MOV    AL,BL

	                MOV    BL,10
	                DIV    BL

                    ADC    AH,0

	                MOV    BL,AL
	                MOV    BH,AH

	                ADD    BH,30H         	
	                MOV    rest,BH

	                MOV    AH,0
	                MOV    AL,BL
	                MOV    BL,10
	                DIV    BL

                ADC    AH,0

	                MOV    BL,AL
	                MOV    BH,AH

	                ADD    BH,30h         	
	                ADD    BL,30h         	

	                RET
CHANGE ENDP
;________________________________________________________________________________________________________________________
;pour afficher le reste apres convertir en format decimALe
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
	; vALeur Absolu si c'est negative
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
	; flag to prevent prINTing zeros before number:
	                MOV    CX, 1

	                MOV    BX, 10000

	; AX zero?
	                CMP    AX, 0
	                JZ     AFFICHER_ZERO
	BEGIN_PRINT:    
	; verifier si le diviseur est egALe a 0:
	                CMP    BX,0
	                JZ     END_PRINT
	; pour eviter d'ecrire des 0 avant le nombre:
	                CMP    CX, 0
	                JE     CALC
	; si AX<BX ALors le resultat de division sera zero
	; donc il faut qu'on essaye a chaque fois
	                CMP    AX, BX
	                JB     SKIP
	CALC:           
	                MOV    CX, 0          	; set flag.
	                MOV    DX, 0          	; initiALiser le reste a 0
	                DIV    BX             	; AX = DX:AX / BX   (DX=le reste).
	; on commence a afficher le dernier chiffre
	; AH est toujourds ZERO, donc c'est ignorer
	                ADD    AL, 30h        	; convertir a ASCII code.
	                INSERT AL
	                MOV    AX, DX         	; stocker le reste de derniere division
	SKIP:           
	;BX=BX/10
	                PUSH   AX
	                MOV 	   DX, 0
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
		