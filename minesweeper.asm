;minesweeper.asm		Title:		Names:

INCLUDE Irvine32.inc

.386
.model flat,stdcall
.stack 4096			;SS register
ExitProcess proto,dwExitCode:dword

.data				;DS register
	;rules to the game
	rules1		BYTE	"Each tile either contains a mine, or a number. Your goal is to flag each tile containing a mine and clear each tile that doesn't. Tiles showing ", 34, "-", 34, " have not been checked, tiles",0
	rules2		BYTE	"showing ", 34, "!", 34, " have been flagged as having a mine, and showing a number show you the total number of mines in adjacent tiles (including diagonals). You must use these numbers to ",0
	rules3		BYTE	"deduce the locations of all mines to win. If you clear a tile that shows a number on it, all adjacent non-flagged tiles will be cleared.",0
	rules4		BYTE	"Press <enter> to continue",0

	;board size (based on chosen difficulty)
	prompt1		BYTE	"Choose a Difficulty:",0
	prompt2		BYTE	"	1. Easy",0
	prompt3		BYTE	"	2. Medium",0
	prompt4		BYTE	"	3. Difficult",0
	prompt5		BYTE	"	4. Rules",0
	prompt6		BYTE	"Invalid input (1-4)",0
	difficulty	DWORD	?
	board_size	DWORD	?
	mine_count	DWORD	?

	;2D 27x27m array defaulted to all 10s (unchecked non-mine tiles)
	board		DWORD	27 DUP(27 DUP(10))

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
end main
