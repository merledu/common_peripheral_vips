# Verification IP of SPI Master Core

## Verification Hierarchy of SPI

This repository contains the verification IP of a SPI master core
![spi_uvm_components_of_tx_test](https://user-images.githubusercontent.com/42897240/176407637-41314d83-a286-4bd0-b1f5-c4ec35f544a4.png)

# Features of a SPI Master Core IP

- Full duplex synchronous serial data transfer
- Variable length of transfer word up to 128 bits
- MSB or LSB first data transfer
- Rx and Tx on both rising or falling edge of serial clock independently
- 4 slave select lines
- Fully static synchronous design with one clock domain
- Technology independent Verilog
- Fully synthesizable

###### Description
The serial interface consists of slave select lines, serial clock lines, as well as input and output data lines. All transfers are full duplex transfers of a programmable number of bits per transfer (up to 32 bits). Compared to the SPI/Microwire protocol, SPI master core has some additional functionality. It can drive data to the output data line in respect to the falling (SPI/Microwire compliant) or rising edge of the serial clock, and it can latch data on an input data line on the rising (SPI/Microwire compliant) or falling edge of a serial clock line. It also can transmit (receive) the MSB first (SPI/Microwire compliant) or the LSB first.

For more details please [this](https://github.com/merledu/common_peripheral_vips/tree/main/verif/vips/spi/docs) document.

# Features of a Timer verification IP

The verification IP is build on Universal verification methodology (UVM) that contain `Constrained Random Testbenches`.

## Working of verification IP

Note: Configuration and testing of the SPI master core is completely randomize by UVM testing environment for all internal registers of the DUT.

#### Configuration/Testing of the core

1. Reset the SPI master core.
2. 

#### Activation the timer

8. Acticate the timer by setting zeroth bit of register `ALERT_TEST` located at address `0x0`.

#### Result

9. Waits until `intr_timer_expired_0_0_o` signal is enabled from the DUT (timer), that indicates timer has compeletd the counting.
10. Compare the number of clock cycles after which `intr_timer_expired_0_0_o` signal is enabled with the predicted clock cycle calculated before (mentioned in point 7).
11. If comparison is succussful then contrained random UVM test is `PASSED`.



# How to run the verification IP?

Follow [this](https://github.com/merledu/common_peripheral_vips) link to run the verification IP.

## OR

Clone respositaries [common_peripheral_ip](https://github.com/merledu/common_peripheral_ips) and [common_peripheral_vips](https://github.com/merledu/common_peripheral_vips) that contain IP and verification IP respectively. Clone the mentioned repositories parallel to each other using following couple of `commands`

```
git clone https://github.com/merledu/common_peripheral_ips.git
```
```
git clone https://github.com/merledu/common_peripheral_vips.git
```

### For running verification IP with different number of contraint random test
Redirect to the following `path` for testing `timer`
```
cd common_peripheral_vips/verif/vips/timer/
```

Excecute the `command` python run_test.py < enter number of test to run >

```
python run_test.py 100
```

In above command `100` means 100 constraint random test will be generated.

Note you can observe the test results in `test_result.txt` file

### OR

#### Can also run the single test by following steps

Redirect to the following `path` for testing `timer`
```
cd common_peripheral_vips/verif/vips/timer/
```
Excecute the `command`
```
./command
```
