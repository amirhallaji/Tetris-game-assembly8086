title (exe) Graphics System Calls 

.model small 
.stack64


.data                 

    
    ;*****************************
    ;********* RECTANGLE**********
    
    ; vertical rectangle
    
    start_col_rec_v dw 50
    start_row_rec_v dw 0 
    finish_row_rec_v dw 20
    finish_col_rec_v dw 130
    
    ; horizontal rectangle
    
    start_col_rec_h dw 100
    start_row_rec_h dw 0
    finish_row_rec_h dw 20
    finish_col_rec_h dw 180
    
    ;*****************************
    ;**********SQUARE*************
    
    start_row_sq dw 0
    start_col_sq dw 50
    finish_row_sq dw 40
    finish_col_sq dw 90
    
    ;*****************************
    ;**********LBlOCK*************
    
    start_row_l dw 50
                     
    
    
    init_score dw '0'    
    init_score_hd dw '0'
    

.code

MAIN PROC FAR
    MOV AX, @DATA
    MOV DS, AX
    
    CALL CLEAR_SCREEN   
    CALL set_graphic_mode
    CALL start_game  
    CALL draw_init_score
    call hd
                        
    



EXIT:      
    MOV AX, 4C00H
    INT 21H
    

;*****************

CLEAR_SCREEN PROC    
    
    MOV AL, 06H       ;scroll up
    MOV BH, 00H
    MOV CX, 0000H
    MOV DX, 184FH
    INT 10H
    
    RET
   
ENDP CLEAR_SCREEN        

;******************

set_graphic_mode proc ; change color for a single pixel, set graphics video mode.
       
    MOV AL, 13H
    MOV AH, 0
    INT 10H
    MOV AL, 1110B
    MOV CX, 0
    MOV DX, 20
    MOV AH, 0CH
    INT 10H           ; set pixel
    
    ret
    
endp set_graphic_mode

;******************

start_game proc
    
    call draw_rectangle_vertical  
    call draw_square
    ;call draw_rectangle_horizontal
    
    ret
endp start_game

;******************    

draw_rectangle_vertical proc
    
    MOV AL, 1        ;set color blue
    MOV AH, 0CH
   
    MOV CX, start_col_rec_v 
rec_v_loop1:                

    MOV DX, start_row_rec_v
rec_v_loop2:
    INT 10H
    INC DX
    CMP DX, finish_row_rec_v
    JNZ rec_v_loop2
    
    INC CX
    CMP CX, finish_col_rec_v
    JNZ rec_v_loop1
         
    ret
endp draw_rectangle_vertical

;******************

draw_rectangle_horizontal proc
    
    MOV AL, 1001B ; set color light blue
    MOV AH, 0CH                         
    
    MOV DX, start_row_rec_h
rec_h_loop1:
    MOV CX, start_col_rec_h
                 
rec_h_loop2:
    INT 10H
    INC CX
    CMP CX, finish_col_rec_h
    JNZ rec_h_loop2
    
    INC DX
    CMP DX, finish_row_rec_h
    JNZ rec_h_loop1
    
    ret
endp draw_rectangle_horizontal
                    
;******************   TODO        
                   
draw_square proc 
    
    MOV AL, 1110b
    MOV AH, 0ch
    
    MOV DX, start_row_sq
    
sq_loop1:
    MOV CX, start_col_sq
    
sq_loop2:
    INT 10h
    INC CX
    CMP CX, finish_col_sq
    JNZ sq_loop2
    
    INC DX
    CMP DX, finish_row_sq
    JNZ sq_loop1         
    
    ret
endp draw_square

;******************   
                   
draw_l_block proc 
    
    ret
endp draw_l_block

;******************

panjebox_block proc
    
    ret
endp panjebox_block

;******************

z_block proc
    
    
    ret
endp z_block

;******************  

shape_shift proc
    
    ret
endp shape_shift

;******************
                       

draw_init_score proc
    
    MOV DL, init_score
    MOV AH, 2
    INT 21h
    
    ret
endp draw_init_score  

;********************

hd proc
    MOV DL, init_score_hd
    MOV AH, 2
    INT 21H
    
    MOV AL, init_score
    OUT 199, AL 
    
    ret
endp hd
        
;*********************
ENDP MAIN

END MAIN