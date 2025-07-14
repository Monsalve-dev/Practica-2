.data
array:      .space 400       # 100 elementos máximo (4 bytes cada uno)
n:          .word 0
prompt_n:   .asciiz "Ingrese cantidad de números (n <= 100): "
prompt_num: .asciiz "Ingrese número: "
space:      .asciiz " "
newline:    .asciiz "\n"
time_msg:   .asciiz "Ciclos de ejecución: "

.text
main:
    # Pedir cantidad de números
    li $v0, 4
    la $a0, prompt_n
    syscall
    
    li $v0, 5
    syscall
    sw $v0, n
    move $s0, $v0            # $s0 = n
    
    # Pedir números
    la $s1, array            # $s1 = dirección base del array
    li $t0, 0                # contador
    
input_loop:
    bge $t0, $s0, end_input
    
    li $v0, 4
    la $a0, prompt_num
    syscall
    
    li $v0, 5
    syscall
    
    sw $v0, 0($s1)           # guardar número
    addi $s1, $s1, 4         # siguiente posición
    addi $t0, $t0, 1         # incrementar contador
    j input_loop
    
end_input:
    # Preparar para ordenamiento
    la $a0, array
    move $a1, $s0
    
    # Iniciar contador de ciclos
    move $t9, $zero
    
    # Llamar a selection sort
    jal selection_sort
    
    # Guardar total de ciclos
    move $s2, $t9
    
    # Mostrar array ordenado
    la $t0, array
    li $t1, 0
    
print_loop:
    bge $t1, $s0, end_print
    
    lw $a0, 0($t0)
    li $v0, 1
    syscall
    
    li $v0, 4
    la $a0, space
    syscall
    
    addi $t0, $t0, 4
    addi $t1, $t1, 1
    j print_loop
    
end_print:
    # Mostrar tiempo de ejecución
    li $v0, 4
    la $a0, newline
    syscall
    
    li $v0, 4
    la $a0, time_msg
    syscall
    
    li $v0, 1
    move $a0, $s2
    syscall
    
    # Terminar programa
    li $v0, 10
    syscall

selection_sort:
    addi $sp, $sp, -4
    sw $ra, 0($sp)

    li $t0, 0           # i = 0

outer_loop_sel:
    move $t1, $t0        # min_idx = i
    addi $t2, $t0, 1     # j = i+1

inner_loop_sel:
    sll $t3, $t1, 2      # offset min_idx
    add $t3, $a0, $t3
    lw $t4, 0($t3)       # array[min_idx]

    sll $t5, $t2, 2      # offset j
    add $t5, $a0, $t5
    lw $t6, 0($t5)       # array[j]
    
    addi $t9, $t9, 1     # contador de ciclos

    bge $t6, $t4, no_new_min

    move $t1, $t2        # min_idx = j

no_new_min:
    addi $t2, $t2, 1     # j++
    addi $t9, $t9, 1     # contador de ciclos
    
    blt $t2, $a1, inner_loop_sel

    # Swap
    sll $t7, $t0, 2      # offset i
    add $t7, $a0, $t7
    lw $t8, 0($t7)       # array[i]

    sll $t3, $t1, 2      # offset min_idx
    add $t3, $a0, $t3
    lw $s1, 0($t3)       # array[min_idx]

    sw $s1, 0($t7)
    sw $t8, 0($t3)
    
    addi $t9, $t9, 3     # contador de ciclos (swap)

    addi $t0, $t0, 1     # i++
    addi $t3, $a1, -1
    blt $t0, $t3, outer_loop_sel

    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra