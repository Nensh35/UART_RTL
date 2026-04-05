
#  UART RTL (Tx + Rx)

##  Overview

This project implements a UART Transmitter and Receiver in Verilog with end-to-end communication verified using a testbench.

* FSM-based design
* Even parity support
* Bit-level timing using cycle counters
* Asynchronous behavior using different clocks

---

##  Features

* 8-bit data transmission
* Even parity generation & checking
* Start and Stop bit handling
* PISO (Tx) and SIPO (Rx)
* Mid-bit sampling in Rx
* Basic error detection (start, parity, stop)

---

##  Working

### Transmitter (Tx)

* Waits for `data_flg`
* Loads data into PISO
* Sends frame:
  Start → Data[7:0] → Parity → Stop
* Timing controlled using `bit_cycle`

---

### Receiver (Rx)

* Detects start bit
* Samples at mid-bit
* Shifts data into SIPO
* Performs parity and stop bit check

---

## Frame Format

Start | Data (8-bit) | Parity | Stop

---

##  Simulation

* Tx connected directly to Rx
* Different clocks used (Tx faster, Rx slower)
* Example tested: `10101010`
* Output verified from Rx SIPO register

---

##  Future Work

* Add Asynchronous FIFO (for clock domain crossing)
* Configurable baud rate
* FPGA implementation

---

## 📁 Files

* Tx.v           //  Transmitter   
* Rx.v           //  Receiver   
* PISO.v         //parallel in serial out 
* SIPO.v         // serial in parallel out 
* tb*Tx_*Rx.v    //  test bench for final Tx and Rx
* tb_Tx.v        //test bench for the Transmitter

##
