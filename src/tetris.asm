title (exe) Graphics System calls 

.model small 
.stack64


.data 

    block_size dw 15
    delay_counter dw ?

    border_col_left dw 0
    border_col_right dw 0

    color db 14, 1

    current_row_screen dw ?
    finish_col_screen_r dw 235
    finish_col_screen_l dw 100
    
    ;**********SQUARE*************
    start_col_sq dw 150
    start_row_sq dw 0
    finish_col_sq dw ?
    finish_row_sq dw ?
    
    ;********* RECTANGLE**********
    
    ; horizontal rectangle
    start_col_rec_h dw 150
    start_row_rec_h dw 0
    finish_col_rec_h dw ?
    finish_row_rec_h dw ?

    ; vertical rectangle
    start_col_rec_v dw 100
    start_row_rec_v dw 0 
    finish_row_rec_v dw ?
    finish_col_rec_v dw ?

    ; T-shape up-part
    start_col_t_up dw 150
    start_row_t_up dw 0
    finish_col_t_up dw ?
    finish_row_t_up dw ?
    ; T-shape down-part
    start_col_t_down dw 135
    start_row_t_down dw 15
    finish_col_t_down dw ?
    finish_row_t_down dw ?

    ; L-shape right-part
    start_col_l_right dw 150
    start_row_l_right dw 30
    finish_col_l_right dw ?
    finish_row_l_right dw ?

    ; L-shape left-part
    start_col_l_left dw 135
    start_row_l_left dw 0
    finish_col_l_left dw ?
    finish_row_l_left dw ?


    ;; ll-shape right-part
    start_col_ll_right dw 150
    start_row_ll_right dw 15
    finish_col_ll_right dw ?
    finish_row_ll_right dw ?

    ; ll-shape left-part
    start_col_ll_left dw 135
    start_row_ll_left dw 0
    finish_col_ll_left dw ?
    finish_row_ll_left dw ?



    ; Score dispalyed.
    init_score dw '0'    
    init_score_hd dw '0'  
    
    seconds db ?
    buf db 6 dup(?)

    random_number db 0

    shape_number dw 1
    time dw 1

	board dw 180 dup(0000h)  ; 180 blocks in a 135 * 300 board.
    

.code

MAIN PROC FAR
    mov ax, @DATA
    mov DS, ax

value_initialization:

    mov current_row_screen, 0
    

    call clear_screen   
    call set_graphic_mode
    call draw_init_score
    call draw_border
    
main_loop:   
    ; call choose_random_shape   ;TODO 
    call shift_down_shape      
    call procedure_read_character
    call fall_delay
    call shape_can_move_down

    jmp main_loop


EXIT:      
    mov ax, 4C00H
    INT 21H
    

;********************************************************************************

clear_screen PROC    
    
    mov al, 06H       ;scroll up
    mov bh, 00H
    mov cx, 0000H
    mov dx, 184FH
    INT 10H
    
    RET
   
ENDP clear_screen        

;********************************************************************************

set_graphic_mode proc ; change color for a single pixel, set graphics video mode.
       
    mov al, 13H
    mov AH, 0
    INT 10H
    
    ret
    
endp set_graphic_mode

;********************************************************************************

draw_init_score proc
    
    mov DL, '0'
    mov AH, 2
    INT 21h
    
    ret
endp draw_init_score  

;***********************************************************************************
fall_delay proc

    mov delay_counter, 1
delay_loop1:
    mov cx, 0FFFFH
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
    mov cx, 88
    mov dx, border_col_left
    mov ah, 0ch
    int 10h   
    inc border_col_left
    cmp dx, 200
    js border_loop1

border_loop2:
    mov al, 1100b
    mov cx, 242
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

    cmp al, 's'
    je s_key_pressed

    cmp al, 'S'
    je s_key_pressed

    cmp al, 'W'
    je w_key_pressed

    cmp al, 'w'
    je w_key_pressed

    jnz check_input_done

d_key_pressed:
    call shift_right_shape
    jmp check_input_done

l_key_pressed:
    call shift_left_shape
    jmp check_input_done

s_key_pressed:
    call quick_shift_down
    jmp check_input_done

w_key_pressed: ;Todo
    jmp check_input_done


