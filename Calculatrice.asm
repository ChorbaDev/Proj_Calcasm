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
; les valeurs autorisées sont de 0 a 65535 (FFFF)
.286
SSEG SEGMENT STACK
        DB      32 DUP ("STACK---")
SSEG ENDS
;________________________________________________________________________________________________________________________
DSEG SEGMENT
		msg0  DB  0DH,0AH,"_______________________________$"
        msg1  DB  0DH,0AH,"Entrer le premier nombre: $",0DH,0AH 
        msg2  DB  0DH,0AH,"choisisez un operateur:$",0DH,0AH 
		op_b  DB  0DH,0AH,"Operation de Bases : $",0DH,0AH 
        op_bb DB  0DH,0AH,"(+) (-) (*) (/)$",0DH,0AH 
        op_s  DB  0DH,0AH,"Operation Supplementaire :$",0DH,0AH 
        op_pg DB  0DH,0AH,"PGCD : (.)$",0DH,0AH 
        op_pp DB  0DH,0AH,"PPCM : (,)$",0DH,0AH 
        msg3  DB  0DH,0AH,"Entrer le deuxieme nombre: $",0DH,0AH 
        msg4  DB  "Resultat : $" 
		msg8  DB  "Quotient : $" 
        msg5  DB  "Reste : $" 
        msg6  DB  0DH,0AH,"Division par 0 est impossible$",0DH,0AH 
		msg7  DB  0DH,0AH,"Taper o/O pour recommencer: $",0DH,0AH 
		DIX   DW  10   
        reste DW  ?
        res   DW  ?
        moins DB  ?    
        opr   DB  ?	   
        num1  DW  ?
        num2  DW  ?
        sn1   DB  0
        sn2   DB  0
        aff1  DB    "         _____________________________",0DH,0AH
			  DB    "        |  _________________________| |$"
		aff2  DB    0DH,0AH,"        | | $"
		aff3  DB    0DH,0AH,"        | |_________________________| |",0DH,0AH
			  DB    "	|  ___ ___ ___   ___   _____  |",0DH,0AH
		 	  DB   	"	| | 7 | 8 | 9 | | + | |PPCM | |",0DH,0AH
		      DB 	"	| |___|___|___| |___| |_____| |",0DH,0AH
		 	  DB	"	| | 4 | 5 | 6 | | - | |PGCD | |",0DH,0AH
		 	  DB	"	| |___|___|___| |___| |_____| |",0DH,0AH
			  DB   	"	| | 1 | 2 | 3 | | x |         |",0DH,0AH
		      DB   	"	| |___|___|___| |___|         |",0DH,0AH
		      DB   	"	| | . | 0 | = | | / |         |",0DH,0AH
		      DB   	"	| |___|___|___| |___|         |",0DH,0AH
		      DB   	"	|_____________________________|$"
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
					
					LEA    DX, MSG0
	                MOV    AH, 09H
	                INT    21H
					
	                LEA    DX, MSG1						;affichage de msg1: Entrer le premier nombre
	                MOV    AH, 09H
	                INT    21H

	                CALL   SCAN_NUM						; avoir un nombre signee et le resultat est enregistre dans CX
	                CMP    MOINS,1
	                JE     S_N1
	                   JMP    SUITE
	S_N1:           
	                MOV    SN1,1
	SUITE:          
				
	                MOV    NUM1, CX						; stocker le premier nombre
;________________________________________________________________________________________________________________________
	VERIF:            
	;afficher le msg2: choisisez un operateur:    +  -  *  /  .  , :
                    LEA    DX, op_b
	                MOV    AH, 09H
	                INT    21H
	                
                    LEA    DX, op_bb
	                MOV    AH, 09H
	                INT    21H
	                
                    LEA    DX, op_s
	                MOV    AH, 09H
	                INT    21H
	                
                    LEA    DX, op_pp
	                MOV    AH, 09H
	                INT    21H
	                
                  
                  	LEA    DX, op_pg
	                MOV    AH, 09H
	                INT    21H
	                
                    LEA    DX, MSG2
	                MOV    AH, 09H
	                INT    21H
 
	                MOV    AH, 1H							;lire un caractere du clavier
	                INT    21H
	                MOV    OPR, AL
						                                    ;verif si l'operateur entre *.../
	                CMP    OPR, '*'
	                JB     inter_verif
	            	   CMP    OPR, '/'
	               	   JA     inter_verif
						  JMP    next_nb
			inter_verif:
					JMP	   VERIF
	next_nb:            
	                LEA    DX, MSG3
	                MOV    AH, 09H
	                INT    21H
	
	                CALL   SCAN_NUM							; avoir un nombre signee et le resultat sera enregistre dans CX
	                CMP    MOINS,1
	                JE     S_N2
	              	   JMP    SUIT
	S_N2:           
	                MOV    SN2,1
