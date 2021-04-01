%include inser.asm
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