check_input_done:
    ret
endp check_input 

;***********************************************************************************
shape_initialization proc

square_initialize:
    mov start_col_sq, 150
    mov start_row_sq, 0

horizontal_rectangle_initialize:
    mov start_col_rec_h, 150
    mov start_row_rec_h, 0

t_shape_initialize:
    mov start_col_t_up, 150
    mov start_row_t_up, 0

    mov start_col_t_down, 135
    mov start_row_t_down, 15


l_shape_initialize:
    mov start_col_l_right, 150
    mov start_row_l_right, 30
    mov start_col_l_left, 135
    mov start_row_l_left, 0

ll_shape_initialize:
    mov start_col_ll_right, 150
    mov start_row_ll_right, 15
    mov start_col_ll_left, 135
    mov start_row_ll_left, 0


shape_initialization_done:
    ret
    endp shape_initialization
;********************************************************************************

next_shape proc

    mov current_row_screen, 0 ; for the next shape

    inc shape_number
    call shape_initialization
    cmp shape_number, 6
    jz shape_reset

    jmp next_shape_done

shape_reset:
    mov shape_number, 1

next_shape_done:
    ret
    endp next_shape
;********************************************************************************

draw_shape proc 

    cmp shape_number, 1
    jz square_shape

    cmp shape_number, 2
    jz horizontal_rectangle_shape

    cmp shape_number, 3
    jz t_shape

    cmp shape_number, 4
    jz l_shape

    cmp shape_number, 5
    jz ll_shape

    jmp draw_shape_done

;-----------------------------------                 

square_shape:
    mov AH, 0ch                 
    mov al, color

    mov dx, start_row_sq
    add dx, block_size
    mov finish_row_sq, dx

    mov dx, start_col_sq
    add dx, block_size
    mov finish_col_sq, dx

    
    mov dx, start_row_sq
    
sq_loop1:
    mov cx, start_col_sq
    
sq_loop2:
    INT 10h
    INC cx
    CMP cx, finish_col_sq
    JNZ sq_loop2
    
    INC dx
    CMP dx, finish_row_sq
    JNZ sq_loop1  

    jmp draw_shape_done

;-----------------------------------                 

horizontal_rectangle_shape:

    mov AH, 0ch                 
    mov al, color

    mov dx, start_row_rec_h
    add dx, block_size
    mov finish_row_rec_h, dx

    mov dx, start_col_rec_h
    add dx, block_size
    add dx, block_size
    add dx, block_size
    add dx, block_size
    mov finish_col_rec_h, dx

    
    mov dx, start_row_rec_h
    
rec_h_loop1:
    mov cx, start_col_rec_h
    
rec_h_loop2:
    INT 10h
    INC cx
    CMP cx, finish_col_rec_h
    JNZ rec_h_loop2
    
    INC dx
    CMP dx, finish_row_rec_h
    JNZ rec_h_loop1

    jmp draw_shape_done

;-----------------------------------                 

t_shape:

    mov AH, 0ch                 
    mov al, color

    mov dx, start_row_t_up
    add dx, block_size
    mov finish_row_t_up, dx

    mov dx, start_col_t_up
    add dx, block_size
    mov finish_col_t_up, dx

    
    mov dx, start_row_t_up
    
t_loop1:
    mov cx, start_col_t_up
    
t_loop2:
    INT 10h
    INC cx
    CMP cx, finish_col_t_up
    JNZ t_loop2
    
    INC dx
    CMP dx, finish_row_t_up
    JNZ t_loop1
;*******
; down part 
    mov AH, 0ch                 
    mov al, color

    mov dx, start_row_t_down
    add dx, block_size
    mov finish_row_t_down, dx

    mov dx, start_col_t_down
    add dx, block_size
    add dx, block_size
    add dx, block_size
    mov finish_col_t_down, dx

    
    mov dx, start_row_t_down
    
t_loop3:
    mov cx, start_col_t_down
    
t_loop4:
    INT 10h
    INC cx
    CMP cx, finish_col_t_down
    JNZ t_loop4
    
    INC dx
    CMP dx, finish_row_t_down
    JNZ t_loop3

    jmp draw_shape_done

