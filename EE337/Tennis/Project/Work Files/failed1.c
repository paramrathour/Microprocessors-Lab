failed

#include <at89c5131.h>
#include "lcd.h"									// Header file with LCD interfacing functions
#include "serial.c"									// C file with UART interfacing functions

code unsigned char dash = '-';
code unsigned char space = ' ';
unsigned char points[][2] = {'0','0', '1','5', '3','0', '4','0', 'A','d'};
unsigned char gameScores[] = {'0','-','0',' ','0','-','0',' ','0','-','0','\0'};
unsigned int player1Points, player2Points;
unsigned int player1Games, player2Games;
unsigned int player1Sets, player2Sets;
int setNumber;
int tiebreak;
int spaces;

void reset(void){
	gameScores[0] = '0';
	gameScores[2] = '0';
	gameScores[4] = '0';
	gameScores[6] = '0';
	gameScores[8] = '0';
	gameScores[10] = '0';

	player1Points = 0;
	player2Points = 0;
	
	player1Games = 0;
	player2Games = 0;

	player1Sets = 0;
	player2Sets = 0;
	
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

int checkMatch(void){
	if (player1Sets == 2){
		transmit_string("\nP1 Wins\n");
		lcd_clear();
		lcd_cmd(0x80);										// Move cursor to 1st line of LCD
		lcd_write_string("P1 Wins");
		msdelay(5000);
		reset();
		return 1;
	}
	else if (player2Sets == 2){
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
				if (player1Points == 3) {
					if (player2Points < 3) {
						gameScores[4 * setNumber - 4] += 1;
						player1Games++;
						player1Points = 0;
						player2Points = 0;
					}
					else if (player2Points == 3) {
						player1Points++;
					}
					else if (player2Points == 4) {
						player2Points--;
					}
				}
				else if (player1Points == 4) {
					gameScores[4 * setNumber - 4] += 1;
					player1Games++;
					player1Points = 0;
					player2Points = 0;
				}
				else
					player1Points++;
			}
			else if (ch == '2') {
				if (player2Points == 3) {
					if (player1Points < 3) {
						gameScores[4 * setNumber - 2] += 1;
						player2Games++;
						player2Points = 0;
						player1Points = 0;
					}
					else if (player1Points == 3) {
						player2Points++;
					}
					else if (player1Points == 4) {
						player1Points--;
					}
				}
				else if (player2Points == 4) {
					gameScores[4 * setNumber - 2] += 1;
					player2Games++;
					player1Points = 0;
					player2Points = 0;
				}
				else
					player2Points++;
			}
			else
				transmit_string("Wrong key pressed!\n");

			if (player1Games >= 6 || player2Games >= 6){
				if (player1Games >= player2Games + 2){
					player1Sets++;
					player1Games = 0;
					player2Games = 0;
					if (checkMatch() == 0)
						setNumber++;
					else
						continue;
				}
				else if (player2Games >= player1Games + 2){
					player2Sets++;
					player1Games = 0;
					player2Games = 0;
					if (checkMatch() == 0)
						setNumber++;
					else
						continue;
				}
				else if (player1Games == player2Games){
					tiebreak = 1;
					player1Points = 0;
					player2Points = 0;
				}
			}
			//lcd_cmd(0x80 + 4 * setNumber - 4);										// Move cursor to 1st line of LCD
			//lcd_write_fix_string(gameScores, (4 * setNumber) - 1);
			lcd_write_string(gameScores);
			lcd_cmd(0xC0);										// Move cursor to 2nd line of LCD
			lcd_write_char(points[player1Points][0]);
			if (player1Points != 0)
				lcd_write_char(points[player1Points][1]);
			lcd_write_char(dash);
			lcd_write_char(points[player2Points][0]);
			if (player2Points != 0)
				lcd_write_char(points[player2Points][1]);

			for (spaces = 0; spaces < 2; ++spaces)
				lcd_write_char(space);
		}

		else {													// tiebreak = 1
			if (ch == '1') 
				player1Points++;
			else if (ch == '2') 
				player2Points++;
			else
				transmit_string("Wrong key pressed!\n");

			if (player1Points >= 7 || player2Points >= 7) {
				if (player1Points >= player2Points + 2) {
					gameScores[4 * setNumber - 4] += 1;
					player1Games++;
					player1Sets++;
					tiebreak = 0;
				}
				else if (player2Points >= player1Points + 2) {
					gameScores[4 * setNumber - 2] += 1;
					player2Games++;
					player2Sets++;
					tiebreak = 0;
				}
			}

			if (tiebreak == 0) {
				if (checkMatch() == 0)
					setNumber++;
				else
					continue;
				player1Points = 0;
				player2Points = 0;
				player1Games = 0;
				player2Games = 0;
			}

			lcd_cmd(0x80);										// Move cursor to 1st line of LCD
			lcd_write_string(gameScores);
			//lcd_write_fix_string(gameScores, 4 * setNumber - 1);
			lcd_cmd(0xC0);										// Move cursor to 2nd line of LCD
			printTiebreakerPoints(player1Points);
			lcd_write_char(dash);
			printTiebreakerPoints(player2Points);

		}

	}
}