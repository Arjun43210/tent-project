.text

    main:
        #fix stack pointer
        addi $sp, $sp, -8
        sw $ra, 0($sp)
        sw $s0, 4($sp)

        move $s0, $zero #s0 = group* head = NULL
        
        reading_groups:
            jal get_group #gives name* ($v0) and avg score ($v1)

            beq $v1, -1, done_reading_groups #if done -> leave loop

            move $t0, $v0
            move $t1, $v1

            #add name,avg_score to LinkedList
            
            #Make struct group {char[64] name, int avg_score, group* next}
            li $a0, 72 # number of bytes needed (multiple of four)
            li $v0, 9 # code 9 == allocate memory
            syscall # $v0 = pointer to struct

            sw $t0, 0($v0) #memory[0]
            sw $t1, 64($v0) #memory[64]
            sw $zero, 68($v0) #memory[68]
            #(confirmed, stores correctly)


            #head = insert_team(head, new_group);
            move $a0, $s0
            move $a1, $v0
            jal insert_team
            move $s0, $v0

            j reading_groups

        done_reading_groups:

        #print groups in descending order
        move $a0, $s0
        jal print_teams

        #print total number of people
        lw $a0, people
        li $v0, 1
        syscall

        lw $ra, 0($sp)
        lw $s0, 4($sp)
        addi $sp, $sp, 8
        jr $ra

    
    get_group: #v0 = team name, v1 = avg score (or -1 if done)
        #prompt1
        la $a0, prompt1
        li $v0, 4
        syscall

            #Save team name in heap
            li $a0, 64
            li $v0, 9
            syscall
            move $t2, $v0

        move $a0, $t2
        la $a1, 63
        li $v0, 8
        syscall


        #Remove \n from team name (if it exists)
        addi $sp, $sp, -4
        sw $ra, 0($sp)
        jal remove_end_line #(a0 = team_name_input*)
        lw $ra, 0($sp)
        addi $sp, $sp, 4



        move $a0, $t2

        addi $sp, $sp, -4
        sw $ra, 0($sp)
        jal is_done
        lw $ra, 0($sp)
        addi $sp, $sp, 4


        beqz $v0, skip_DONE #if v0 = 0, not done, else done
            li $v1, -1
            jr $ra
        skip_DONE:


        #prompt 2
        la $a0, prompt2
        li $v0, 4
        syscall

        li $v0, 5
        syscall
        move $t0, $v0 #num people in $t0

        #prompt 3
        la $a0, prompt3
        li $v0, 4
        syscall

        li $v0, 5
        syscall
        move $t1, $v0 #total score in $t1


        move $v0, $t2 #team name in $v0
        div $v1, $t1, $t0 #avg score in $v1

        lw $t3, people
        add $t3, $t3, $t0
        sw $t3, people #total_people in .data/people

        jr $ra


    insert_team: #a0 = head*, a1 = current_group*, v0 = head*
        addi $sp, $sp, -4
        sw $ra, 0($sp)

        #move $v0, $a0 #return* = head*
        beqz $a0, insert_team_first_el #if head* == NULL, return team
        
        #else /*put in correct location of LinkedList*/

        addi $sp, $sp, -8
        sw $a0, 0($sp)
        sw $a1, 4($sp)
        jal compare #a0, a1 already there
        lw $a0, 0($sp)
        lw $a1, 4($sp)
        addi $sp, $sp, 8

        #if(compare(team, head) < 0)
        bgez $v0, insert_team_else_else #new group before head
            sw $a0, 68($a1) #*team.next = head
            move $v0, $a1
            j insert_team_end

        insert_team_else_else: #new_group somewhere in middle
            #move $v0, $a0 #return* = head*
            move $t0, $a0 #$t0 = pointer* = head*
            #li $t2, 0 #sorted = 0
            insert_team_loop:
                lw $t1, 68($t0) #$t1 = *pointer.next (next*)
                beqz $t1, insert_team_leave_loop

                #call compare again
                addi $sp, $sp, -16
                sw $a0, 0($sp)
                sw $a1, 4($sp)
                sw $t0, 8($sp)
                sw $t1, 12($sp)
                move $a0, $t1
                #move $a1, $a1
                jal compare #result in v0, already have a0, a1
                lw $a0, 0($sp)
                lw $a1, 4($sp)
                lw $t0, 8($sp)
                lw $t1, 12($sp)
                add $sp, $sp, 16


                bgez $v0, insert_team_loop_increment
                    sw $t1, 68($a1)
                    sw $a1, 68($t0)
                    move $v0, $a0
                    j insert_team_end

                insert_team_loop_increment:
                lw $t0, 68($t0) # pointer* = *pointer.next (next*)

                j insert_team_loop

            insert_team_leave_loop:
                sw $a1, 68($t0) #*pointer.next = team
                move $v0, $a0
                j insert_team_end

        insert_team_first_el: #if first element, return team
            move $v0, $a1

        insert_team_end:
        
        lw $ra, 0($sp)
        addi $sp, $sp, 4
        jr $ra

    print_teams: #a0 = pointer*
        move $t0, $a0 #$t0 = pointer*
        
        #Makes it here, confirmed

        print_teams_loop:
            beqz $t0, print_teams_end_loop

            lw $t1, 64($t0) #$t1 = avg_score
            beqz $t1, skip_print

            #print team
            lw $a0, 0($t0)
            li $v0, 4
            syscall
            la $a0, space #space character
            li $v0, 4
            syscall
            move $a0, $t1
            li $v0, 1
            syscall
            la $a0, end_line #\n character
            li $v0, 4
            syscall

            skip_print:
            lw $t0, 68($t0) #pointer* = *pointer.next
            
            j print_teams_loop

        print_teams_end_loop:
        jr $ra


    #More helper functions

    str_comp: #a0, a1 = input string addresses, #v0 < 0 (a0 < a1), #v0 > 0 (a0 > a1)

        str_comp_loop:
            lb $t0, ($a0) #take 1 byte
            lb $t1, ($a1) #take 1 byte
            sub $v0, $t0, $t1
            bnez $v0, str_comp_end #if not equal, end program
            
            beqz $t0, str_comp_equal_0 #if at end of a0, check a1
            beqz $t1, str_comp_equal_1 #if at end of a1, check a0

            addi $a0, $a0, 1
            addi $a1, $a1, 1
            j str_comp_loop

        str_comp_equal_0:
            beqz $t1, str_comp_done_equal
            jr $ra
        str_comp_equal_1:
            beqz $t0, str_comp_done_equal
            jr $ra
        
        str_comp_done_equal:
            li $v0, 0

        str_comp_end:
        jr $ra


        # Compares two strings alphabetically

    
    is_done: #a0 = string address, #v0 = 0 or 1

        la $a1, done

        addi $sp, $sp, -4
        sw $ra, 0($sp)
        jal str_comp
        lw $ra, 0($sp)
        addi $sp, $sp, 4

        beqz $v0, is_done_1
        li $v0, 0
        jr $ra

        is_done_1:
            li $v0, 1

        jr $ra

    
    remove_end_line: #a0 = char* first

        la $a1, end_line
        lb $a1, 0($a1) # char a1 = '\n'
        
        remove_loop:
            lb $t0, 0($a0) # char t0 = a0_pointer[0]
            sub $v0, $a1, $t0 # $v0 = 0 if t0 == '\n'
            beqz $v0, remove_found
            beqz $t0, no_end_found

            addi $a0, $a0, 1  #a0++

            j remove_loop        

        remove_found:
            sb $zero, 0($a0)

        no_end_found:
        jr $ra


    compare: #a0 = group1*, a1 = group2*, v0 > 0 if g2 -> g1, v0 < 0 if g1 -> g2
        lw $t0, 64($a0)
        lw $t1, 64($a1)
        
        beq $t0, $t1, compare_names

            sub $v0, $t1, $t0
            j compare_end

        compare_names:
            lw $a0, 0($a0)
            lw $a1, 0($a1)
            addi $sp, $sp, -4
            sw $ra, 0($sp)
            jal str_comp
            lw $ra, 0($sp)
            addi $sp, $sp, 4

        compare_end:
        li $t3, -1
        mul $v0, $v0, $t3
        jr $ra






.data
    prompt1: .asciiz "Enter team name (DONE to stop): "
    prompt2: .asciiz "Enter number of people: "
    prompt3: .asciiz "Enter total score: "
    people: .word 0
    done: .asciiz "DONE"
    team_name_input: .space 64
    end_line: .ascii "\n"
    space: .ascii " "