;-----------------------------------  
l_shape:
    mov AH, 0ch                 
    mov al, color

    mov dx, start_row_l_right
    add dx, block_size
    mov finish_row_l_right, dx

    mov dx, start_col_l_right
    add dx, block_size
    mov finish_col_l_right, dx

    
    mov dx, start_row_l_right
    
l_loop1:
    mov cx, start_col_l_right
    
l_loop2:
    INT 10h
    INC cx
    CMP cx, finish_col_l_right
    JNZ l_loop2
    
    INC dx
    CMP dx, finish_row_l_right
    JNZ l_loop1  

; left-part
    mov AH, 0ch                 
    mov al, color

    mov dx, start_row_l_left
    add dx, block_size
    add dx, block_size
    add dx, block_size
    mov finish_row_l_left, dx

    mov dx, start_col_l_left
    add dx, block_size
    mov finish_col_l_left, dx

    
    mov dx, start_row_l_left
    
l_loop3:
    mov cx, start_col_l_left
    
l_loop4:
    INT 10h
    INC cx
    CMP cx, finish_col_l_left
    JNZ l_loop4
    
    INC dx
    CMP dx, finish_row_l_left
    JNZ l_loop3  

    jmp draw_shape_done
;-----------------------------------                 
ll_shape:
    mov AH, 0ch                 
    mov al, color

    mov dx, start_row_ll_right
    add dx, block_size
    add dx, block_size
    mov finish_row_ll_right, dx

    mov dx, start_col_ll_right
    add dx, block_size
    mov finish_col_ll_right, dx

    
    mov dx, start_row_ll_right
    
ll_loop1:
    mov cx, start_col_ll_right
    
ll_loop2:
    INT 10h
    INC cx
    CMP cx, finish_col_ll_right
    JNZ ll_loop2
    
    INC dx
    CMP dx, finish_row_ll_right
    JNZ ll_loop1  

; left-part
    mov AH, 0ch                 
    mov al, color

    mov dx, start_row_ll_left
    add dx, block_size
    add dx, block_size
    mov finish_row_ll_left, dx

    mov dx, start_col_ll_left
    add dx, block_size
    mov finish_col_ll_left, dx

    
    mov dx, start_row_ll_left
    
ll_loop3:
    mov cx, start_col_ll_left
    
ll_loop4:
    INT 10h
    INC cx
    CMP cx, finish_col_ll_left
    JNZ ll_loop4
    
    INC dx
    CMP dx, finish_row_ll_left
    JNZ ll_loop3  

    jmp draw_shape_done

;-----------------------------------                 


draw_shape_done:    
    ret
endp draw_shape

;********************************************************************************

shift_down_shape proc

    cmp shape_number, 1
    jz shift_down_square_shape

    cmp shape_number, 2
    jz shift_down_horizontal_rectangle_shape

    cmp shape_number, 3
    jz shift_down_t_shape

    cmp shape_number, 4
    jz shift_down_l_shape

    cmp shape_number, 5
    jz shift_down_ll_shape

    jmp shift_down_done


shift_down_square_shape:

    mov color, 0
    call draw_shape

    mov dx, start_row_sq
    add dx, block_size
    mov start_row_sq, dx

    mov color, 14
    call draw_shape
    call fall_delay

    jmp shift_down_done

;---------------------------

shift_down_horizontal_rectangle_shape:

    mov color, 0
    call draw_shape

    mov dx, start_row_rec_h
    add dx, block_size
    mov start_row_rec_h, dx

    mov color, 9  ; set color blue
    call draw_shape
    call fall_delay

    jmp shift_down_done

;---------------------------

shift_down_t_shape:

    mov color, 0
    call draw_shape

    mov dx, start_row_t_down
    add dx, block_size
    mov start_row_t_down, dx
    
    mov dx, start_row_t_up
    add dx, block_size
    mov start_row_t_up, dx

    mov color, 13  ; set color light magenta
    call draw_shape
    call fall_delay

    jmp shift_down_done


;---------------------------
shift_down_l_shape:
    mov color, 0
    call draw_shape

    mov dx, start_row_l_right
    add dx, block_size
    mov start_row_l_right, dx
    
    mov dx, start_row_l_left
    add dx, block_size
    mov start_row_l_left, dx

    mov color, 12  ; set color light red
    call draw_shape
    call fall_delay

    jmp shift_down_done
