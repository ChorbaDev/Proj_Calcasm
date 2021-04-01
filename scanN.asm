%include inser.asm
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