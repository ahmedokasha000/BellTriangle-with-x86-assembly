;;;;;;;;AHMED NASER OKASHA
;;;;;;;;ID=45
include 'emu8086.inc'
org 100h
.data


ROWS_B DB 00H 
ROWS_W DW 0000H
FIRST_ELEMENT DW 0000H
CUR_ROW  DB 1
CUR_COL  DB 0
CELLB_OFFSET DW 00H
CELL_OFFSET  DW  00H
CELLBLR_OFFSET  DW  00H 
INCREMENTS DW  0000H 
row_counter DB 01H
row_curser DB 00H
.code

; cancel blinking and enable all 16 colors:
mov ax, 1003h
mov bx, 0
int 10h


; set segment register:
mov     ax,@data
mov     ds, ax


;############   ALLOCATE MEMORY FOR ARRAY MAX 10*10 WORD TYPE
arr1 DW 200 DUP(?)   

;############   TAKE INPUTS FROM USER >>FIRST ELEMENT, TRIANGLE ROWS

;############   ROWS NUMBER  

;# TODO  take input numbers not strings 
GOTOXY 0,0 
PRINT 'Please Enter Rows Number: '
 
CALL SCAN_NUM
MOV [ROWS_B],CL
MOV [ROWS_W],CX 

mov CX,0000h

;############   FIRST ELEMENT 
GOTOXY 0,1
PRINT 'Please Enter First Element Value:'
CALL SCAN_NUM
MOV [FIRST_ELEMENT],CX
MOV arr1[0],CX 
MOV CX,0000h  

;# TODO you can make first element word


;############   SET ARRAY ELEMENTS VALUES  

;############   COUNTING LOOP ITERATION 
;
MOV DX,0000H 
MOV CX,0000H
 
MOV CX,[ROWS_W]
MOV AX,[ROWS_W]
MUL CX
MOV CX,AX       ;;ITERATION = ROWS*ROWS -1
DEC CX
MOV [INCREMENTS],CX
MOV AL,00H

