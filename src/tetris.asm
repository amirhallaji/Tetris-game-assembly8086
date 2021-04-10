title (exe) Graphics System Calls 

.model small 
.stack64


.data 

    block_size dw 20
    delay_counter dw ?

    border_col_left dw 0
    border_col_right dw 0

    color db ?

    finish_row_screen dw ?
    finish_col_screen_r dw 200
    finish_col_screen_l dw 100
    
    ;**********SQUARE*************
    start_col_sq dw 150
    start_row_sq dw 0
    finish_col_sq dw ?
    finish_row_sq dw ?
    
    ;********* RECTANGLE**********
    
    ; vertical rectangle
    start_col_rec_v dw 100
    start_row_rec_v dw 0 
    finish_row_rec_v dw ?
    finish_col_rec_v dw ?

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

value_initialization:
    mov finish_row_screen, 0
    

    CALL clear_screen   
    CALL set_graphic_mode
    CALL draw_init_score
    call draw_border
    mov color, 14
    call draw_square 

    
main_loop:   
    ; call choose_random_shape   ;TODO 
    call shift_down_shape      
    call procedure_read_character
    call fall_delay

    mov ax, finish_row_screen
    add ax, block_size
    mov finish_row_screen, ax

    cmp finish_row_screen, 180
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

    mov delay_counter, 1
delay_loop1:
    MOV CX, 0FFFFH
    inc delay_counter

delay_loop2: 
    loop delay_loop2
    cmp delay_counter, 15
    jnz delay_loop1

    ret
endp fall_delay

;***********************************************************************************


choose_random_shape proc
    
    ; mov al, byte [random_number]
    ; add al, 31
    ; mov byte [random_number], al

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

;*********************************************************************************

draw_border proc

border_loop1:
    mov al, 1100b
    mov cx, 68
    mov dx, border_col_left
    mov ah, 0ch
    int 10h   
    inc border_col_left
    cmp dx, 200
    js border_loop1

border_loop2:
    mov al, 1100b
    mov cx, 212
    mov dx, border_col_right
    mov ah, 0ch
    int 10h   
    inc border_col_right
    cmp dx, 200
    js border_loop2
    
     

    ret
    endp draw_border

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

    cmp al, 'A'
    je l_key_pressed

    cmp al, 'a'
    je l_key_pressed

    jnz check_input_done

d_key_pressed:
    call shift_right_shape
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
    mov di, 1
draw_square proc 
                 
    MOV AH, 0ch                 
    MOV AL, color

    mov dx, start_row_sq
    add dx, block_size
    mov finish_row_sq, dx

    mov dx, start_col_sq
    add dx, block_size
    mov finish_col_sq, dx

    
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


done:    
    ret
endp draw_square

;********************************************************************************

shift_down_shape proc

    mov color, 0
    call draw_square


    mov dx, start_row_sq
    add dx, block_size
    mov start_row_sq, dx

    mov color, 14
    call draw_square
    call fall_delay

    ret
endp shift_down_shape
               
;********************************************************************************
shift_right_shape proc

    mov ax, finish_col_screen_r
    cmp finish_col_sq, ax
    js square_can_move_right

    jmp square_cannot_move_right
    
square_can_move_right:

    mov color, 0
    call draw_square

    mov dx, start_col_sq
    add dx, block_size
    mov start_col_sq, dx

    mov color, 14
    call draw_square
    call fall_delay

square_cannot_move_right:

    ret
    endp shift_right_shape

;********************************************************************************

shift_left_shape proc

    mov ax, finish_col_screen_l
    cmp ax, finish_col_sq
    js square_can_move_left

    jmp square_cannot_move_left

square_can_move_left:

    mov color, 0
    call draw_square

    mov dx, start_col_sq
    sub dx, block_size
    mov start_col_sq, dx

    mov color, 14
    call draw_square
    call fall_delay

square_cannot_move_left:

    ret
    endp shift_left_shape

;********************************************************************************

ENDP MAIN