;_____________________________________________________________________________________________________________
	SUIT:                   
	                MOV    NUM2, CX							; stocker le deuxieme nombre
 ;_______________________________________________
	                CMP    OPR, '+'
	                JE     ADDITION

	                CMP    OPR, '-'
	                JE     SOUSTR

	                CMP    OPR, '*'
	                JE     MULTI

	                CMP    OPR, '/'
	                JE     DO_DIV
 
	                CMP    OPR, '.'
	                JE     inter_DO_PGCD

					CMP    OPR, ','
	                JE     inter_DO_PPCM

				inter_DO_PGCD:		
					JMP     DO_PGCD
				inter_DO_PPCM:
					JMP     DO_PPCM	
;________________________________________________________________________________________________________________________
ADDITION:            
	                MOV    AX, NUM1
	                ADD    AX, NUM2
                    PUSH   AX
	                CALL   affichage       
					CALL   recommence
;________________________________________________________________________________________________________________________
SOUSTR:         
	                MOV    AX, NUM1
	                SUB    AX, NUM2
	                CALL   affichage       
					CALL   recommence
;________________________________________________________________________________________________________________________
MULTI:          
	                MOV    AX, NUM1
	                IMUL   NUM2             			; (dx:AX) = AX * num2.
					CALL   affichage       				; AFFICHER LE RESULTAT
					CALL   recommence					; dx sera ignorer (caLc fonctionne uniquement avec des nombres pas tres grand).           		 
;________________________________________________________________________________________________________________________
DO_DIV:       
	                CMP    NUM2,0          				; verifier que le denumerateur est different de 0
	                JE     IMPOSSIBLE
	               	    JMP    VALEUR_ABOSLU1
	        IMPOSSIBLE:     
	                MOV    AH,9H
	                LEA    DX,MSG6
	                INT    21H
	                CALL   recommence
			VALEUR_ABOSLU1:
					CMP     SN1,1
	                JNE     VALEUR_ABOSLU2
						NEG 	NUM1
			VALEUR_ABOSLU2:
					CMP     SN2,1
	                JNE     DIVIS
						NEG 	NUM2
;________________________________________________________________________________________________________________________
	DIVIS:           		
					MOV    DX,0
					MOV    AX,NUM1
	                DIV   NUM2            				; AX = (DX:AX) / num2.
	                CMP    AX,0        					; comparer le resultat de division avec 0, si c le cas on decale par un caractere et on le retire pour eviter d'afficher -0
	                JNE    NEXTT
	                CMP    SN2,1
					JNE    NEXTT 
	        SUPP_MOINS:             
	                INSERT 8              				; retour.
	                INSERT ' '            				; remplacer le moins par ' '.
	                INSERT 8              				; retour une autre fois		
	        NEXTT:          					
	                CMP    DX, 0
	                JNZ    AFF_RESTE
	                   CALL   affichage        			; AFFICHER RESULTAT
	               	   CALL   recommence
	        AFF_RESTE:    
				VERIF1:  
					CMP	   SN1,1
					JE	   VERIF2
						CMP	   SN2,0
						JE	   DEJA_REGLER
							NEG    AX
							JMP    DEJA_REGLER
				VERIF2:
					CMP	   SN2,1
					JE	   DEJA_REGLER
				TYPE1:
					INC    AX
					NEG    AX
					SUB	   NUM2,DX
					MOV    DX,NUM2
			DEJA_REGLER:
	                CALL   AFFICHAGE_RESULTAT
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
			CAS3:									;NUM1 et NUM2 diff de 0
					CMP    AX,NUM2
					JGE    SMBR1
					    JL     SMBR2
			SMBR1:									;Soustraction sur le membre 1 soit num1
	                SUB    AX, NUM2
	                JMP    CAS0
	        SMBR2:
					SUB    NUM2, AX
	                JMP    CAS0
	        
			CAS1:									;NUM1 est egALe a 0 resultat cest NUM2
					MOV    AX, NUM2
					CALL   affichage
					CALL   recommence
					
			CAS2:									;NUM2 est egALe a 0 resultat cest NUM1
					MOV    AX, NUM1
					CALL   affichage
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
					CALL   affichage
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
	