;;;;;;;;;;;SETTING EACH CELL DATA LOOP;;;;;;;;;;;;;;;;;;;
  
 loop1:
     MOV DH,[CUR_ROW] ;HOLDS CUR ROW
     MOV DL,[CUR_COL] ;HOLDS CUR COL
     ;########## assume DL represent rows  ,DH represent cols
     cmp DH,DL
     JNC CELL_IN_TRIANGLE   ; IF ROWS>=COLS    go to CELL_IN_TRIANGLE
     JMP INCREASE_INDEX        ;; IF ROWS< COLS GO TO INCREASE_INDEX     
     
     
     CELL_IN_TRIANGLE:
        
        
        cmp DL,00H  ; IF COL==0 GO TO  first_element_in row
        jz FIRST_IN_ROW
        
        ; IF COL != 0       ;BASE +(ROW SIZE*ROW_OFFSE+ITEM OFFSET)*CELL SIZE
        MOV BX,0000H
        MOV DX,0000H 
        MOV AX,0000H
        ADD BL,[ROWS_B]
        MOV AL,BL            
        MUL [CUR_ROW]        ;FIRST ELEMENT INDEX OF CURRENT ROW IN ARRAY
        MOV BL,AL
        ADD BL,[CUR_COL]    ;; OFFSET =ROW SIZE*ROW_OFFSE+ITEM OFFSET 
        MOV AL,BL
        
        ADD BX,AX           ;;INDEX =(ROW SIZE*ROW_OFFSE+ITEM OFFSET)*2

        
        MOV [CELL_OFFSET],BX      ;;CURRENT CELL OFFSET
        DEC BX
        DEC BX             
        MOV [CELLB_OFFSET],BX       ;; INDEX OF ELEMENT ARR[i-1][j] 
        MOV DX,arr1+[BX]         ;;DATA=ARR[i-1]
        SUB BX,[ROWS_W]
        SUB BX,[ROWS_W]           ;;INDEX OF ELEMENT ARR[i-1][j-1]
        MOV [CELLBLR_OFFSET],BX
        
        

        ADD DX,arr1+[BX]      ;;DATA=ARR[i-1] +ARR[i-1][j-1]   
        MOV BX,0000H
        MOV BX,[CELL_OFFSET]
        MOV arr1+[BX],DX    
        MOV BX,0000H
        MOV DX,0000H
        JMP INCREASE_INDEX:
         
        ;IF COL=0
        FIRST_IN_ROW:
            MOV BX,0000H
            MOV DX,0000H 
            MOV AX,0000H
            ADD BL,[ROWS_B]     ;+ROW 
            MOV AL,BL     
            MUL [CUR_ROW]     ;OFFSET =ROW SIZE*ROW_OFFSE
            MOV BL,AL
            ADD BX,AX   
            MOV [CELL_OFFSET],BX ;SAVE OFFSET TO MEM 
            
            SUB BX,[ROWS_W]
            SUB BX,[ROWS_W]     ; INDEX OF ELEMENT ARR[i-1][0] 
            ADD BL,[CUR_ROW]
            ADD BL,[CUR_ROW]   ;; INDEX OF ELEMENT ARR[i-1][CUR_ROW] 
            DEC BX             ;;  INDEX OF ELEMENT ARR[i-1][CUR_ROW-1]
            DEC BX        
            MOV [CELLB_OFFSET],BX  ;;;LAST ELEMENT IN UPPER TRIANGLE ROW
            
            
            MOV DX,[arr1+BX]    
            MOV BX,[CELL_OFFSET]
            MOV [arr1+BX],DX    ; BASE +ROW SIZE*ROW_OFFSET  
            MOV BX,0000H
            MOV DX,0000H
            MOV AX,0000H
            
    INCREASE_INDEX:
    
    INC [CUR_COL]
    MOV DL,[CUR_ROW] ;HOLDS CUR ROW
    MOV DH,[CUR_COL] ;HOLDS CUR COL
    CMP [ROWS_B],DH   ;; IF ROWS -CUR_COL <0
    JC SET_COLLUMN 
    
    JMP end1
    
    SET_COLLUMN: ;;SET CUR_COL TO ZERO  & INCREASE CUR_ROW
       
       MOV DH,00H
       MOV [CUR_COL],DH
       INC DL 
       MOV [CUR_ROW],DL
       MOV DX,0000H 
       
    
    end1:
    dec CX  
    jnz loop1 
     

;;;;;;;;;;;;;;;;;;;;;;;;PRINTING LOOP;;;;;;;;;;;;;;;;;;
;;;;; new line in cmd
GOTOXY 0,2 
PRINT 'Array is:' 
GOTOXY 0,3
MOV [row_curser],3

MOV BX,0000H
MOV AX,0000H
MOV CX, [INCREMENTS] 
INC CX              ;;SETTING COUNTER ITERATION
loop2: 
    
    mov AX, [arr1]+[BX]     ;;loading array cell data
    CALL PRINT_NUM_UNS      ;; printing data
    PRINT ' '
    INC [row_counter]       ;;counter indicates end of row when it == [ROWS]
    MOV DH,[row_counter]
    cmp [ROWS_B],DH
    MOV DX,0000H        
    jnc dont_increase_line  ;; IF [ROWS]-[row_counter] >0 DONT INCREASE ROW_CURSER
    
    new_line:
        MOV [row_counter],01H
        inc [row_curser] 
        GOTOXY 0,[row_curser] 
        
        
    dont_increase_line:    
    ADD BX,02H              ;;ADDING ARRAY CELL OFFSET
    dec cx                  ;;DECREASE COUNTER
    jnz loop2 
DEFINE_PRINT_NUM_UNS
DEFINE_SCAN_NUM 
; wait for any key press:
mov ah, 0
int 16h

ret

