/*
	Author: Jeremy Kimotho
	Date: 15/11/2020
*/

	.text
	prnfmt1: .string "\n*****Program Starts*****\n\n"
	prnfmt3: .string "Please enter input in the form <filename> M N\n"
	prnfmt4: .string "Please enter values of M and N between 4 and 16 inclusive\n"
	prnfmt5: .string "\n*****Program Ends*****\n\n"
	prnfmt6: .string "M is %s and N is %s\n"	
	prnfmt7: .string "%-3d"
	prnfmt8: .string "\n"
	prnfmt9: .string "Highest: %d, Index: %d, Frequency: %d"


	column_s = 19
	row_s = 16
	struct_1 = 4
	struct_2 = 8
	struct_3 = 12
	
	struct_size = 12	

	// Register equates
	alloc_r	.req	x23

	// Defined Macros
	define(argv, x21)
	define(row, x19)
	define(column, x20)
	define(argc, w22)

	define(offset, x27)
	define(sum, x28)
	define(base, x29)
	define(i_r, x21)
	define(j_r, x22)
	define(random, x25)
	define(index, x24)
	define(highest, x26)	
	define(frequency, x18)
	define(temp, x17)
	define(size, x22)
	define(t_base, x27)

	.balign 4
	.global main

main:
	stp	x29,	x30,	[sp,16]!				// save fp register and link register current values
	mov	x29,	sp						// update fp register
	
	mov	argv,	x1						// saving the arguments from the command line to argv 
	mov	argc,	w0						// saving the number of arguments from the command line to argc

	cmp	argc,	3						// comparing the number of arguments passed to 3
	b.ne	wrongArguments						// if the number if arguments is not equal to 3 we branch to wrongArguments

	ldr	row,	[argv,8]					// loading from memory the second argument that was passed in cmd line
	ldr	column,	[argv,16]					// loading from memory the third argument that was passed in cmd line

	mov	x0,	row						// copying the row value to x0
	bl	atoi							// converting to int the row value that was copied to x0
	mov	row,	x0						// copying the row value that is now an int back to row

	mov	x0,	column						// copying the column value to x0
	bl	atoi							// converting to int the column value that was copied to x0
	mov	column,	x0						// copying the coilumn value that is now an int back to column

	cmp	row,	4						// comparing the row value to integer 4
	b.lt	wrongInput						// if the row is less than 4 we branch to wrongInput
	cmp	column,	4						// comparing the column value to integer 4
	b.lt	wrongInput						// if the column is less than 4 we branch to wrongInput
	cmp	column,	16						// comparing the column value to integer 16
	b.gt	wrongInput						// if the column value is larger than 16 we branch to wrongInput
	cmp	row,	16						// comparing the row value to integer 16
	b.gt	wrongInput						// if the row value is larger than 16 we branch to wronInput

programStart:								// label name for where we start the program 
	ldr	x0,	=prnfmt1					// load the string prnfmt1 to x0
	bl	printf							// branch to C function printf and print value in x0

	mov	alloc_r,	-(row_s*column_s*4)&-16			// allocating enough memory for a 16*19/19*16 2d array of ints	
	add	sp,	sp,	alloc_r					// allocate the number of bytes we need on top of the stack	
	mov	x29,	sp

	mov	i_r,	0						// set i for my loop to 0
	mov	j_r,	0						// set j for my loop to 0
	mov	offset,	0						// set offset for my loop to 0
	mov	sum,	0						// set sum for my loop to 0
	mov	highest,0						// set highest for my loop to 0
	mov	temp,	0						// set temp for my loop to 0
	mov	random,	0						// set random for my loop to 0

	mov	x0,	xzr						// copy 0 into x0 for seeding of rand
	bl	time							// seeding of rand
	bl	srand							// seeding of rand
loop:									// loop where we store the values in memory
	bl	rand							// generate a random with C function rand
	mov	random,	x0						// move generated random to non-temporary register
	and	random,	random,	0xF
	
	mul	offset,	column,	i_r					// multiply column by i which is row index. this is first part of offset
	add	offset,	offset,	j_r					// adding to offset j which is column index
	lsl	offset,	offset,	2					// multiplying offset by 4 because cell size is 4
		
	add	random,	random,	1					// incrementing random by 1 to avoid 0 values
	cmp	random,	16						// ensuring our random is below or is 16
	b.gt	loop							// if random is greater than 16 we branch back to loop beginning
	
	add	sum,	sum,	random					// add to our sum the random value we just generated
	str	random,	[base, offset]					// store in memory address base+offset the random value
	cmp	random,	highest						// compare the random to highest we currently have
	b.gt	new_highest						// if random current is bigger than previous highest we replace highest with current random
