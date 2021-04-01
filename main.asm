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
TITLE DISPLAY - Calculatrice
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
CSEG SEGMENT 'CODE'
ASSUME CS:CSEG, SS:SSEG, DS:DSEG
;_________________________________
%include inser.asm
%include affich.asm
%include scanN.asm
%include recom.asm
%include verneg.asm
;_________________________________
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
fin:
RET
MAIN ENDP
CSEG ENDS
        END MAIN