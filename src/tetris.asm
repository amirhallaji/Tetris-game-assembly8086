title (exe) Graphics System Calls 

.model small 
.stack64


.data                 

    
    ;*****************************
    ;********* RECTANGLE**********
    
    ; vertical rectangle
    
    start_col_rec_v dw 100
    start_row_rec_v dw 0 
    finish_row_rec_v dw 10
    finish_col_rec_v dw 140
    
    ; horizontal rectangle
    
    start_col_rec_h dw 100
    start_row_rec_h dw 0
    finish_row_rec_h dw 10
    finish_col_rec_h dw 140
    
    ;*****************************
    ;**********SQUARE*************
    
    start_col_sq dw 140
    start_row_sq dw 0
    finish_col_sq dw 160
    finish_row_sq dw 20
    
    ;*****************************
    ;**********LBlOCK*************

    ;*****************************
    ;**********PanjeBox**********
    start_col_pb dw 100
    start_row_pb dw 0
    finish_col_pb dw 
    ;*****************************
    
    start_row_l dw 50
    
    init_score dw '0'    
    init_score_hd dw '0'  
    
    seconds db ?
    buf db 6 dup(?)
    

.code

MAIN PROC FAR
    MOV AX, @DATA
    MOV DS, AX
    
    CALL clear_screen   
    CALL set_graphic_mode
    CALL draw_init_score
    call draw_square  
    
main_loop:   
    call choose_random_shape 
    call shift_down_sq      
    ; call check_input
    call fall_delay
    cmp finish_row_sq, 200
    jnz main_loop 
    
loop2:
    
    call draw_rectangle_vertical
    call shift_down_rectangle
    ; call check_input
    call fall_delay
    cmp finish_row_rec_v, 200
    jnz loop2        
    

EXIT:      
    MOV AX, 4C00H
    INT 21H
    

;*****************

clear_screen PROC    
    
    MOV AL, 06H       ;scroll up
    MOV BH, 00H
    MOV CX, 0000H
    MOV DX, 184FH
    INT 10H
    
    RET
   
ENDP clear_screen        

;******************

set_graphic_mode proc ; change color for a single pixel, set graphics video mode.
       
    MOV AL, 13H
    MOV AH, 0
    INT 10H
    
    ret
    
endp set_graphic_mode

;******************   
draw_rectangle_vertical proc
    
    MOV AL, 1001b  ;set color blue
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
                   
draw_square proc 
                 
    MOV AH, 0ch                 
    MOV AL, 1110b
    
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

shift_down_sq proc
    
    MOV AH, 0CH
    MOV AL, 0
    MOV DX, start_row_sq
    MOV CX, start_col_sq

shift_down_sq_loop1:
    INT 10h  
    INC CX
    CMP CX, finish_col_sq
    JNZ shift_down_sq_loop1
    
    MOV AL, 1110b
    MOV CX, start_col_sq
    MOV DX, finish_row_sq
    
shift_down_sq_loop2:
    INT 10H
    INC CX
    CMP CX, finish_col_sq
    JNZ shift_down_sq_loop2
    
    INC start_row_sq
    INC finish_row_sq
    
    ret
endp shift_down_sq

;******************

shift_down_rectangle proc
    
    MOV AH, 0CH
    MOV AL, 0
    MOV DX, start_row_rec_v
    MOV CX, start_col_rec_v

shift_down_rec_loop1:
    INT 10h  
    INC CX
    CMP CX, finish_col_rec_v
    JNZ shift_down_rec_loop1
    
    MOV AL, 1001b
    MOV CX, start_col_rec_v
    MOV DX, finish_row_rec_v
    
shift_down_rec_loop2:
    INT 10H
    INC CX
    CMP CX, finish_col_rec_v
    JNZ shift_down_rec_loop2
    
    INC start_row_rec_v
    INC finish_row_rec_v
    
        
    
    ret
endp shift_down_rectangle 

;******************
                       

draw_init_score proc
    
    MOV DL, '0'
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

fall_delay proc
    
    MOV CX, 9FFFH

delay_loop:      
    LOOP delay_loop
    ret
endp fall_delay

;*********************

choose_random_shape proc
    
    mov ax, dx
    xor dx, dx
    mov cx, 10
    div cx
     ; result of random number between 0 to 9.
    
    ret
    
endp choose_random_shape

;*********************

check_input proc
    
    mov ah, 00h
    int 16h
    
    cmp al,'d'
    call shift_down_rectangle 

    
    ret
endp check_input 

;*********************
ENDP MAIN

END MAIN