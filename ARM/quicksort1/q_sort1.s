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



/* NOTE: START OF main */
.align 4
.global main
.type main, %function
main:
	push {r4,r5,r6,r7,r8,r9, lr}
	sub sp, sp, #12		/* sp+0: file_pointer, sp+4: N (size of input), sp+8: start of input array */
	cmp r0, #3
	bne usage
	
	ldr r0, [r1, #4]		/* sto r0 to input_file */
	ldr r9, [r1, #8]		/* sto r9 kratame to output_file */
	mov r5, r0			/* swse to filename kai sto r5 proswrina */
	ldr r1, =str3			/* sto r1 to "r" */
	bl fopen
	cmp r0, #0			/* an h fopen apotyxei typwse mnm kai fyge */
	bne cont_MAIN
	mov r0, r5
	bl perror
	mov r0, #-1
	bl exit
cont_MAIN:				/* diaforetika synexise */
	str r0, [sp, #0]		/* sto sp+0 vazw to FILE * */

	ldr r1, =str5
	add r2, sp, #4
	bl fscanf			/* twra sto sp+4 exoume th metavlhth mas */
	
	ldr r0, [sp, #4]
	lsl r0, #2 		/* left shift 2 theseis (k*sizeof(int) == k*4 == k<<2) */
	bl malloc			/* malloc(N * sizeof(int)) */
	str r0, [sp, #8]	/* swse th dieuth tou pinaka sto sp+8 */
	

/* Gia na diavasoume kai na typwsoume -apodotika- ton pinaka prp na arxikopoihsoume kapoious
 * registers (wste na apofegoume tis prospelaseis sth mnhmh se kathe iteration)..
 * autoi einai:
 * * r4 <-- file pointer
 * * r5 <-- "%d"
 * * r6 <-- &array[0] (opws epestrepse h malloc)
 * * r7 <-- 0 (i)
 * * r8 <-- k (megethos pinaka eisodou)
 * Autous tous registers h main prepei na tous exei prwta valei sth stoiva wste meta na tous
 * epanaferei.
 */
	ldr r4, [sp, #0]	/* ston r4 kratame to FILE pointer */
	ldr r5, =str5		/* ston r5 to "%d" */
	mov r6, r0		/* ston r6 thn vash tou pinaka */
	mov r7, #0		/* for (i=0; ... */
	ldr r8, [sp, #4]	/* r8 = k */
/* read elements of array */
read_inp:
	mov r0, r4
	mov r1, r5
	mov r2, r7
	lsl r2, #2		/* phgaine sthn katallhlh dieuth */
	add r2, r2, r6
	bl fscanf
	add r7, r7, #1
	cmp r7, r8
	bne read_inp

/* close file */
	ldr r0, [sp, #0]
	bl fclose

/* do your job here */
/* qsort(array, 0, k-1); */
	mov r0, r6
	mov r1, #0
	sub r2, r8, #1
	bl q_sort

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
	add sp, sp, #12
	pop {r4,r5,r6,r7,r8,r9, pc}
.size main, .-main


.data

str1: .ascii "%s\n\000"
str2: .ascii "Usage: ./qsort inp_file out_file\n\000"
str3: .ascii "r\000"
str4: .ascii "w\000"
str5: .ascii "%d\000"
str6: .ascii "%d \000"
nl:   .ascii "\n\000"
debug: .ascii "DEBUG\n\000"