;---------------------------
shift_down_ll_shape:
    mov color, 0
    call draw_shape

    mov dx, start_row_ll_right
    add dx, block_size
    mov start_row_ll_right, dx
    
    mov dx, start_row_ll_left
    add dx, block_size
    mov start_row_ll_left, dx

    mov color, 10  ; set color light green
    call draw_shape
    call fall_delay

    jmp shift_down_done
;---------------------------

shift_down_done:
    ret
endp shift_down_shape
               
;********************************************************************************
shape_can_move_down proc

    cmp shape_number, 3
    jz can_t_shape_move_down

    cmp shape_number, 4
    jz can_l_shape_move_down

    cmp shape_number, 5
    jz  can_ll_shape_move_down

    mov ax, current_row_screen
    add ax, block_size
    mov current_row_screen, ax
    cmp current_row_screen, 180 ; has reached down
    js shape_can_move_down_done:
    jz has_reached_down

has_reached_down:
    call next_shape
    jmp shape_can_move_down_done

can_t_shape_move_down:
    mov ax, current_row_screen
    add ax, block_size
    mov current_row_screen, ax
    cmp current_row_screen, 165 ; has reached down
    jnz shape_can_move_down_done:
    jz has_reached_down 

can_l_shape_move_down:   
    mov ax, current_row_screen
    add ax, block_size
    mov current_row_screen, ax
    cmp current_row_screen, 150 ; has reached down
    jnz shape_can_move_down_done:
    jz has_reached_down 

can_ll_shape_move_down:
    mov ax, current_row_screen
    add ax, block_size
    mov current_row_screen, ax
    cmp current_row_screen, 150 ; has reached down
    jnz shape_can_move_down_done:
    jz has_reached_down 


shape_can_move_down_done:
    ret
    endp shape_can_move_down
;********************************************************************************

shift_right_shape proc

    cmp shape_number, 1
    jz shift_right_square_shape

    cmp shape_number, 2
    jz shift_right_horizontal_rectangle_shape

    cmp shape_number, 3
    jz shift_right_t_shape

    cmp shape_number, 4
    jz shift_right_l_shape

    cmp shape_number, 5
    jz shift_right_ll_shape

    jmp shift_right_done


;shifting square shape

shift_right_square_shape:

    mov ax, finish_col_screen_r
    cmp finish_col_sq, ax
    js square_can_move_right

    jmp shift_right_done
    
square_can_move_right:

    mov color, 0
    call draw_shape

    mov dx, start_col_sq
    add dx, block_size
    mov start_col_sq, dx

    mov color, 14
    call draw_shape
    call fall_delay

    jmp shift_right_done:

;-------------------------

shift_right_horizontal_rectangle_shape:

    mov ax, finish_col_screen_r
    cmp finish_col_rec_h, ax
    js horizontal_rectangle_can_move_right

    jmp shift_right_done

horizontal_rectangle_can_move_right:

    mov color, 0
    call draw_shape

    mov dx, start_col_rec_h
    add dx, block_size
    mov start_col_rec_h, dx

    mov color, 9
    call draw_shape
    call fall_delay

    jmp shift_right_done

;--------------------------

shift_right_t_shape:

    mov ax, finish_col_screen_r
    cmp finish_col_t_down, ax
    js t_shape_can_move_right

    jmp shift_right_done

t_shape_can_move_right:

    mov color, 0
    call draw_shape

    mov dx, start_col_t_up
    add dx, block_size
    mov start_col_t_up, dx

    mov dx, start_col_t_down
    add dx, block_size
    mov start_col_t_down, dx

    mov color, 13
    call draw_shape
    call fall_delay

    jmp shift_right_done

;-----------------------------
shift_right_l_shape:

    mov ax, finish_col_screen_r
    cmp finish_col_l_right, ax
    js l_shape_can_move_right

    jmp shift_right_done

l_shape_can_move_right:

    mov color, 0
    call draw_shape

    mov dx, start_col_l_right
    add dx, block_size
    mov start_col_l_right, dx

    mov dx, start_col_l_left
    add dx, block_size
    mov start_col_l_left, dx

    mov color, 12
    call draw_shape
    call fall_delay

    jmp shift_right_done

