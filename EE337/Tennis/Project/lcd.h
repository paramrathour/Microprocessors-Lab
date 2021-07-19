/*************************************************
 	lcd.h: Header file for 16x2 LCD interfacing  
**************************************************/

								// Functions contained in this header file
void msDelay(unsigned int);		// fn takes integer value as an input and generates corresponding delay in milli seconds
void LCDInit(void);										// Initialize LCD
void LCDClear(void);										// Clear LCD
void LCDCmd(unsigned int i);								// Sends commands to LCD
void LCDWriteChar(unsigned char ch);							// display character on a LCD corresponding to input ascii
void LCDWriteString(unsigned char *s);					// takes pointer of a string which ends with null and display on a LCD 

//Signals to LCD
sbit RS=P0^0;							   // Register select
sbit RW=P0^1;							   // Read from or write to register
sbit EN=P0^2;							   // Enable pin of LCD


//Function definitions
/************************************************
LCDInit():
	Initializes LCD port and 
	LCD display parameters
************************************************/
void LCDInit(void)
{
	P2=0x00;
	EN=0;
	RS=0;
	RW=0;
	
	LCDCmd(0x38);							// Function set: 2 Line, 8-bit, 5x7 dots
	msDelay(4);
	LCDCmd(0x06);							// Entry mode, auto increment with no shift
	msDelay(4);
	LCDCmd(0x0C);							// Display on, Curson off
	msDelay(4);
	LCDCmd(0x01);							// LCD clear
	msDelay(4);
	LCDCmd(0x80);							//Move cursor to Row 1 column 0
}

void LCDClear(void)
{
	msDelay(4);
	LCDCmd(0x01);							// LCD clear
	msDelay(4);
}
/**********************************************************
msDelay(<time_val>): 
	Delay function for delay value <time_val>ms
***********************************************************/	
void msDelay(unsigned int time)
{
	int i,j;
	for(i=0;i<time;i++)
		for(j=0;j<382;j++);
}



/**********************************************************
LCDCmd(<char command>):
	Sends 8 bit command
	LCD display parameters
***********************************************************/	
void LCDCmd(unsigned int i)
{
	RS=0;
	RW=0;
	EN=1;
	P2=i;
	msDelay(10);
	EN=0;
}

/**********************************************************
LCDWriteChar(<char data>):
	Sends 8 bit character(ASCII)
	to be printed on LCD
***********************************************************/	
void LCDWriteChar(unsigned char ch)
{
	RS=1;
	RW=0;
	EN=1;
	P2=ch;
	msDelay(10);
	EN=0;
}


/***********************************************************
LCDWriteString(<string pointer>):
	Prints string on LCD. Requires string pointer 
	as input argument.
***********************************************************/	
void LCDWriteString(unsigned char *s)
{
	while(*s!='\0')
		LCDWriteChar(*s++);
}