#include <at89c5131.h>
#include "lcd.h"							// Header file with LCD interfacing functions
#include "serial.c"							// C file with UART interfacing functions

// -------------------------- (char) Variables helpful in printing to LCD ------- //
code unsigned char dash = '-';				// Dash
code unsigned char space = ' ';				// Space
code unsigned char gamePoint = 'G';			// Game Point
code unsigned char setPoint = 'S';			// Set Point
code unsigned char matchPoint = 'M';		// Match Point
unsigned char threeSpaces[4] = {' ',' ',' ','\0'};	// 3 spaces
											// 2D array, stores points in each row
											// Index 0 -> Point 0, 1 -> 15, 2 -> 30, 3 -> 40, 4 -> Ad
unsigned char points[][2] = {'0','0', '1','5', '3','0', '4','0', 'A','d'};	
											// 2D array, ith row stores ith set score
											// Index i -> "0-0 " for i = 0, 1, 2
unsigned char gameScores[][4] = {'0','-','0',' ','0','-','0',' ','0','-','0',' '};

// -------------------------- Variables Declaration ----------------------------- //
											// Index 0, 1 for Player 1, 2 respectively
unsigned int playerPoints[2];				// Size 2 array, each player's current earned points (0 to 4)
unsigned int playerGames[2];				// Size 2 array, each player's current earned games (0 to 7)
unsigned int playerSets[2];					// Size 2 array, each player's current earned sets (0 to 4)
unsigned int setNumber;						// Current set number
unsigned int tiebreak;						// Set to 1 IF current set is tiebreak ELSE 0
unsigned int row;							// Index for loop in printSets()
unsigned int Lines[2] = {0x8D, 0xCD};		// Size 2 array, stores 14th column of each line

// -------------------------- Functions Declaration ----------------------------- //
void reset(void);							// Resets game
void updateGames(unsigned char ch);			// Updates points and games at each point
void updateSets(unsigned int i);			// Updates sets and games when a set is completed
void tiebreakOverflow(void);				// Handles case when tiebreaker points overflows to 3 digits
void updateSetTiebreaker(unsigned int i);	// Updates sets when tiebreaker is completed
unsigned char checkMatchWin(void);			// Checks IF match is finished & display winner ELSE returns 0
void printSets(void);						// Prints 1st Line 
void printPointsNonTiebreaker(void);		// Prints 2nd Line when no tiebreaker
void printPointsTiebreaker(void);			// Prints 2nd Line when tiebreaker
void print2digitnumber(unsigned int n);		// Helper function for printPointsTiebreaker()
void printWinner(unsigned char ch);			// Prints winner of match
void showInstructions(void);				// Show instructions
void printPoints(unsigned int i, unsigned int j);				// Checks and Displays Points
unsigned char checkGamePoint(unsigned int i, unsigned int j);	// Checks Game Point
unsigned char checkSetPoint(unsigned int i, unsigned int j);	// Checks Set Point
unsigned char checkMatchPoint(unsigned int i);					// Checks Match Point

