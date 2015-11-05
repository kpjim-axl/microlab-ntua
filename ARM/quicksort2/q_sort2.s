.text

/* NOTE: START OF partition */
.align 4
.global partition
.type partition, %function
/* partition: dialegei ena stoixeio apo ton pinaka (to prwto) kai sth synexeia
 * fernei ola ta stoixeia tou pinaka pou einai mikrotera aristera tou kai ola 
 * osa einai megalytera de3ia tou. ektos twn orismatwn r0-2,
 * xrhsimopoiei tous r3-6 (tous r4-6 tous swzei sth stoiva).
 * ORISMATA:
 * * r0 <- pointer sto array
 * * r1 <- left limit tou kommatiou tou array sto opoio ginontai oi pra3eis
 * * r2 <- right >> 	>>	>>		>>		>>		>>	>>	>>
 * EPISTREFEI:
 * * r0 <- index sto opoio katelh3e to pivot meta tis enallages twn stoixeiwn
 */
partition:
	push {r4,r5,r6, lr}
	
	mov r3, r1
	lsl r3, #2
	add r3, r3, r0

/* r0 <-- &array[0]
 * r1 <-- i
 * r2 <-- j
 * r3 <-- pivot
 */
	ldr r3, [r3, #0]	/* pivot = array[left]	*/
	sub r1, r1, #1		/* i = left - 1		*/
	add r2, r2, #1		/* j = right + 1		*/

while1_part:				/* while(1) */
while2_part:				/* while(array[++i] < pivot) */
	add r1, r1, #1
	
	mov r4, r1
	lsl r4, #2
	add r4, r4, r0
	ldr r4, [r4, #0]		/* r4 <-- array[++i] */
	
	cmp r4, r3
	bgt while2_part		/* end of while2 */
	
while3_part:				/* while(array[--j] > pivot) */
	sub r2, r2, #1
	
	mov r5, r2
	lsl r5, #2
	add r5, r5, r0
	ldr r5, [r5, #0]	/* r5 <-- array[--j] */
	
	cmp r5, r3
	blt while3_part		/* end of while3 */

	/* if (i>=j) return j; */
	cmp r1, r2
	bge ret_part
	
	/* else swap(array[i], array[j]); */
	mov r6, r2
	lsl r6, #2
	add r6, r6, r0
	str r4, [r6, #0]
	
	mov r6, r1
	lsl r6, #2
	add r6, r6, r0
	str r5, [r6, #0]

	b while1_part			/* end of while1 */
	
ret_part:
	mov r0, r2			/* return j */
	pop {r4,r5,r6, pc}
.size partition, .-partition


/* NOTE: START OF q_sort */
.align 4
.global q_sort
.type q_sort, %function
/* q_sort: an to de3i orio tou pinaka pros ta3inomhsh einai prin to aristero
 * tote epistrefei. Diaforetika diaxwrizei ton pinaka se mikrotera kai megalytera
 * stoixeia enos sygkekrimenou kai anadromika ta3inomei tous 2 ypopinakes.
 * ORISMATA:
 * * r0 <-- pointer ston pinaka
 * * r1 <-- left limit tou pros ta3inomhsh pinaka
 * * r3 <-- right >>	>>		>>		>>
 * EPISTREFEI:
 * * -tipota-
 * XRHSIMOPOIEI:
 * * r0-2: orismata
 * * r4-7: tous apo8hkeuei gia epanafora kata thn epistrofh
 */
q_sort:
	push {r4,r5,r6,r7, lr}
	
	/* if (right < left) return */
	cmp r1, r2
	bge ret_sort
	
/* 	i = partition(array,left,right); */
	mov r4, r0
	mov r5, r1
	mov r6, r2	
	bl partition
	mov r7, r0
	
/* 	q_sort(array,left,i); */
	mov r0, r4
	mov r1, r5
	mov r2, r7
	bl q_sort

/* 	q_sort(array,i+1,right); */
	mov r0, r4
	add r1, r7, #1
	mov r2, r6
	bl q_sort

/* return */
ret_sort:
	pop {r4,r5,r6,r7, pc}
.size q_sort, .-q_sort


/* NOTE: START OF read_inp */
.align 4
.global read_inp
.type read_inp, %function
/* read_inp: diavazei apo to plhktrologio arithmous, mexri na vrei allagh grammhs. Gia kathe
 * arithmo, dhmiourgei ena struct node { int data; stuct node *next; } to opoio arxikopoiei kai
 * topothetei sto telos ths listas. Telika antigrafei ta stoixeia ths listas se enan pinaka pou
 * sto meta3y dhmiourghse
 * SHMEIWSH: Gia na doulepsei swsta to programma prepei na dwthei swsta h eisodos apo to plhktrologio.
 * Dhladh prepei h allagh grammhs na vrisketai akrivws meta ton teleytaio arithmo (kai oxi kapoios allos
 * xarakthras opws ' ')
 * EPISTREFEI:
 * * r0 <-- array
 * * r1 <-- arithmos akeraiwn pou diavasthkan (k-1)
 * ALLAZEI:
 * * r0-3
 */
read_inp:
	push {r4,r5, lr}
	/* sp+0 <-- list[first] (r4 <-- list[last])
	 * sp+4 = k
	 * sp+8 = c
	 */
	sub sp, sp, #9
	mov r0, #8		/* sizeof (struct bla {int i, struct bla *next}) = 8 */
	bl malloc
	str r0, [sp, #0]
	mov r4, r0
	mov r5, #0
	
.Lread:
	ldr r0, =str3
	add r1, sp, #4
	add r2, sp, #8
	bl scanf
	
	mov r0, #8
	bl malloc
	
	/* new->data = k */
	ldr r2, [sp, #4]
	str r2, [r0, #0]
	/* new->next = NULL */
	mov r2, #0
	str r2, [r0, #4]
	
	/* last->next = new */
	str r0, [r4, #4]
	/* last = new */
	mov r4, r0
	
	add r5, r5, #1
	
	ldrb r2, [sp, #8]
	cmp r2, #10			/* if (c=='\n') break; */
	beq .Bread			/* else loop */
	b .Lread
	
.Bread:
	mov r0, r5
	
	lsl r0, #2
	bl malloc
	mov r1, r0
	ldr r3, [sp, #0]
	
/* while (!current->next){ array[i++] = (current=current->next)->data; }
 * Arxika to r3 deixnei sto prwto element ths listas to opoio einai keno
 * opote apo to epomeno arxizoume na vazoume ta dedomena ston pinaka, mexris
 * otou ftasoume sto telos ths listas
 */
.Lread2:
	ldr r3, [r3, #4]
	ldr r2, [r3, #0]
	str r2, [r1, #0]
	add r1, r1, #4
	ldr r2, [r3, #4]
	cmp r2, #0
	bne .Lread2
	
	add sp, sp, #9
	mov r1, r5
	pop {r4,r5, pc}
.size read_inp, .-read_inp
	
	
	


/* NOTE: START OF main */
.align 4
.global main
.type main, %function
/* Idia ylopoihsh me to q_sort1, me th diafora pws h eisagwgh twn stoixeiwn ginetai dynamika.
 * Arxika diavazoume apo to plhktrologio ena int kai ena char, mexri to char na ginei '\n'.
 * Ta stoixeia arxika ta vazoume se lista kai sth synexeia ta metaferoume ston pinaka. Apo ekei
 * kai pera h diadikasia einai idia me prin
 */
main:
	push {r4,r5,r6,r7,r8,r9, lr}
	sub sp, sp, #8
	cmp r0, #2
	bne usage
	
	ldr r9, [r1, #4] /* out */
	
	bl read_inp
	
	sub r2, r1, #1
	mov r1, #0
	bl q_sort
	add r8, r1, #1
	mov r6, r0
	
	/* open output file */
	mov r0, r9
	ldr r1, =str4
	bl fopen
	cmp r0, #0
	bne cont2_MAIN
	mov r0, r9
	bl perror
	mov r0, #-1
	bl exit
cont2_MAIN:
	mov r9, r0
/* print array */
	mov r7, #0
	ldr r5, =str6
print_inp:
	mov r0, r9
	mov r1, r5
	mov r2, r7
	lsl r2, #2
	add r2, r2, r6
	ldr r2, [r2, #0]
	bl fprintf
	add r7, r7, #1
	cmp r7, r8
	bne print_inp
	
	mov r0, r9
	ldr r1, =nl
	bl fprintf
	
	mov r0, r9
	bl fclose
	b end

usage:
	ldr r0, =str2
	bl printf

end:
	add sp, sp, #8
	pop {r4,r5,r6,r7,r8,r9, pc}
.size main, .-main


.data

str1: .ascii "%s\n\000"
str2: .ascii "Usage: ./qsort out_file\n\000"
str3: .ascii "%d%c\000"
str4: .ascii "w\000"
str6: .ascii "%d \000"
nl:   .ascii "\n\000"
debug: .ascii "DEBUG\n\000"
deb2: .ascii "%d\n\000"
