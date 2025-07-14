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
    
    # Llamar a bubble sort optimizado
    jal bubble_sort_opt
    
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

bubble_sort_opt:
    addi $sp, $sp, -4
    sw $ra, 0($sp)

    move $t0, $a1        # n
    addi $t0, $t0, -1    # outer counter: i = n-1
    li $t8, 0            # contador de optimización

outer_loop_opt:
    li $t1, 0            # swapped = false
    li $t2, 0            # j = 0
    move $t3, $a0        # copia de dirección base

inner_loop_opt:
    lw $t4, 0($t3)       # array[j]
    lw $t5, 4($t3)       # array[j+1]
    
    addi $t9, $t9, 1     # contador de ciclos

    ble $t4, $t5, no_swap_opt   # if <=, no swap

    # Swap
    sw $t5, 0($t3)
    sw $t4, 4($t3)
    li $t1, 1            # swapped = true

no_swap_opt:
    addi $t3, $t3, 4     # j++
    addi $t2, $t2, 1     # j counter
    addi $t8, $t8, 1     # contador optimizado
    
    addi $t9, $t9, 1     # contador de ciclos
    
    blt $t2, $t0, inner_loop_opt

    beqz $t1, end_bubble_opt  # if no swaps, done

    addi $t0, $t0, -1    # i--
    bgtz $t0, outer_loop_opt

end_bubble_opt:
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra