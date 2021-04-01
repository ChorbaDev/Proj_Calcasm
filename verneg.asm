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