void main(void){
	
// -------------------------- Initialization ----------------------------- //
	LCDInit();								// Initialise LCD
	UARTInit();								// Initialise UART
	reset();								// Initialise Variables
	showInstructions();

	while(1){

		unsigned char ch = 0;
										
		ch = ReceiveChar();					// Receive a character
		TransmitChar(ch);					// Send it back to terminal software
		if (ch == 'r' || ch == 'R') {		// Reset game
			TransmitString("\nResetting...");
			reset();
			continue;
		}
		if (ch == 'i' || ch == 'I') {		// Show Instructions
			showInstructions();
			continue;
		}
		
		if (tiebreak == 0) {									// No Tiebreak case
			if (ch == '1' || ch == '2') {
				updateGames(ch);
			}
			else
				TransmitString("\nWrong key pressed!\n");

			if (playerGames[0] >= 6 || playerGames[1] >= 6){	// Condition for updateSets()
				if (playerGames[0] >= playerGames[1] + 2){
					updateSets(0);								// Player 1 wins the set
					if (checkMatchWin() == 'N')
						setNumber++;							// Increment current set IF match not done
					else
						continue;								// Start over IF match done
				}
				else if (playerGames[1] >= playerGames[0] + 2){
					updateSets(1);								// Player 2 wins the set
					if (checkMatchWin() == 'N')
						setNumber++;							// Increment current set IF match not done
					else
						continue;								// Start over IF match done
				}
				else if (playerGames[0] == playerGames[1]){		// Next set is Tiebreak
					tiebreak = 1;								// Tiebreak Mode ON
					playerPoints[0] = 0, playerPoints[1] = 0; 	// Reset current points
				}
			}
			printSets();										// Prints 1st Line
			printPointsNonTiebreaker();							// Prints 2nd Line
			if (checkGamePoint(0,1) == 'Y')						// Prints GSM Points
				printPoints(0,1);
			else
				printPoints(1,0);
		}

		else {													// Tiebreak case
			if (ch == '1')
				playerPoints[0]++;								// Increase Points for Player 1
			else if (ch == '2') 
				playerPoints[1]++;								// Increase Points for Player 2
			else
				TransmitString("\nWrong key pressed!\n");
			tiebreakOverflow();
			if (playerPoints[0] >= 7 || playerPoints[1] >= 7) {	// Check for winner of tiebreaker set
				if (playerPoints[0] >= playerPoints[1] + 2)
					updateSetTiebreaker(0);						// IF Player 1 wins tiebreaker
				else if (playerPoints[1] >= playerPoints[0] + 2)
					updateSetTiebreaker(1);						// IF Player 2 wins tiebreaker
			}

			if (tiebreak == 0) {								// IF tiebreak ends
				if (checkMatchWin() == 'N'){
					setNumber++;								// Increment current set IF match not done
					playerPoints[0] = 0, playerPoints[1] = 0;	// Reset current points
					playerGames[0] = 0, playerGames[1] = 0;		// Reset current games
				}
				else
					continue;									// Increment current set IF match not done
			}
			printSets();										// Prints 1st Line
			printPointsTiebreaker();							// Prints 2nd Line
			if (checkGamePoint(0,1) == 'Y')						// Prints GSM Points
				printPoints(0,1);
			else
				printPoints(1,0);
		}
	}
}

void reset(void){
	gameScores[0][0] = '0', gameScores[0][2] = '0';				// Resets gameScores
	gameScores[1][0] = '0', gameScores[1][2] = '0';
	gameScores[2][0] = '0', gameScores[2][2] = '0';
	playerPoints[0] = 0, playerPoints[1] = 0;					// Resets playerPoints
	playerGames[0] = 0, playerGames[1] = 0;						// Resets playerGames
	playerSets[0] = 0, playerSets[1] = 0;						// Resets playerSets
	setNumber = 1;												// First Set
	tiebreak = 0;												// Tiebreak Mode OFF
	
	TransmitString("\nTennis Scoreboard Simulator\n");			// Print Welcome Screen in terminal
	LCDCmd(0x80);												// Move cursor to 1st line of LCD
	LCDWriteString("TennisScoreboard");							// Print Welcome Screen in LCD
	LCDCmd(0xC0);												// Move cursor to 2nd line of LCD
	LCDWriteString("   Simulator");								// Print Welcome Screen in LCD
	msDelay(2000);
	LCDClear();
	LCDCmd(0x80);												// Move cursor to 1st line of LCD
	LCDWriteString("0-0");										// Initial score
	LCDCmd(0xC0);												// Move cursor to 2nd line of LCD
	LCDWriteString("0-0");										// Initial points
}

