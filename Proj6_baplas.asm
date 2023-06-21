TITLE Proj6_baplas     (template.asm)

; Author: Simran Bapla
; Last Modified:
; OSU email address: baplas@oregonstate.edu
; Course number/section:   CS271 Section 401
; Project Number:6                 Due Date: August 12, 2022
; Description: provide 10 signed decimal integers
;			   Each number needs to be small enough to fit inside a 32 bit register. After you have finished inputting the raw numbers it will display a list of the
;			   integers, their sum, and their average value.

INCLUDE Irvine32.inc
; Name: mGetString
; user enters a string and it stores the string at the offset of stringOffset and the bytes read in the offset of bytesReadOffset
; preconditions: none
; Recieves: promptOffset = address of prompt
;			stringOffset = address where you would like to store string
;			maxStringLength = max possible string length (value)
;			byteReadOffset	= address to store the amount of bytes read
; Returns: string in [stringOffset], bytes read in [bytesReadOffset]
mGetString	MACRO	promptOffset, stringOffset, maxStringLength, bytesReadOffset
	PUSH	EDX
	PUSH	ECX
	PUSH	EAX

	MOV		EDX, promptOffset
	CALL	WriteString

	MOV		EDX, stringOffset
	MOV		ECX, maxStringLength
	CALL	ReadString

	MOV		[bytesReadOffset], EAX

	POP		EAX
	POP		ECX
	POP		EDX

ENDM

; Name: mDisplayString
; displays a string given the string offset
; preconditions: none
; Recieves: stringOffset = offset of string you would like to print
; Returns: prints the string
mDisplayString	MACRO	stringOffset
	PUSH	EDX

	MOV		EDX, stringOffset
	CALL	WriteString

	POP		EDX

ENDM

MAXSIZE = 100

.data
progName		BYTE	"PROGRAMMING ASSIGNMENT 6: Designing low-level I/O procedures",13,10,"Written by Simran Bapla",13,10,13,10,0
introduction	BYTE	"Please provide 10 signed decimal integers",13,10,0
introduction2	BYTE	"Each number needs to be small enough to fit inside a 32 bit register. After you have finished inputting the raw numbers I will display a list of the ",0
introduction3	BYTE	"integers, their sum, and their average value.",13,10,0
message			BYTE	"You entered the following numbers:",13,10,0
message2		BYTE	"The sum of these numbers is: ",0
message3		BYTE	"The truncated average is: ",0
message4		BYTE	"Thanks for playing!",13,10,0
space			BYTE	" ",0
finalArray		SDWORD	10		DUP(?)
prompt			BYTE	"Enter a signed number: ",0
usrString		BYTE	MAXSIZE + 1	DUP(0)
sLen			DWORD	?
value			SDWORD	?
errorMsg		BYTE	"ERROR: you did not enter a signed number or your number was too big.",13,10,0
arrayOfNums		BYTE	MAXSIZE DUP(?)
dispString		BYTE	MAXSIZE DUP(0)


.code
main PROC
	
	MOV		EDX, OFFSET progName
	CALL	WriteString
	MOV		EDX, OFFSET introduction
	CALL	WriteString
	MOV		EDX, OFFSET introduction2
	CALL	WriteString
	MOV		EDX, OFFSET introduction3
	CALL	WriteString
	CALL	CrLf

	MOV		EDI, OFFSET finalArray
	MOV		ECX, 10

_readingLoop:
	PUSH	OFFSET	errorMsg
	PUSH	OFFSET	value
	PUSH	OFFSET	sLen
	PUSH	OFFSET	usrString
	PUSH	OFFSET prompt
	CALL	ReadVal
	MOV		EAX, value
	MOV		[EDI], EAX
	ADD		EDI, TYPE finalArray
	LOOP	_readingLoop


	MOV		ESI, OFFSET finalArray
	MOV		ECX, 10

	MOV		EDX, OFFSET message
	CALL	WriteString

_writingAllValues:
	PUSH	OFFSET	dispString
	PUSH	OFFSET arrayOfNums
	PUSH	[ESI]
	CALL	WriteVal
	ADD		ESI, TYPE finalArray
	MOV		EDX, OFFSET space
	CALL	WriteString
	LOOP	_writingAllValues

	CALL	CrLf
	MOV		EDX, OFFSET message2
	CALL	WriteString
	MOV		ECX, 10
	MOV		EAX, 0

	MOV		ESI, OFFSET finalArray
_sumLoop:
	ADD		EAX, [ESI]
	ADD		ESI, TYPE finalArray
	LOOP	_sumLoop

	PUSH	OFFSET	dispString
	PUSH	OFFSET arrayOfNums
	PUSH	EAX
	CALL	WriteVal
	CALL	CrLf

	MOV		EBX, 10
	MOV		EDX, 0
	DIV		EBX
	
	MOV		EDX, OFFSET message3
	CALL	WriteString

	PUSH	OFFSET	dispString
	PUSH	OFFSET arrayOfNums
	PUSH	EAX
	CALL	WriteVal
	CALL	CrLf

	MOV		EDX, OFFSET message4
	CALL	WriteString


	Invoke ExitProcess,0	; exit to operating system
