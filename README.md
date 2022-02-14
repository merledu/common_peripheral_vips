# common_peripheral_vips
This repository contains VIPs for generic peripherals.

The verification IPs are UVM (Universal Verification Library) based with test running automation with python code

## How to run verification IP for a specific design?
Clone respositaries [common_peripheral_ip](https://github.com/merledu/common_peripheral_ips) and [common_peripheral_vips](https://github.com/merledu/common_peripheral_vips) that contain IP and verification IP respectively. Clone the mentioned repositories parallel to each other using following couple of `commands`

```
git clone https://github.com/merledu/common_peripheral_ips.git
```
```
git clone https://github.com/merledu/common_peripheral_vips.git
```

## For running verification IP with different number of contraint random test
Redirect to `path` to test a specific `design` using verification IP. For testing `timer` redirect to following path.
```
cd common_peripheral_vips/verif/vips/timer/
```

Excecute the `command` python run_test.py < enter number of test to run >

```
python run_test.py 100
```

In above command `100` means 100 constraint random test will be generated.

Note you can observe the test results in `test_result.txt` file

## OR

### Can also run the single test by following steps

Redirect to `path` to test a specific `design` using verification IP. For testing `timer` redirect to following path.
```
cd common_peripheral_vips/verif/vips/timer/
```
Excecute the `command`
```
./command
```
