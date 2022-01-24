# common_peripheral_vips
This repository contains VIPs for generic peripherals.

The verification IPs are UVM (Universal Verification Library) based with test running automation with python code

## How to run verification IP for a specific design?
Clone respositaries [common_peripheral_ip](https://github.com/merledu/common_peripheral_ips) and [common_peripheral_vips](https://github.com/merledu/common_peripheral_vips) that contain IP and verification IP respectively. Clone using following couple of `commands`

> git clone https://github.com/merledu/common_peripheral_ips

> git clone https://github.com/merledu/common_peripheral_vips


Redirect to `path` to test a specific `design` using verification IP. For testing `timer` redirect to following path.
> common_peripheral_vips/verif/vips/timer/

Excecute the `command`
> ./command

## OR 

## For running verification IP with different number of contraint random test
