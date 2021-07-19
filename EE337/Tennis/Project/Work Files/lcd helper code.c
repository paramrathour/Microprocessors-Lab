lcd helper code

msdelay(100);
lcd_cmd(0x80);										// Move cursor to 1st line of LCD
lcd_cmd(0xC0);										// Move cursor to 2nd line of LCD

code unsigned char display_msg1[]="Volt.: ";						//Display msg on 1st line of lcd
lcd_write_string(display_msg1);											//Display "Volt: " on first line of lcd
unsigned char display_msg3[]={0,0,0,'.',0,' ',223,'C','\0'};//"xxx °C", Display msg on 2nd line of lcd	

char adc_ip_data_ascii[6]={0,0,0,0,0,'\0'};							//string array for saving ascii of input sample
unsigned int adc_data=0;
int_to_string(adc_data,adc_ip_data_ascii);					//Converting integer to string of ascii
lcd_write_string(adc_ip_data_ascii);								//Print analog sampled input on lcd

transmit_string("************************\r\n");


Functions 
void int_to_string(unsigned int,unsigned char *str_data);
												// convert unsigned int to string of corresponding decimal value 
/**********************************************************
int_to_string(<integer_value>,<string_ptr>): 
	Converts integer to string of length 5
***********************************************************/	
void int_to_string(unsigned int val,unsigned char *str_data)
{	
   											// char str_data[4] = 0;
	str_data[0]=48+(val/10000);
	str_data[1]=48+(val%10000/1000);
	str_data[2]=48+((val%1000)/100);
	str_data[3]=48+((val%100)/10);
	str_data[4]=48+(val%10);
   											// return str_data;
}
Ditch
unsigned char display_msg3[]={0, 15, 30, 40, 'Ad','\0'};//"xxx °C", Display msg on 2nd line of lcd	

code unsigned char dash[] = "-";
unsigned char points[][2] = {0,0, 1,5, 3,0, 4,0, 'A','d'};
unsigned char setScores[] = {0,'-',0,' ',0,'-',0,' ',0,'-',0,'\0'};
unsigned int player1Points = 0, player2Points = 0;
unsigned int player1Games = 0, player2Games = 0;
unsigned int setNumber = 1;

Might be

switch(ch)
			{
				case '1':lcd_test();
								 transmit_string("LCD tested\r\n");
								 break;
				
				case '2':led_test();
								 transmit_string("LED tested\r\n");
								 break;
							
				default:transmit_string("Incorrect test. Pass correct number\r\n");
								 break;
				
			}