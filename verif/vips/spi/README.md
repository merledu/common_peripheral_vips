# Verification IP of SPI Master Core

## Verification Hierarchy of SPI

This repository contains the verification IP of a SPI master core
![spi_uvm_components_of_tx_test](https://user-images.githubusercontent.com/42897240/176407637-41314d83-a286-4bd0-b1f5-c4ec35f544a4.png)

# Features of a SPI Master Core IP

- Full duplex synchronous serial data transfer
- Length of transfer word is upto 32 bits
- MSB or LSB first data transfer
- Rx and Tx on both rising or falling edge of serial clock independently
- 4 slave select lines
- Fully static synchronous design with one clock domain
- Technology independent Verilog
- Fully synthesizable

###### Description
The serial interface consists of slave select lines, serial clock lines, as well as input and output data lines. All transfers are full duplex transfers of a programmable number of bits per transfer (up to 32 bits). Compared to the SPI/Microwire protocol, SPI master core has some additional functionality. It can drive data to the output data line in respect to the falling (SPI/Microwire compliant) or rising edge of the serial clock, and it can latch data on an input data line on the rising (SPI/Microwire compliant) or falling edge of a serial clock line. It also can transmit (receive) the MSB first (SPI/Microwire compliant) or the LSB first.

For more details please [this](https://github.com/merledu/common_peripheral_vips/tree/main/verif/vips/spi/docs) document.

# Features of a SPI verification IP

The verification IP is build on Universal verification methodology (UVM) that contain `Constrained Random Testbenches`.

## Working of verification IP

Note: Configuration and testing of the SPI master core is completely randomize by UVM testing environment for all internal registers of the DUT.

#### Configuration/Testing of the core

1. Reset the SPI master core
2. Configure the Control and status register located at address `0x10`. Initially, this register is configured as `RX` and `TX` are disabled and other field like `ie`, `lsb` and `char_length`
3. Configure the MOSI register (TX register) located at address `0x0`
4. Configure the Divider located at address `0x14`
5. Configure the slave select register located at address `0x18`. Note slave select register is configured randomly
6. `TX` is enabled by reconfiguring the control and status register located at `0x10`
8. Testing the functionality of `TX` (MOSI pin) by configuring `TX` register and enabling it multiple times to through data on `sd_o` pin
9. Storing the `sd_o` 32 bit serial data in the `TX` queue to be compare with respective `TX` queue present in the checker logic
10. Testing the functionality of `RX` (MISO pin) by applying the random one bit stimulus (i.e. serial input data) on `sd_i` pin and `RX` is enabled multiple times and serial data is collected in the `RX` register located at address `0x20` in the DUT.
11. Note that the rx (MISO) is enabled by reconfiguring the control and status register located at `0x10` to collect the serial data on `sd_i` pin in the internal `RX` register located at address `0x20` of DUT
12. Then read the 32 bit data stored in `RX` register whenever `rx_interrupt` is asserted on the output and store that in `RX` queue that is compared with the `RX` queue implemented in the checker logic
13. After `TX` and `RX` are checked independently. Verification environment check the full duplex mode by enabling the tx and rx simultaneously and store the results in their respective queues.

#### Result

14. Finally the actual `tx_data` and `rx_data` queues are compared with the expected `RX` and `TX` queues to find out either the test `passed` or `failed`

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
Redirect to the following `path` for testing `SPI`
```
cd common_peripheral_vips/verif/vips/spi/
```

Excecute the `command` python run_test.py < enter number of test to run >

```
python run_test.py 100
```

In above command `100` means 100 constraint random test will be generated.

Note you can observe the test results in `test_result.txt` file

### OR

#### Can also run the single test by following steps

Redirect to the following `path` for testing `spi`
```
cd common_peripheral_vips/verif/vips/spi/
```
Excecute the `command`
```
./command
```
