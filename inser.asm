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