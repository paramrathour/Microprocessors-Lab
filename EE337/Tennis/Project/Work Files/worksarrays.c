#include <at89c5131.h>
#include "lcd.h"									// Header file with LCD interfacing functions
#include "serial.c"									// C file with UART interfacing functions

code unsigned char dash = '-';
code unsigned char space = ' ';
unsigned char points[][2] = {'0','0', '1','5', '3','0', '4','0', 'A','d'};
unsigned char gameScores[][4] = {'0','-','0',' ','0','-','0',' ','0','-','0',' '};
unsigned int playerPoints[2];
unsigned int playerGames[2];
unsigned int playerSets[2];
unsigned int setNumber;
int tiebreak;
int i;

void reset(void);
void printTiebreakerPoints(unsigned int n);
int checkMatchWin(void);

void main(void){
	
	// ------------------------------- Call initialization functions
	lcd_init();
	uart_init();
	reset();
	
	while(1){

		unsigned char ch = 0;
										
		ch = receive_char();			// Receive a character
		transmit_char(ch);
		if (ch == 'r') {
			reset();
			continue;
		}
		
		if (tiebreak == 0) {
			if (ch == '1') {
				if (playerPoints[0] == 3) {
					if (playerPoints[1] < 3) {
						gameScores[setNumber - 1][0] += 1;
						playerGames[0]++;
						playerPoints[0] = 0;
						playerPoints[1] = 0;
					}
					else if (playerPoints[1] == 3) {
						playerPoints[0]++;
					}
					else if (playerPoints[1] == 4) {
						playerPoints[1]--;
					}
				}
				else if (playerPoints[0] == 4) {
					gameScores[setNumber - 1][0] += 1;
					playerGames[0]++;
					playerPoints[0] = 0;
					playerPoints[1] = 0;
				}
				else
					playerPoints[0]++;
			}
			else if (ch == '2') {
				if (playerPoints[1] == 3) {
					if (playerPoints[0] < 3) {
						gameScores[setNumber - 1][2] += 1;
						playerGames[1]++;
						playerPoints[1] = 0;
						playerPoints[0] = 0;
					}
					else if (playerPoints[0] == 3) {
						playerPoints[1]++;
					}
					else if (playerPoints[0] == 4) {
						playerPoints[0]--;
					}
				}
				else if (playerPoints[1] == 4) {
					gameScores[setNumber - 1][2] += 1;
					playerGames[1]++;
					playerPoints[0] = 0;
					playerPoints[1] = 0;
				}
				else
					playerPoints[1]++;
			}
			else
				transmit_string("Wrong key pressed!\n");

			if (playerGames[0] >= 6 || playerGames[1] >= 6){
				if (playerGames[0] >= playerGames[1] + 2){
					playerSets[0]++;
					playerGames[0] = 0;
					playerGames[1] = 0;
					if (checkMatchWin() == 0)
						setNumber++;
					else
						continue;
				}
				else if (playerGames[1] >= playerGames[0] + 2){
					playerSets[1]++;
					playerGames[0] = 0;
					playerGames[1] = 0;
					if (checkMatchWin() == 0)
						setNumber++;
					else
						continue;
				}
				else if (playerGames[0] == playerGames[1]){
					tiebreak = 1;
					playerPoints[0] = 0;
					playerPoints[1] = 0;
				}
			}
			lcd_cmd(0x80);										// Move cursor to 1st line of LCD
			for (i = 0; i < setNumber; ++i)
			{
				lcd_write_char(gameScores[i][0]);
				lcd_write_char(gameScores[i][1]);
				lcd_write_char(gameScores[i][2]);
				lcd_write_char(gameScores[i][3]);
			}
			lcd_cmd(0xC0);										// Move cursor to 2nd line of LCD
			lcd_write_char(points[playerPoints[0]][0]);
			if (playerPoints[0] != 0)
				lcd_write_char(points[playerPoints[0]][1]);
			lcd_write_char(dash);
			lcd_write_char(points[playerPoints[1]][0]);
			if (playerPoints[1] != 0)
				lcd_write_char(points[playerPoints[1]][1]);

			lcd_write_char(space);
			lcd_write_char(space);
		}

		else {													// tiebreak = 1
			if (ch == '1') 
				playerPoints[0]++;
			else if (ch == '2') 
				playerPoints[1]++;
			else
				transmit_string("Wrong key pressed!\n");

			if (playerPoints[0] >= 7 || playerPoints[1] >= 7) {
				if (playerPoints[0] >= playerPoints[1] + 2) {
					gameScores[setNumber - 1][0] += 1;
					playerGames[0]++;
					playerSets[0]++;
					tiebreak = 0;
				}
				else if (playerPoints[1] >= playerPoints[0] + 2) {
					gameScores[setNumber - 1][2] += 1;
					playerGames[1]++;
					playerSets[1]++;
					tiebreak = 0;
				}
			}

			if (tiebreak == 0) {
				if (checkMatchWin() == 0)
					setNumber++;
				else
					continue;
				playerPoints[0] = 0;
				playerPoints[1] = 0;
				playerGames[0] = 0;
				playerGames[1] = 0;
			}

			lcd_cmd(0x80);										// Move cursor to 1st line of LCD
			for (i = 0; i < setNumber; ++i)
			{
				lcd_write_char(gameScores[i][0]);
				lcd_write_char(gameScores[i][1]);
				lcd_write_char(gameScores[i][2]);
				lcd_write_char(gameScores[i][3]);
			}
			lcd_cmd(0xC0);										// Move cursor to 2nd line of LCD
			printTiebreakerPoints(playerPoints[0]);
			lcd_write_char(dash);
			printTiebreakerPoints(playerPoints[1]);
			lcd_write_char(space);
			lcd_write_char(space);
		}

	}
}

void reset(void){
	gameScores[0][0] = '0', gameScores[0][2] = '0';
	gameScores[1][0] = '0', gameScores[1][2] = '0';
	gameScores[2][0] = '0', gameScores[2][2] = '0';

	playerPoints[0] = 0, playerPoints[1] = 0;
	
	playerGames[0] = 0, playerGames[1] = 0;

	playerSets[0] = 0, playerSets[1] = 0;
	
	setNumber = 1;
	
	tiebreak = 0;
	
	transmit_string("\nTennis Scoreboard Simulator\n");	// These strings will be printed in terminal software
	lcd_clear();
	lcd_cmd(0x80);										// Move cursor to 1st line of LCD
	lcd_write_string("0-0");
	lcd_cmd(0xC0);										// Move cursor to 2nd line of LCD
	lcd_write_string("0-0");
}

void printTiebreakerPoints(unsigned int n){
	if (n < 10) {
		lcd_write_char(48 + n);
	}
	else {
		lcd_write_char(48 + n / 10);
		lcd_write_char(48 + n % 10);
	}
}

int checkMatchWin(void){
	if (playerSets[0] == 2){
		transmit_string("\nP1 Wins\n");
		lcd_clear();
		lcd_cmd(0x80);										// Move cursor to 1st line of LCD
		lcd_write_string("P1 Wins");
		msdelay(5000);
		reset();
		return 1;
	}
	else if (playerSets[1] == 2){
		transmit_string("\nP2 Wins\n");
		lcd_clear();
		lcd_cmd(0x80);										// Move cursor to 1st line of LCD
		lcd_write_string("P2 Wins");
		msdelay(5000);
		reset();
		return 1;
	}
	return 0;
}