void updateGames(unsigned char ch){
	unsigned int player = (int) ch - 48;
	unsigned int i = player - 1;								// i = index of current point winner
	unsigned int j = 1 - i;										// j = index of current point loser
	
	if (playerPoints[i] == 3) {									// Player i at 40
		if (playerPoints[j] < 3) {								// Player j at 0, 15, 30. Game done
			gameScores[setNumber - 1][2*i] += 1;				// Update gameScores
			playerGames[i]++;									// Update Player i games
			playerPoints[i] = 0, playerPoints[j] = 0;			// Resets playerPoints
		}
		else if (playerPoints[j] == 3) {						// Player j at 40
			playerPoints[i]++;									// Player i increses to Ad
		}
		else if (playerPoints[j] == 4) {						// Player j at Ad
			playerPoints[j]--;									// Player j reduces to 40
		}
	}
	else if (playerPoints[i] == 4) {							// Player i at Ad. Game done
		gameScores[setNumber - 1][2*i] += 1;					// Update gameScores 
		playerGames[i]++;										// Update Player i games
		playerPoints[i] = 0, playerPoints[j] = 0;				// Resets playerPoints
	}
	else														// Player i at 0, 15, 30
		playerPoints[i]++;										// Update Player i points
}

void updateSets(unsigned int i){
																// i = index of current set winner
	unsigned int j = 1 - i;										// j = index of current set loser
	playerSets[i]++;											// Update Player i sets
	playerGames[i] = 0, playerGames[j] = 0;						// Resets playerGames
}

void tiebreakOverflow(void){
	if (playerPoints[0] == 100 && playerPoints[1] == 98) {		// Equivalent to (7,5)
																// as Player 2 already lost this set
		playerPoints[0] = 7; playerPoints[1] = 5;
	}
	else if (playerPoints[0] == 100 && playerPoints[1] == 99) { // Equivalent to (7,6)
		playerPoints[0] = 7; playerPoints[1] = 6;
	}
	else if (playerPoints[0] == 98 && playerPoints[1] == 100) {	// Equivalent to (5,7)
																// as Player 1 already lost this set
		playerPoints[0] = 5; playerPoints[1] = 7;
	}
	else if (playerPoints[0] == 99 && playerPoints[1] == 100) {	// Equivalent to (6,7)
		playerPoints[0] = 6; playerPoints[1] = 7;
	}
}

void updateSetTiebreaker(unsigned int i){
																// i = index of tiebreaker winner
	unsigned int j = 1 - i;										// j = index of tiebreaker loser
	gameScores[setNumber - 1][2*i] += 1;						// Update gameScores
	playerGames[i]++;											// Update Player i games
	playerSets[i]++;											// Update Player i sets
	tiebreak = 0;												// Tiebreak Mode OFF
}

unsigned char checkMatchWin(void){
	unsigned char winner;
	if (playerSets[0] == 2 || playerSets[1] == 2){				// IF winner exists
		if (playerSets[0] == 2){
			winner = '1';										// Player 1 is winner
			printWinner('1');
		}
		else if (playerSets[1] == 2){
			winner = '2';										// Player 2 is winner
			printWinner('2');
		}
		msDelay(5000);											// Wait for 5 seconds
		reset();												// Reset Game
		return 'Y';
	}
	else
		return 'N';
}

void printSets(void){
	LCDCmd(0x80);												// Move cursor to 1st line of LCD
	// Prints 1st $setNumber rows of gameScores, setNumber= 1->"0-0 ", 2->"0-0 0-0 ", 3->"0-0 0-0 0-0 "
	for (row = 0; row < setNumber; ++row){
		LCDWriteChar(gameScores[row][0]);
		LCDWriteChar(gameScores[row][1]);
		LCDWriteChar(gameScores[row][2]);
		LCDWriteChar(gameScores[row][3]);
	}
}

void printPointsNonTiebreaker(void){
	LCDCmd(0xC0);												// Move cursor to 2nd line of LCD
	LCDWriteChar(points[playerPoints[0]][0]);
	if (playerPoints[0] != 0)									// Prints second char IF points NOT 0
		LCDWriteChar(points[playerPoints[0]][1]);
	LCDWriteChar(dash);											// Prints dash
	LCDWriteChar(points[playerPoints[1]][0]);
	if (playerPoints[1] != 0)									// Prints second char IF points NOT 0
		LCDWriteChar(points[playerPoints[1]][1]);

	// Overwrite score IF any at (4th, 5th) OR (5th) column when no. of chars printed are 3,4 respectively
	// Examples i) 40-30 to 0-0, ii) 40-0, to 0-0
	LCDWriteChar(space);									// Prints space
	LCDWriteChar(space);									// Prints space
}