continue:								// where we return after setting new highest value
	add	j_r,	j_r,	1					// incrementing the column index by 1
	cmp	j_r,	column						// comparing our count for how many columns with required size we want in column
	b.lt	loop							// if we don't have enough columns we branch back to the start of the loop
	
	add	t_base,	base,	offset					// add the base and offset and that will be our basse for the structure
	
	str	highest,[t_base, struct_1]				// store into memory address t_base+struct_1 the highest value in that row
	str	index,	[t_base, struct_2]				// store into memory address t_base+struct_2 the index of the highest value in that row
	mov	x1,	100						// copy into x1 100
	mul	frequency,highest,x1					// multiply the highest value and 100
	udiv	frequency,frequency,sum					// divide (highest value multiplied by 100) by sum of that row
	str	frequency,[t_base, struct_3]				// store into memory address  t_base+struct3 the frequency of the highest value in that row
	
	add	base,	base,	12					// add 12 to the base to accomodate for the structure of size 12 we just added to memory
	
	mov	highest,0						// copy 0 back into highest as we prepare to store new row
	mov	sum,	0						// copy 0 back into sum as we prepare to store new row
	mov	j_r,	0						// copy 0 back into column index as we prepare to store new row
	mov	offset,	0						// copy 0 back into offset as we prepare to store new row
	add	i_r,	i_r,	1					// increment the row index by 1
	cmp	i_r,	row						// compare how many rows we already have with how many we need
	b.lt	loop							// if we don't have enough rows we branch back to start of loop

	mov	sum,	0						// set sum for my loop to 0
	mov	highest,0						// set highest for my loop to 0
	mov	i_r,	0						// set i for my loop to 0
	mov	j_r,	0						// set j for my loop to 0
	mov	offset,	0						// set offset for my loop to 0
	mov	temp,	12						// copy 12 into temp 
	mul	temp,	temp,	row					// multiply 12 and row value. this is how many bytes we need to move up the base
	sub	base,	base,	temp					// move the base up (subtract) the bytes we added in the previous loop. base is now in initial state before store loop

print:									// loop where we load from memory and print the data
	mul     offset, column, i_r					// multiply column by i which is row index. this is first part of offset
        add     offset, offset, j_r					// adding to offset j which is column index
        lsl     offset, offset, 2					// multiplying offset by 4 because cell size is 4

	ldr	random,	[base, offset]					// load from memory base+offset the random value we had stored earlier

	ldr	x0,	=prnfmt7					// load into x0 string prmfmt7
	mov	x1,	random						// copy the random value into x1 for printing
	bl	printf							// printing the random value using C function printf

	add	j_r,	j_r,	1					// increment the column index by 1
	cmp	j_r,	column						// comparing the number of column we already printed and how many we need to print
	b.lt	print							// if we haven't printed all the columns yet we branch back to loop
	
	add	t_base,	base,	offset					// add the base and offset and that will be our base for the structure
	
        ldr     highest,[t_base, struct_1]				// load from memory t_base+struct_1 the highest value we stored earlier
        ldr     index, 	[t_base, struct_2]				// load from memory t_base+struct_2 the index value we stored earlier
        ldr     frequency,[t_base, struct_3]				// load from memory t_base+struct_1 the frequency value we stored earlier

	add	base,	base,	12					// add 12 to the base to accomodate for the structure of size 12 we just added to memory	

	ldr	x0,	=prnfmt9					// load string prnfmt9 to x0
	mov	x1,	highest						// copy highest to x1 for printing
	mov	x2,	index						// copy index to x2 for printing
	mov	x3,	frequency					// copy frequency to x3 for printing
	bl	printf							// printing the highest, index and frequency using C function printf

	ldr	x0,	=prnfmt8					// load string prnfmt8 to x0
	bl	printf							// print nextline character using C function printf
	mov	highest,0						// copy 0 back into highest as we prepare to store new row
	mov	frequency,0						// copy 0 back into frequency as we prepare to store new row					
	mov	j_r,	0						// copy 0 back into column index as we prepare to store new row
	add	i_r,	i_r,	1					// increment the row index by 1
	cmp	i_r,	row						// compare how many rows we already printed with how many we need to print
	b.lt	print							// if we haven't printed enough rows we branch back to start of loop

	ldr	x0,	=prnfmt5					// load the string prnfmt5 to x0
	bl	printf							// branch to the C function printf and print value in x0
	b	end							// branch to the end function that deallocates memory and restores registers

new_highest:								// function where we set the highest value and it's index
	mov	highest,random						// make random the new highest by copying it into highest
	mov	index,	j_r						// copy column index of highest into index
	b	continue						// branch back to the store loop

wrongArguments:								// label name for where we return error message of wrong argument number
	ldr	x0,	=prnfmt3					// load the string prnfmt3 to x0
	bl	printf							// branch to the C function printf and print value in x0
	b	endEarly						// branch to the end function that restores registers

wrongInput:								// label name for where we return error message for wrong values for row and column
	ldr	x0,	=prnfmt4					// load the string prnfmt4 to x0
	bl	printf							// branch to the C function printf and print value in x0
	b	endEarly						// branch to the end function that restores registers

end:									// label name for where we deallocate the memory for the 2d array and restore registers if the program ran
	sub	alloc_r,	xzr,	alloc_r				// make the allocated memory a minus of itself (alloc*-1)
	add	sp,		sp,	alloc_r				// remove the allocated memory from the stack frame
endEarly:								// label name for where we end if user entered incorrect M and/or N values before we allocate memory
	ldp	x29,	x30,	[sp],	16				// restore fp and link registers
	ret								
