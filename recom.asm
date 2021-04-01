					
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