#include <at89c5131.h>

bit tx_complete = 0,rx_complete = 0;    // Bit flags for interrupts

/**********************************************************
UARTInit(): 
	Initialization function to be completed
	Initializes UART peripheral for 8-bit transfer, 
	1 start and 1 stop bits. 
	
	Please write TH1 value for required baud rate
***********************************************************/	
void UARTInit(void)
{
	TMOD = 0x20;						// Configure Timer 1 in Mode 2
	TH1  = 243;							// Load TH1 to obtain require Baudrate (Refer Serial.pdf for calculations)
	SCON = 0x50;						// Configure UART peripheral for 8-bit data transfer 
	TR1  = 1;							// Start Timer 1
	ES   = 1;							// Enable Serial Interrupt
	EA   = 1;							// Enable Global Interrupt
}


/**********************************************************
TransmitChar(<unsigned char ch>): 
	Transmits a character using UART
***********************************************************/	
void TransmitChar(unsigned char ch)
{
	SBUF=ch;							// Load data in SBUF
	while(!tx_complete); 				// Wait for tx_complete flag (interrupt to complete)
	tx_complete = 0;					// Clear tx_complete flag 
}


/**********************************************************
TransmitString(<String pointer>): 
	Transmit a string using UART
***********************************************************/	
void TransmitString(unsigned char *s)
{
	while(*s != 0)
			TransmitChar(*s++);
}


/**********************************************************
ReceiveChar(): 
	Receives a character through UART. Returns a 
	character.
***********************************************************/		
unsigned char ReceiveChar(void)
{
	unsigned char ch = 0;
	while(!rx_complete);				// Wait for rx_complete(interrupt to complete)
	rx_complete = 0;
	ch = SBUF;							// Read data from SBUF
	return ch;							// Return read character
}


/**********************************************************
SerialISR(): 
	Interrupt service routine for UART interrupt.
	Determines whether it is a transmit or receive
	interrupt and raise corresponding flag.
	Transmit or receive functions (defined above) monitor
	for these flags to check if data transfer is done.
***********************************************************/	
void SerialISR(void) interrupt 4
{
		if(TI==1)						// Check whether TI is set
		{
			TI = 0;						// Clear TI flag
			tx_complete = 1;			// Set tx_complete flag indicating interrupt completion
		}
		else if(RI==1)					// Check whether RI is set
		{
			RI = 0;						// Clear RI flag
			rx_complete = 1;			// Set rx_complete flag indicating interrupt completion
		}
}
