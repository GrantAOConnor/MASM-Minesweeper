;minesweeper.asm		Title:		Names:

INCLUDE Irvine32.inc

.386
.model flat,stdcall
.stack 4096			;SS register
ExitProcess proto,dwExitCode:dword

.data				;DS register
	;rules to the game
	rules1			BYTE	"Each tile either contains a mine, or a number. Your goal is to flag each tile containing a mine and clear each tile that doesn't. Tiles showing ", 34, "-", 34, " have not been checked, tiles",0
	rules2			BYTE	"showing ", 34, "!", 34, " have been flagged as having a mine, and showing a number show you the total number of mines in adjacent tiles (including diagonals). You must use these numbers to ",0
	rules3			BYTE	"deduce the locations of all mines to win. If you clear a tile that shows a number on it, all adjacent non-flagged tiles will be cleared.",0
	rules4			BYTE	"Press <enter> to continue",0

	;board size (based on chosen difficulty)
	prompt1			BYTE	"Choose a Difficulty:",0
	prompt2			BYTE	"	1. Easy",0
	prompt3			BYTE	"	2. Medium",0
	prompt4			BYTE	"	3. Difficult",0
	prompt5			BYTE	"	4. Rules",0
	prompt6			BYTE	"Invalid input, 1-",0
	difficulty		DWORD	?
	board_size		DWORD	?
	mine_count		DWORD	?

	;2D 27x27m array defaulted to all 10s (unchecked non-mine tiles)
	board			DWORD	27 DUP(27 DUP(10))

	;strings for the print function
	dash			BYTE	" - ",0
	exclaimation	BYTE	" ! ",0
	vertical_line	BYTE	"|",0
	horizontal_line	BYTE	"___",0
	space			BYTE	" ",0

	;prompts for getting a coordinate
	prompt7			BYTE	"Choose a row: ",0
	prompt8			BYTE	"Choose a column: ",0

	;win/loss and misc error messages
	prompt9			BYTE	"You tried to clear a mine.  You LOSE!",0
	prompt10		BYTE	"You found all the mines.  You WIN!",0
	prompt11		BYTE	"Locations flagged for mines cannot be cleared.  Unflag this tile and try again if you really want to clear it.",0

	;row and column variables
	row				DWORD	?
	col				DWORD	?

