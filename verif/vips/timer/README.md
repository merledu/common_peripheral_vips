## Verification Hierarchy of Timer
![uvm_components_of_tx_test](https://user-images.githubusercontent.com/42897240/150805003-e5d2cca9-1e23-4c0e-ba3f-f01f544bb75a.png)

This repository contains the verification IP of a Timer

## Features of a Timer IP:

1. 64-bit timer with 12-bit prescaler and 8-bit step register
2. Compliant with RISC-V privileged specification v1.11
3. Configurable number of timers per hart and number of harts

Description
The timer module provides a configurable number of 64-bit counters where each counter increments by a step value whenever the prescaler times out. Each timer generates an interrupt if the counter reaches (or is above) a programmed value. The timer is intended to be used by the processors to check the current time relative to the reset or the system power-on.

Compatibility
The timer IP provides memory-mapped registers mtime and mtimecmp which can be used as the machine-mode timer registers defined in the RISC-V privileged spec. Additional features such as prescaler, step, and a configurable number of timers and harts have been added.

## Features of a Timer verification IP:

The verification IP is build on Universal verification methodology (UVM) that contain `Constrained Random Testbenches`.

## Working of verification verification IP

Note: Configuration of the timer is completely randomize by UVM testing environment for all internal registers of timer.

### Configuration

1. First, verification IP generates randomized 64bit `data` that is used to configure the COMPARE_REGISTERS of timer to set the value that timer counts.
2. If `data` to be counted is less than or equal to 64'h00000000FFFFFFFF then set 32bit register `COMPARE_UPPER_REGISTER` to zero located at address 0x110, and also set 32bit register `COMPARE_LOWER_REGISTER` located at address 0x10c to value to be counted i.e `data`.
3. If value to be counted is greater than 64'h00000000FFFFFFFF then set 32bit registers `COMPARE_UPPER_REGISTER` & `COMPARE_LOWER_REGISTER` to upper 32 bits of `data` and lower 32 bits of `data` located at 0x110 & 0x10c respectively.
4. Randomize prescale bits and step bits in the register `CFG0` located at address 0x100
5. Enable interrupt by setting zeroth bit of register `INTR_ENABLE0` located at address 0x114

### Actication of timer

6. Acticate the timer by setting zeroth bit of register `ALERT_TEST` located at address 0x0
