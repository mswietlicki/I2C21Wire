#define F_CPU 8000000UL

#include <avr/io.h>
#include <util/delay.h>
#include <stdlib.h>
#include <avr/interrupt.h>
#include <avr/eeprom.h>
#include "usiTwiSlave.h"
#include "io_macros.h"
#include "config.h"

//====================
#define ReadRegister(address) (Register[address])
#define slaveAddress Register[I2C_ADDRESS]

static uint8_t EEMEM eeprom_buffor[REGISTER_SIZE];
static uint8_t EEMEM is_first_run;
static uint8_t Register[REGISTER_SIZE] = {0};

void Init_Register(){
	if(eeprom_read_byte(&is_first_run)){
		eeprom_write_block(&Register[0], &eeprom_buffor[0], REGISTER_SIZE); //Reset EEPROM
		eeprom_write_byte(&eeprom_buffor[I2C_ADDRESS], Default_I2C_Adress); //Set default address

		eeprom_write_byte(&is_first_run, 0); //Zero first run flag
	}

	eeprom_read_block(&Register[0], &eeprom_buffor[0], REGISTER_SIZE);	//Read register from EEPROM
}

void WriteRegister(uint8_t pointer, uint8_t value, uint8_t persistent){
	Register[pointer] = value;
	if(persistent)
		eeprom_write_byte(&eeprom_buffor[pointer], value);
}

//=======================

// A callback triggered when the i2c master attempts to read from a register.
uint8_t i2cReadFromRegister(uint8_t reg)
{
	return ReadRegister(reg);
}

// A callback triggered when the i2c master attempts to write to a register.
void i2cWriteToRegister(uint8_t reg, uint8_t value)
{
	WriteRegister(reg, value, 1);
	if(reg == 0)
		usiTwiSlaveSetAddress(slaveAddress);
}

void Init(){
	DDRB = 0x00;
	PORTB = 0xFF;
}

int main(void){
	Init();
	Init_Register();

	_delay_ms(100);

	usiTwiSlaveInit(slaveAddress, i2cReadFromRegister, i2cWriteToRegister);
	
	sei();

	while(1){	
		_delay_ms(50);
	}
	return 0;
}