void print2digitnumber(unsigned int n){
	if (n < 10) {
		LCDWriteChar(48 + n);									// Print single digit number
	}
	else {
		LCDWriteChar(48 + n / 10);								// Print ten's digit
		LCDWriteChar(48 + n % 10);								// Print units's digit
	}
}

void printPointsTiebreaker(void){
	LCDCmd(0xC0);												// Move cursor to 2nd line of LCD
	print2digitnumber(playerPoints[0]);							// Print points of Player 1
	LCDWriteChar(dash);											// Print dash
	print2digitnumber(playerPoints[1]);							// Print points of Player 2

	// Overwrite score IF any at (4th, 5th) OR (5th) column when no. of chars printed are 3,4 respectively
	// Examples i) 40-30 to 0-0, ii) 40-0, to 0-0
	LCDWriteChar(space);										// Prints space
	LCDWriteChar(space);										// Prints space
}

void printWinner(unsigned char ch){
// -------------------------- Print winner on Terminal ----------------------------- //
	TransmitString("\nP");
	TransmitChar(ch);
	TransmitString(" wins\n");

// -------------------------- Print winner on LCD ----------------------------- //
	printSets();												// Prints 1st Line
	
	LCDCmd(Lines[0]);											// Move cursor to 14th column of 1st line of LCD
	LCDWriteString(threeSpaces);
	LCDCmd(Lines[1]);											// Move cursor to 14th column of 2nd line of LCD
	LCDWriteString(threeSpaces);
	
	LCDCmd(0xC0);												// Move cursor to 2nd line of LCD
	LCDWriteString("P");
	LCDWriteChar(ch);
	LCDWriteString(" wins");

	LCDCmd(0xCD);												// To clear points
	LCDWriteString(threeSpaces);
}

void printPoints(unsigned int i, unsigned int j){
	LCDCmd(Lines[i]);									// Move cursor to ith column of LCD
	if (checkGamePoint(i,j) == 'Y') {
		LCDWriteChar(gamePoint);
		if (checkSetPoint(i,j) == 'Y') {
			LCDWriteChar(setPoint);
			if (checkMatchPoint(i) == 'Y') {
				LCDWriteChar(matchPoint);
			}
			else
				LCDWriteChar(space);
		}
		else{
			LCDWriteChar(space);
			LCDWriteChar(space);
		}
	}
	else
		LCDWriteString(threeSpaces);
	
	LCDCmd(Lines[j]);										// Move cursor to jth column of LCD
	LCDWriteString(threeSpaces);
}

unsigned char checkGamePoint(unsigned int i, unsigned int j){
	if (((tiebreak == 0 && (playerPoints[i] >= 3)) || tiebreak == 1 && playerPoints[i] >= 6) && (playerPoints[i] > playerPoints[j])) 
		return 'Y';
	else
		return 'N';
}

unsigned char checkSetPoint(unsigned int i, unsigned int j){  // checkGamePoint(i,j) should be Y
	if ((playerGames[i] == 6 && playerGames[i] - playerGames[j] <= 1) || (playerGames[i] == 5 && playerGames[i] >= playerGames[j] + 1)) 
		return 'Y';
	else
		return 'N';
}

unsigned char checkMatchPoint(unsigned int i){				 // checkSetPoint(i) should be Y
	if (playerSets[i] == 1)
		return 'Y';
	else
		return 'N';
}

void showInstructions(void){
// -------------------------- Print Instructions on Terminal ---------------------- //
	TransmitString("\nPress `1' if Player 1 wins the point");
	TransmitString("\nPress `2' if Player 2 wins the point");
	TransmitString("\nPress `r' or `R' to reset game");
	TransmitString("\nPress `i' or `I' for these instructions\n");
}