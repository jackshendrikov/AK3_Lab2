# Basic instructions for a 32-bit ARM processor for microcontrollers

Learn how to use Cortex M4 kernel assembly instructions, work with procedures, and have a basic understanding of kernel architecture.


## Task
Write a program on GAS that calculates a function and run it in the gdb debugger. Show registers with the correct result.

Function: `(a & b) >> 1) + c!`

1. Create files `start.S` and `lscript.ld` as in lab work #1, but the contents of the file `start.S` are as follows:

<details>
<summary>Content of <cite>start.S</cite> (with comments)</summary><p align="left">

```assembly
.syntax unified
.cpu cortex-m4
//.fpu softvfp
.thumb


// Global memory locations.
.global vtable
.global __hard_reset__


/* vector table */
.type vtable, %object
.type __hard_reset__, %function
vtable:
    .word __stack_start 
    .word __hard_reset__+1
    .size vtable, .-vtable
  
__hard_reset__:
// initialize stack here
// if not initialized yet
    bl lab1
    _loop: b _loop
    .size __hard_reset__, .-__hard_reset__


```
</details>

2.Create a file lab1.S, which will be the program:

<details>
  <summary>Content of <cite>lab1.S</cite> (with comments)</summary><p align="left">
  
```assembly
.global lab1
.syntax unified

#define A #5
#define B #7
#define C #3

// ((a & b) >> 1) + c!

lab1:
	push {lr}
	mov r0, A
	and r0, B       // A & B
	lsr r1, r0, #1  // (A & B) >> 1
	mov r0, #1
    
	mov r2, C
	bl factorial
	add r0, r1      // ((A & B) >> 1) + C!
	pop {pc}

factorial:
	push { lr }
	.fact_calc:
		mul r0, r2
		subs r2, #1
		bne .fact_calc
	pop { pc }

```
</details>

3. Create a Makefile to automatically build a project:

<details>
<summary>Content of <cite>Makefile</cite></summary><p align="left">

```make
SDK_PREFIX?=arm-none-eabi-
CC = $(SDK_PREFIX)gcc
LD = $(SDK_PREFIX)ld
SIZE = $(SDK_PREFIX)size
OBJCOPY = $(SDK_PREFIX)objcopy
QEMU = ~/opt/xpack-qemu-arm-2.8.0-12/bin/qemu-system-gnuarmeclipse
BOARD ?= STM32F4-Discovery
MCU=STM32F407VG
TARGET=firmware
CPU_CC=cortex-m4
TCP_ADDR=1234
deps = \
       start.S    \
       lscript.ld

all: target

target:
	$(CC) -x assembler-with-cpp -c -O0 -g3 -mcpu=$(CPU_CC) -Wall start.S -o start.o
	$(CC) -x assembler-with-cpp -c -O0 -g3 -mcpu=$(CPU_CC) -Wall lab1.S -o lab1.o
	$(CC) start.o lab1.o -mcpu=$(CPU_CC) -Wall --specs=nosys.specs -nostdlib -lgcc -T./lscript.ld -o $(TARGET).elf
	$(OBJCOPY) -O binary -F elf32-littlearm  $(TARGET).elf  $(TARGET).bin

qemu:
	$(QEMU)  --verbose --verbose --board $(BOARD) --mcu $(MCU) -d unimp,guest_errors --image $(TARGET).bin --semihosting-config enable=on,target=native -gdb tcp::$(TCP_ADDR)  -S

clean:
	-rm *.o
	-rm *.elf
	-rm *.bin

flash:
	st-flash write $(TARGET).bin 0x08000000
```
</details>

4. Build the project with make:

```sh
>>> make
```

5. Start the qemu emulator with make qemu:

```sh
>>> make qemu
```

6. In another terminal, start the gdb debugger with the command `gdb-multiarch firmware.elf`. And run the program step by step. Demonstrate the value of the registers.

```sh
(gdb) target extended-remote:1234
(gdb) layout regs
(gdb) step
```