SCAN_NUM        PROC    						;le resultat est enregistre dans CX
        										;Sauvgarder les registres 
					PUSH    DX
					PUSH    AX
					PUSH    SI
					MOV     CX,0
					INSERT  0DH
					INSERT  0AH
												
					MOV     moins, 0			; remettre le flag

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
					CMP     AL, 8               ; verifier si le touche de retour est taper
					JNE     verif_retour          

					MOV     DX, 0               ; si c'est le cas, on retire le chiffre precedent 
					MOV     AX, CX              ; division:
					iDIV    dix                 ; AX = DX:AX / 10 (DX-rem).
					MOV     CX, AX
					insert  ' '                 ; position claire
					insert  8                   ; retour une autre fois
					JMP     chiffre_suivant
			verif_retour:
												; verifier s'il est compose que avec des chiffres
					CMP     AL, '0'
					JAE     ok_AE_0
					JMP     suppr_non_chiff
			ok_AE_0:        
					CMP     AL, '9'
					JBE     verifier 			; si le chiffre a passer tout les tests avec succes donc c'est verifier
			suppr_non_chiff:       
					insert  8       			; retour.
					insert  ' '     			; remplacer le caractere par ' '.
					insert  8       			; retour une autre fois        
					JMP     chiffre_suivant        
			verifier:
												; multiplier CX par 10 
					PUSH    AX
					MOV     AX, CX
					IMUL    dix                 ; DX:AX = AX*10
					MOV     CX, AX
					POP     AX
														
					CMP     DX, 0				; verifier si le nombre est tres grand
					JNE     t_grand1			; (il faut que le resultat soit de 16 bits)

					
					SUB     AL, 30h				; convertir en decimaLe

												; ajouter AL a CX:
					MOV     AH, 0
					MOV     DX, CX     			; sauvegarde, au cas où le résultat serait trop grand.
					ADD     CX, AX
					JC      t_grand2   			; jump si le nombre est grand (jump if carry).
					    JMP     chiffre_suivant

			set_minus:
					CMP		 moins,1
					JE 		suppr_non_chiff
						CMP 	CX,0
						JNE 	suppr_non_chiff
							MOV     moins, 1
							JMP     chiffre_suivant
			t_grand2:
					MOV     CX, DX      		; restaurer la vALeur de sauvegarde avant d'ajouter.
					MOV     DX, 0      			; DX était nul avant la sauvegarde
			t_grand1:
					MOV     AX, CX
					IDIV    dix  				; reverse last DX:AX = AX*10, make AX = DX:AX / 10
					MOV     CX, AX
					insert  8      				; retour.
					insert  ' '    				; remplacer le caractere par ' '.
					insert  8      				; retour une autre fois             
					JMP     chiffre_suivant 
			fin_saisie:							
					CMP     moins, 0			; verifier si le flag est a 0 ou 1	
					JE      non_moins			; si 0 on arrete 
					NEG     CX					;sinon NEG CX, (négation de CX)
			non_moins:      
					POP     SI
					POP     AX
					POP     DX
					INSERT  0DH
					INSERT  0AH
					RET
SCAN_NUM        ENDP
;________________________________________________________________________________________________________________________
recommence proc             
                    MOV     AH,9H
                    LEA 	DX,msg7
                    INT 	21H

                    MOV 	ah,1h
                    INT		21h 
                    
                    CMP 	AL,'O'
                    JB  	fin_rec
                    	CMP 	AL,'O'
                    	JE  	rec
							CMP 	AL,'o'
							JE  	rec
								JMP	 	fin_rec
			    rec: 
					CALL main
				fin_rec:
					MOV ah,4ch
					INT 21h