;----------------------------
shift_right_ll_shape:

    mov ax, finish_col_screen_r
    cmp finish_col_ll_right, ax
    js ll_shape_can_move_right

    jmp shift_right_done

ll_shape_can_move_right:

    mov color, 0
    call draw_shape

    mov dx, start_col_ll_right
    add dx, block_size
    mov start_col_ll_right, dx

    mov dx, start_col_ll_left
    add dx, block_size
    mov start_col_ll_left, dx

    mov color, 10
    call draw_shape
    call fall_delay

    jmp shift_right_done

shift_right_done:
    ret
    endp shift_right_shape

;********************************************************************************

shift_left_shape proc

    cmp shape_number, 1
    jz shift_left_square_shape

    cmp shape_number, 2
    jz shift_left_horizontal_rectangle_shape

    cmp shape_number, 3
    jz shift_left_t_shape

    cmp shape_number, 4
    jz shift_left_l_shape

    cmp shape_number, 5
    jz shift_left_ll_shape

    jmp shift_left_done

; shifting square shape

shift_left_square_shape:

    mov ax, finish_col_screen_l
    cmp ax, start_col_sq
    js square_can_move_left

    jmp shift_left_done

square_can_move_left:

    mov color, 0
    call draw_shape

    mov dx, start_col_sq
    sub dx, block_size
    mov start_col_sq, dx

    mov color, 14
    call draw_shape
    call fall_delay

    jmp shift_left_done

;----------------------

shift_left_horizontal_rectangle_shape:

    mov ax, finish_col_screen_l
    cmp ax, start_col_rec_h
    js horizontal_rectangle_can_move__left

    jmp shift_left_done

horizontal_rectangle_can_move__left:

    mov color, 0
    call draw_shape

    mov dx, start_col_rec_h
    sub dx, block_size
    mov start_col_rec_h, dx

    mov color, 9
    call draw_shape
    call fall_delay

    jmp shift_left_done

;-----------------------

shift_left_t_shape:
    mov ax, finish_col_screen_l
    cmp ax, start_col_t_down
    js t_shape_can_move_left

    jmp shift_left_done

t_shape_can_move_left:
    mov color, 0
    call draw_shape

    mov dx, start_col_t_down
    sub dx, block_size
    mov start_col_t_down, dx

    
    mov dx, start_col_t_up
    sub dx, block_size
    mov start_col_t_up, dx

    mov color, 13
    call draw_shape
    call fall_delay

    jmp shift_left_done

;------------------------
shift_left_l_shape:

    mov ax, finish_col_screen_l
    cmp ax, start_col_l_left
    js l_shape_can_move_left

    jmp shift_left_done

l_shape_can_move_left:
    mov color, 0
    call draw_shape

    mov dx, start_col_l_left
    sub dx, block_size
    mov start_col_l_left, dx

    
    mov dx, start_col_l_right
    sub dx, block_size
    mov start_col_l_right, dx

    mov color, 12
    call draw_shape
    call fall_delay

    jmp shift_left_done

;-----------------------------
shift_left_ll_shape:

    mov ax, finish_col_screen_l
    cmp ax, start_col_ll_left
    js ll_shape_can_move_left

    jmp shift_left_done

ll_shape_can_move_left:
    mov color, 0
    call draw_shape

    mov dx, start_col_ll_left
    sub dx, block_size
    mov start_col_ll_left, dx
    
    mov dx, start_col_ll_right
    sub dx, block_size
    mov start_col_ll_right, dx

    mov color, 10
    call draw_shape
    call fall_delay

    jmp shift_left_done

;-------------------------------

shift_left_done:
    ret
    endp shift_left_shape

;********************************************************************************
quick_shift_down proc

    cmp shape_number, 1
    jz quick_shift_down_square

quick_shift_down_square:

    mov color, 0
    call draw_shape

    mov dx, start_row_sq

    add dx, block_size
    mov current_row_screen, dx

    add dx, block_size
    mov current_row_screen, dx

    add dx, block_size
    mov current_row_screen, dx

    mov start_row_sq, dx

    mov color, 14
    call draw_shape
    call fall_delay



    ret
    endp quick_shift_down

;********************************************************************************

ENDP MAIN
