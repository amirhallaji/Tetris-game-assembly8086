title (exe) Graphics System Calls 

.model small 
.stack64


.data 


    
    ;**********SQUARE*************
    start_col_sq dw 140
    start_row_sq dw 0
    finish_col_sq dw 160
    finish_row_sq dw 20
    
    ;********* RECTANGLE**********
    
    ; vertical rectangle
    start_col_rec_v dw 100
    start_row_rec_v dw 0 
    finish_row_rec_v dw 10
    finish_col_rec_v dw 140


    ; Score dispalyed.
    init_score dw '0'    
    init_score_hd dw '0'  
    
    seconds db ?
    buf db 6 dup(?)

    random_number db 0
    


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
    call shift_down_shape      
    call procedure_read_character
    call fall_delay
    cmp finish_row_sq, 200
    jnz main_loop 


EXIT:      
    MOV AX, 4C00H
    INT 21H
    

;********************************************************************************

clear_screen PROC    
    
    MOV AL, 06H       ;scroll up
    MOV BH, 00H
    MOV CX, 0000H
    MOV DX, 184FH
    INT 10H
    
    RET
   
ENDP clear_screen        

;********************************************************************************

set_graphic_mode proc ; change color for a single pixel, set graphics video mode.
       
    MOV AL, 13H
    MOV AH, 0
    INT 10H
    
    ret
    
endp set_graphic_mode

;********************************************************************************


draw_init_score proc
    
    MOV DL, '0'
    MOV AH, 2
    INT 21h
    
    ret
endp draw_init_score  

;***********************************************************************************
fall_delay proc
    
    MOV CX, 9FFFH

delay_loop:      
    LOOP delay_loop
    ret
endp fall_delay

;***********************************************************************************


choose_random_shape proc
    
    mov al, byte [random_number]
    add al, 31
    mov byte [random_number], al

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ; divide by N and return remainder
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    div bl ; divide by N
    mov al, ah ; save remainder in al
    xor ah, ah
    
    ret


    mov ax, dx
    xor dx, dx
    mov cx, 10
    div cx
     ; result of random number between 0 to 9.
    
    ret
    
endp choose_random_shape

;***********************************************************************************
procedure_read_character proc

    mov ah, 1
    int 16h
    jnz check_input

    ret
    endp procedure_read_character

;********************************************************************************


check_input proc
    
    mov ah, 00h
    int 16h

    push ax    
    mov ah, 6 ; direct console I/O
    mov dl, 0FFh ; input mode
    int 21h 
    pop ax
    
    cmp al,'d'
    je d_key_pressed
    
    cmp al, 'D'
    je d_key_pressed

    cmp al, 'L'
    je l_key_pressed

    cmp al, 'l'
    je l_key_pressed

    jne check_input_done

d_key_pressed:
    call shif_right_shape
    jmp check_input_done

l_key_pressed:
    call shift_left_shape
    jmp check_input_done


check_input_done:
    ret
endp check_input 

;***********************************************************************************

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

;********************************************************************************

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

;********************************************************************************

shift_down_shape proc
    
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
endp shift_down_shape
               
;********************************************************************************
shift_right_shape proc

    ret
    endp shif_right_shape

;********************************************************************************
shift_left_shape proc

    ret
    endp shift_left_shape

;********************************************************************************

ENDP MAIN