recommence endp
;________________________________________________________________________________________________________________________
    AFFICHAGE_RESULTAT PROC
                    PUSH   CX
	                PUSH   BX
	                PUSH   DX
	                PUSH   AX
					mov    reste,DX	
                    
                    LEA    DX, aff1
	                MOV    AH, 09H
	                INT    21H
                    
                    LEA    DX, aff2
	                MOV    AH, 09H
	                INT    21H

					LEA    DX, msg8
	                MOV    AH, 09H
	                INT    21H

                    pop    AX 
                    CALL   aff_res
					CALL   AFFICHAGE_RESTE

                    POP    AX
	                POP    DX
	                POP    BX
	                POP    CX
					CALL   recommence
	                RET
    AFFICHAGE_RESULTAT ENDP
;________________________________________________________________________________________________________________________
    AFFICHAGE_RESTE PROC
                    PUSH   AX
	                PUSH   BX
	                PUSH   CX
	                PUSH   DX
						
					LEA    DX, aff2
	                MOV    AH, 09H
	                INT    21H

					LEA    DX, msg5
	                MOV    AH, 09H
	                INT    21H

					MOV    AX,reste
					CALL   aff_res
					
                    LEA    DX, aff3
	                MOV    AH, 09H
	                INT    21H

                    POP    DX
	                POP    CX
	                POP    BX
	                POP    AX
	                RET
    AFFICHAGE_RESTE ENDP
;________________________________________________________________________________________________________________________
    AFFICHAGE PROC
                    PUSH   AX
	                PUSH   BX
	                PUSH   CX
	                PUSH   DX
                    mov    res,ax

                    LEA    DX, aff1
	                MOV    AH, 09H
	                INT    21H

                    LEA    DX, aff2
	                MOV    AH, 09H
	                INT    21H

					LEA    DX, msg4
	                MOV    AH, 09H
	                INT    21H

                    mov    ax,res  
                    CALL   aff_res

                    LEA    DX, aff3
	                MOV    AH, 09H
	                INT    21H

                    POP    DX
	                POP    CX
	                POP    BX
	                POP    AX
	                RET
    AFFICHAGE ENDP
;________________________________________________________________________________________________________________________
AFF_RES PROC								; cette procedure affiche le nombre dans AX et utiliser avec AFF_RES_NS pour afficher les nombres non signee
	                PUSH   DX
	                PUSH   AX
	                CMP    AX, 0
	                JNZ   NOT_ZERO
	                INSERT '0'
	                JMP    PRINTED
			NOT_ZERO:       
	                CMP    AX, 0		  	; vaLeur Absolu si c'est negative
	                JNS    POSITIVE
	                NEG    AX
	                INSERT '-'
			POSITIVE:       
	                CALL   AFF_RES_NS
			PRINTED:        
	                POP    AX   			
	                POP    DX   
					RET
AFF_RES ENDP

;________________________________________________________________________________________________________________________
AFF_RES_NS PROC								; cette procedure affiche les nombres non signee
	                PUSH   AX
	                PUSH   BX
	                PUSH   CX
	                PUSH   DX
	
	                MOV    CX, 1			; flag to prevent printing zeros before number:

	                MOV    BX, 10000

	                CMP    AX, 0			; AX zero?
	                JZ     AFFICHER_ZERO
	BEGIN_PRINT:    
											
	                CMP    BX,0				; verifier si le diviseur est egaLe a 0
	                JZ     END_PRINT
	
	                CMP    CX, 0			; pour eviter d'ecrire des 0 avant le nombre:
	                JE     CALC
	
	
	                CMP    AX, BX			; si AX<BX ALors le resultat de division sera zero
	                JB     SKIP				; donc il faut qu'on essaye a chaque fois

	CALC:           
	                MOV    CX, 0          	; set flag.
	                MOV    DX, 0          	; initiALiser le reste a 0
	                DIV    BX             	; AX = DX:AX / BX   (DX=le reste).

											; on commence a afficher le dernier chiffre
											; AH est toujourds ZERO, donc c'est ignorer

	                ADD    AL, 30h        	; convertir a ASCII code.
	                INSERT AL
	                MOV    AX, DX         	; stocker le reste de derniere division
	SKIP:           							;BX=BX/10
	                PUSH   AX
	                MOV    DX, 0
	                MOV    AX, BX
	                iDIV   DIX         		; AX = DX:AX / 10   (DX=le reste).
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