.code				;CS register
main proc
	;initialize random number generator
	call Randomize

	;intro to the project

	;use fpu

	;procedure to choose difficulty
	call choose_difficulty

	;procedure to initialize mines
	push mine_count
	push board_size
	push OFFSET board
	call initialize_mines

	;procedure for the first turn procedure (can't lose on the first turn)
	push board_size
	push OFFSET board
	call first_turn

	;procedure for every other turn

	invoke ExitProcess,0
main endp



;procedure for choosing a difficulty.  The user will input 1-4, 1=easy, 2=medium, 3=hard, 4=rules.
;repeated until user has chosen a difficulty, at which point the difficulty, board_size and mine_count
;variables will be set as appropriate.
choose_difficulty proc
	jmp input

	;prints an error message when user enters an invalid input
	invalid_input:
		mov EDX, OFFSET prompt6
		call WriteString
		mov EAX, 4
		call WriteDec
		call Crlf

	;gets a user input
	input:
		;prints the prompts for game difficulties/rules
		mov EDX, OFFSET prompt1
		call Writestring
		call Crlf

		mov EDX, OFFSET prompt2
		call WriteString
		call Crlf

		mov EDX, OFFSET Prompt3
		call WriteString
		call Crlf

		mov EDX, OFFSET prompt4
		call WriteString
		call Crlf

		mov EDX, OFFSET prompt5
		call WriteString
		call Crlf

		;gets the user input for difficulty
		call ReadDec
		mov difficulty, EAX

		;if the user chooses 1, sets game to easy
		cmp EAX, 1
		je easy

		;if the user chooses 2, sets the game to medium
		cmp EAX, 2
		je medium

		;if the user chooses 3, sets the game to hard
		cmp EAX, 3
		je hard

		;if the user chooses 4, prints the rules and asks for another input
		cmp EAX, 4
		je rules

		;else, the user will be shown an error message and prompted for a new input
		jmp invalid_input

	;easy difficulty, 10x10 board w/ 12 mines
	easy:
		mov board_size, 10
		mov mine_count, 12
		ret

	;medium difficulty, 15x15 board w/ 35 mines
	medium:
		mov board_size, 15
		mov mine_count, 35
		ret

	;hard difficulty, 25x25 board w/ 100 mines
	hard:
		mov board_size, 25
		mov mine_count, 100
		ret

	;prints the rules and gets a new difficulty input after the user chooses to continue
	rules:
		;prints rules
		mov EDX, OFFSET rules1
		call WriteString

		mov EDX, OFFSET rules2
		call WriteString

		mov EDX, OFFSET rules3
		call WriteString
		call Crlf

		;prints a message waiting for the user to choose to continue
		mov EDX, OFFSET rules4
		call WriteString
		call Crlf

		;waits until user presses enter to continue
		call ReadDec

		;gets a new user input
		jmp input
choose_difficulty endp



initialize_mines proc
	;sets array and counter from values on stack
	push EBP
	mov EBP, ESP
	mov ECX, [EBP + 16]
	mov ESI, [EBP + 8]

	random_coords:
		;gets first random number
		mov EAX, [EBP + 12]
		call RandomRange
		inc EAX
		mov EBX, EAX

		;gets a second random number
		mov EAX, [EBP + 12]
		call RandomRange
		inc EAX

	check_coords:
		;checks if the location with the randomly generated coordinates has a mine.  If it does, a new set of 
		;coordinates is generated.  If there was no mine, the tile is set to be a mine and the loop is decremented
		imul EBX, 4
		imul EAX, 108
		add EAX, EBX
		mov EDX, [ESI + EAX]
		cmp EDX, 10
		je set_mine
		jmp random_coords

	set_mine:
		;sets the tile to a mine and loops to random_coords
		mov EDX, 9
		mov [ESI + EAX], EDX
		loop random_coords

	pop EBP
	ret 12
initialize_mines endp



;prints the board for the user to see.  Will use the 2D array and the max size (based on difficulty)
;to print each tile.  10 = unchecked tile = "-", 9 = unchecked mine = "-", 0-8 = checked tile (number
;of surrounding mines), 11 = flagged mine = "!", 12 = incorrectly flagged tile = "!"
print_board proc
	;sets parameters and counters
	push EBP
	mov EBP, ESP
	mov ECX, 1
	mov EAX, 1
	mov ESI, [EBP + 8]
	call Crlf
	call Crlf
	call Crlf
	mov EDX, OFFSET space
	call WriteString
	call WriteString
	call WriteString
	call WriteString

	;adds the numeric labels above each column
	label_columns:
		call WriteString
		call WriteDec
		cmp EAX, 10
		jl print_extra_space

	label_columns2:
		inc EAX
		cmp EAX, [EBP + 12]
		jle label_columns
		call Crlf
		call WriteString
		call WriteString
		call WriteString
		call WriteString
		mov EAX, 0

	;adds a line to seperate label from board
	add_line:
		mov EDX, OFFSET horizontal_line
		call WriteString
		inc EAX
		cmp EAX, [EBP + 12]
		jl add_line
		call Crlf

	L1:
		;reset inner loop counter
		mov EBX, 1

		;adds a numeric label to the left of each row
		jmp label_row

		l2:
			;finds the index of the array to print
			mov EAX, EBX
			imul EAX, 27
			add EAX, ECX
			shl EAX, 2

			;prints the number in the position
			mov EAX, [ESI + EAX]

			;prints dash for unchecked tiles
			cmp EAX, 9
			je print_dash
			cmp EAX, 10
			je print_dash

			;prints an exclaimation point for flagged tiles
			cmp EAX, 11
			jge print_exclaimation

			;else prints the number on the tile
			mov EDX, OFFSET space
			call WriteString
			call WriteDec
			call WriteString

		L3:
			;increments counter and checks break condition
			inc EBX
			cmp EBX, [EBP + 12]
			jle L2

		;prints an endline after every row
		call Crlf

		;increments counter and checks break condition
		inc ECX
		cmp ECX, [EBP + 12]
		jle L1


	pop EBP
	ret 8

	print_dash:
		mov EDX, OFFSET dash
		call WriteString
		jmp L3

	print_exclaimation:
		mov EDX, OFFSET exclaimation
		call WriteString
		jmp L3

	label_row:
		mov EAX, ECX
		call WriteDec

	print_spaces:
		mov EDX, OFFSET space
		call WriteString

		cmp EAX, 10
		mov EAX, 10
		jl print_spaces

	print_vertical_line:
		mov EDX, OFFSET vertical_line
		call WriteString
		jmp L2

	print_extra_space:
		call WriteString
		jmp label_columns2
print_board endp



;gets an input for a column or row.  [EBP + 8] = initial prompt, [EBP + 12] = invalid input prompt, [EBP + 16] = max size
get_user_input proc
	;sets parameters and counters
	push EBP
	mov EBP, ESP
	jmp get_input

	invalid_input:
		mov EDX, [EBP + 12]
		call WriteString
		call Crlf

	get_input:
		mov EDX, [EBP + 8]
		call WriteString
		call ReadInt

		cmp EAX, 1
		jl invalid_input

		cmp EAX, [EBP + 16]
		jg invalid_input

	pop EBP
	ret 12
get_user_input endp



first_turn proc
	push EBP
	mov EBP, ESP
	mov ESI, [EBP + 8]
	mov ECX, [EBP + 12]
	jmp start_first_turn

	reset_mines:
		;set all tiles back to 10
		mov EDI, EAX
		mov EDX, EBX
		push ESI
		call reset_board

		;generate new random mines
		push mine_count
		mov ECX, [EBP + 12]
		push ECX
		push ESI
		call initialize_mines

		;re-check for adjacent mines (repeated until first move is safe)
		mov EAX, EDI
		mov EBX, EDX
		jmp ensure_no_mines

	start_first_turn:
		;prints the starting board
		push board_size
		push OFFSET board
		call print_board

		;gets a user input for row
		push ECX
		push OFFSET prompt6
		push OFFSET prompt7
		call get_user_input
		mov EBX, EAX
		mov row, EAX

		;gets a user input for col
		push ECX
		push OFFSET prompt6
		push OFFSET prompt8
		call get_user_input
		mov col, EAX

	ensure_no_mines:
		mov EAX, row
		mov EBX, col
		push EAX
		push EBX
		push ESI
		call count_adjacent_mines
		cmp ECX, 0
		jne reset_mines

	;calls clear_tile on chosen space once there are no adjacent mines
	push 0
	push EAX
	push EBX
	push ESI
	call clear_tile

	;prints the starting board
	push board_size
	push OFFSET board
	call print_board

	pop EBP
	ret 8
first_turn endp



;counts all adjacent mines.  [EBP + 8] = board/array, [EBP + 12] = col of tile, [EBP + 16] = row of tile
count_adjacent_mines proc
	push EBP
	mov EBP, ESP
	mov ECX, 0				;inner loop counter
	mov EDX, 0				;outer loop counter
	mov EDI, 0				;counter for adjacent mines
	mov ESI, [EBP + 8]
	jmp check_tile

	add_mine:
		inc EDI
		jmp increment_counters

	check_tile:
		;sets EAX to the correct position of each tile to be checked
		mov EAX, [EBP + 12]
		mov EBX, [EBP + 16]
		sub EAX, 1
		sub EBX, 1
		add EAX, ECX
		add EBX, EDX
		imul EAX, 27
		add EAX, EBX
		shl EAX, 2

		;increments the counter if it is a mine
		mov EAX, [ESI + EAX]
		cmp EAX, 9
		je add_mine
		cmp EAX, 11
		je add_mine

	increment_counters:
		inc ECX
		cmp ECX, 3
		jl check_tile

		mov ECX, 0
		inc EDX
		cmp EDX, 3
		jl check_tile

	mov EAX, [EBP + 12]
	mov EBX, [EBP + 16]
	mov ECX, EDI

	pop EBP
	ret 12
count_adjacent_mines endp



;sets each space in the board back to 10
reset_board proc
	push EBP
	mov EBP, ESP
	mov ESI, [EBP + 8]
	mov EAX, 0
	mov EBX, 10

	mov ECX, 729

	reset_tile:
		mov [ESI + EAX], EBX
		add EAX, 4
		loop reset_tile

	pop EBP
	ret 4
reset_board endp



;clears a tile on the board, if it is a mine, the player loses, if it has adjacent mines, changes tile to the given number
;if the tile has a flag on it, it will print an error message, if the tile has already been cleared, it will clear all adjacent
;tiles that don't have a flag on it, and if there are no adjacent mines, it will clear all adjacent tiles.  [EBP + 8] = board,
;[EBP + 12] = row, [EBP + 16] = col, [EBP + 20] = whether the function was called recursively
clear_tile proc
	push EBP
	mov EBP, ESP

	;enforces upper and lower bounds
	mov EAX, [EBP + 12]
	mov EBX, [EBP + 16]
	cmp EAX, 1
	jl ending
	cmp EAX, board_size
	jg ending
	cmp EBX, 1
	jl ending
	cmp EBX, board_size
	jg ending

	;finds location to be cleared
	mov ESI, [EBP + 8]
	mov EAX, [EBP + 12]
	mov EBX, [EBP + 16]
	imul EBX, 27
	add EAX, EBX
	shl EAX, 2

	;checks if tile is 9/an unflagged mine
	mov ECX, 9
	cmp [ESI + EAX], ECX
	je clear_mine

	;checks if tile is 11 or 12, a flagged mine or a flagged non-mine tile
	mov ECX, 11
	cmp [ESI + EAX], ECX
	je clear_flag
	mov ECX, 12
	cmp [ESI + EAX], ECX
	je clear_flag

	;checks if tile has already been cleared
	mov ECX, 8
	cmp [ESI + EAX], ECX
	jle check_clear_adjacent
	;jle ending

	;counts the number of adjacent mines
	mov EAX, [EBP + 12]
	push EAX
	mov EBX, [EBP + 16]
	push EBX
	push ESI
	call count_adjacent_mines

	;sets the tile to the number of adjacent mines
	mov EAX, [EBP + 12]
	mov EBX, [EBP + 16]
	imul EBX, 27
	add EAX, EBX
	shl EAX, 2
	mov ESI, [EBP + 8]
	mov [ESI + EAX], ECX

	;clears adjacent tiles when there are no adjacent mines
	cmp ECX, 0
	jz clear_adjacent
	jmp ending

	;if the player tries to clear a mine, writes a loss message and ends program
	clear_mine:
		mov ECX, 0
		cmp [EBP + 20], ECX
		jnz ending

		mov EDX, OFFSET prompt9
		call WriteString
		invoke ExitProcess,0

	;if the player tries to clear a flagged tile, check if the function call was recursive
	clear_flag:
		mov ECX, 0
		cmp [EBP + 20], ECX
		jnz ending

		;if function call was not recursive, print error message
		mov EDX, OFFSET prompt11
		call WriteString
		jmp ending

	;checks if the function was called recursively, if it wasn't, calls this function for each adjacent tile
	check_clear_adjacent:
		mov ECX, 0
		cmp [EBP + 20], ECX
		jnz ending

	;calls clear_tile for each adjacent tile
	clear_adjacent:
		mov ECX, 0
		mov EDX, 0

	call_clear_adjacent:
		;decides what tile to call clear_tile for
		mov EAX, [EBP + 12]
		mov EBX, [EBP + 16]
		sub EAX, 1
		sub EBX, 1
		add EAX, ECX
		add EBX, EDX

		;saves counter registers
		push ECX
		push EDX

		;calls clear_tile for the applicable adjacent tile
		push 1
		push EBX
		push EAX
		push ESI
		call clear_tile

		;gets saved values from stack back to registers
		pop EDX
		pop ECX

		;increments counter for inner loop
		inc ECX
		cmp ECX, 3
		jl call_clear_adjacent

		;increments counter for outer loop
		inc EDX
		mov ECX, 0
		cmp EDX, 3
		jl call_clear_adjacent

	ending:
		pop EBP
		ret 16
clear_tile endp
end main
