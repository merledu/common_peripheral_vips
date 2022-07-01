# Verification IP of UART

## Verification Hierarchy of UART
![uvm_components_of_tx_test](https://user-images.githubusercontent.com/42897240/170076067-cf450306-4bc4-4271-a9d8-0e226c759fbb.png)


This repository contains the verification IP of a UART


# Features of a UART IP

UART stands for Universal Asynchronous Receiver/Transmitter. It’s not a communication protocol like SPI and I2C, but a physical circuit in a microcontroller, or a stand-alone IC. A UART’s main purpose is to transmit and receive serial data.

###### Description

In UART communication, two UARTs communicate directly with each other. The transmitting UART converts parallel data from a controlling device like a CPU into serial form, transmits it in serial to the receiving UART, which then converts the serial data back into parallel data for the receiving device. Only two wires are needed to transmit data between two UARTs. Data flows from the Tx pin of the transmitting UART to the Rx pin of the receiving UART.

# Features of a UART verification IP

The verification IP is build on Universal verification methodology (UVM) that contain `Constrained Random Testbenches`.

## Working of verification IP

Note: Configuration of the UART is completely randomize by UVM testing environment for all internal registers of UART.

[This link](https://www.circuitbasics.com/basics-uart-communication/#:~:text=UART%20stands%20for%20Universal%20Asynchronous,transmit%20and%20receive%20serial%20data) points to the working and behaviour of UART

#### Configuration and Testing UART

1. First, we have to set configurable registers which are `baud rate`, `tx_level` and `tx_data` located at addresses `0x0`, `0x18` and `0x04` respectively
2. Enable the `RX` by writing in register at address `0xc`
3. Enabled the `TX` (transfer) by writing in register at address `0x1c`
4. Then disable the transfer
5. And read data that is stored in the `RX` register at address `0x8` of the recieving UART
6. To read the `baud_rate` set, set the `pwrite_i` to `0` and set the addr to `0x0`
7. To read the level of `fifo` set, set the `pwrite` to `0` and set the addr to `0x18`
8. To read the data entered into the `fifo`,set the `pwrite_i` to `0` and set `addr` to `4` according to the `tx_level` set.

#### Result

9. Compare the data that is transfered from the `TX` UART with the data received in `RX` UART

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
Redirect to the following `path` for testing `UART`
```
cd common_peripheral_vips/verif/vips/uart
```

Excecute the `command` python run_test.py < enter number of test to run >

```
python run_test.py 100
```

In above command `100` means 100 constraint random test will be generated.

Note you can observe the test results in `test_result.txt` file

### OR

#### Can also run the single test by following steps

Redirect to the following `path` for testing `UART`
```
cd common_peripheral_vips/verif/vips/uart/
```
Excecute the `command`
```
./command
```