main ENDP

; Name: WriteVal
; given a SDWORD it converts it to a string and prints using mDisplayString
; Preconditions: none
; Postconditions: none
; Recieves:
;			[EBP + 8] = value
;			[EBP + 12] = offset of arrayOfNums 
;			[EBP + 16] = offset of global variable we print string into
;Returns: prints value as a string using mDisplayString
WriteVal PROC
	LOCAL	sign:DWORD


	PUSH	EAX
	PUSH	EDX
	PUSH	ECX
	PUSH	EBX
	PUSH	ESI
	PUSH	EDI
	

	MOV		sign, 0

	MOV		EAX, [EBP + 8]
	MOV		ESI, [EBP + 12]
	MOV		EDI, [EBP + 16]
	MOV		ECX, MAXSIZE				

	MOV		EBX, 0

_loop0:
	MOV		[EDI], EBX
	ADD		EDI, 1
	LOOP	_loop0

	MOV		EDI, [EBP + 16]
	MOV		ECX, 0

	CMP		EAX, 0
	JGE		_loop1

	MOV		EBX, EAX
	IMUL	EAX, EBX, -1
	MOV		sign, 1

_loop1:

	MOV		EDX, 0
	MOV		EBX, 10
	DIV		EBX				; EAX = value, EDX = remainder
	MOV		[ESI], EDX
	INC		ESI
	INC		ECX
	CMP		EAX, 0
	JE		_end
	JMP		_loop1

_end:
	DEC		ESI
	MOV		EAX, 0
	CMP		sign, 1
	JNE		_loop2

	MOV		AL, "-"
	CLD
	STOSB


_loop2:
	STD
	LODSB
	DEC		ECX
	ADD		AL, 48
	CLD
	STOSB
	CMP		ECX, 0
	JNE		_loop2

	MOV		EDI, [EBP + 16]
	mDisplayString	EDI



	POP		EDI
	POP		ESI
	POP		EBX
	POP		ECX
	POP		EDX
	POP		EAX




	RET		12

WriteVal ENDP




; Name: ReadVal
; reads value as a string converts it to a signed DWORD and stores it in value global variable
; Preconditions: None
; Postconditions: None
; Receives: [EBP + 24] = address of errorMsg
;			[EBP + 20] = address of variable that stores the value
;			[EBP + 16] = address of sLen
;			[EBP + 12] = address of usrString
;           [EBP + 8] = address of prompt
; Returns:  The value as a signed DWORD in value global variable
ReadVal	PROC

	PUSH	EBP
	MOV		EBP, ESP

	PUSH	EAX
	PUSH	EBX
	PUSH	EDX
	PUSH	ECX
	PUSH	ESI
	PUSH	EDI

_start:	
	mGetString	[EBP + 8], [EBP + 12], MAXSIZE, [EBP + 16]

	MOV		ESI, [EBP + 12]
	MOV		EBX, 0				
	MOV		ECX, [[EBP + 16]]

	CLD
	LODSB
	CMP		AL, '-'
	JE		_negativeValue
	CMP		AL, '+'
	JE		_positiveValueWithPositiveSign
	CMP		AL, 48
	JL		_error
	CMP		AL, 57
	JG		_error
	JMP		_positiveValue


_negativeValue:
	CLD
	LODSB
	MOV		EDX, 0
	DEC		ECX
	CMP		ECX, 0
	JE		_end
	CMP		AL, 48
	JL		_error
	CMP		AL, 57
	JG		_error
	SUB		AL, 48
	MOV		DL, AL
	IMUL	EAX, EBX, 10
	JO		_error
	MOV		EBX, EAX
	SUB		EBX, EDX
	JO		_error
	JMP		_negativeValue
	JMP		_end

_positiveValueWithPositiveSign:
	CLD
	LODSB
	MOV		EDX, 0
	DEC		ECX
	CMP		ECX, 0
	JE		_end
	CMP		AL, 48
	JL		_error
	CMP		AL, 57
	JG		_error
	SUB		AL, 48
	MOV		DL, AL
	IMUL	EAX, EBX, 10
	JO		_error
	MOV		EBX, EAX
	ADD		EBX, EDX
	JO		_error
	JMP		_positiveValueWithPositiveSign
	JMP		_end

_positiveValue:
	MOV		EDX, 0
	CMP		AL, 48
	JL		_error
	CMP		AL, 57
	JG		_error
	SUB		AL, 48
	MOV		DL, AL
	IMUL	EAX, EBX, 10
	JO		_error
	MOV		EBX, EAX
	ADD		EBX, EDX
	JO		_error
	CLD
	LODSB
	DEC		ECX
	CMP		ECX, 0
	JE		_end
	JMP		_positiveValue
	JMP		_end
 
_error:
	mDisplayString	[EBP + 24]
	JMP		_start

	

 _end:
	MOV		EDI, [EBP + 20]
	MOV		[EDI], EBX

	POP		EDI
	POP		ESI
	POP		ECX
	POP		EDX
	POP		EBX
	POP		EAX
	POP		EBP

	RET		20

ReadVal	ENDP

END main
