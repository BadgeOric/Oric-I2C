# Oric-I2C
Oric Wifi using ESP8266 module and I2C comms

Here lies a number of files that allow WIFI file transfer from anywhere to a Oric (1 or Atmos)

Quick Usage:-
The wifi module connects to the printer port of the oric using 3 wires.
Any of the top row of the printer port is GND and connects to GND on the wifi module.
Looiking from the back, 2nd pin of bottom row of printer port connects to D2 of wifi module.
3rd pin of bottom row connects to D1 of wifi module.

Both D1 and D3 of the wifi module should be pulled up to 3.3v using 2 x 4.7k Resistors. Connect resistors between 3.3v pin
D1 and D2.

Using an ESP8266 flashed with the Arduino core as the wifi module, Socket_server_3 should be uploaded
to the module after filling in your own wifi SSID and Password

Load the OricI2C.tap into your Oric (in the build folder) and let it run.

The wifi module should announce connection to your wifi and give out its IP address.

Using some kind of terminal software (I used realterm), you can connect to the wifi module by entering the ip address and
port number (default port is 80 set in Socket_Sever_3 code and can be changed.)

Using Realterm
--------------
In realterm eneter xxx.xxx.xxx.xxx:80 into the port text box on the port tab (xxx replaced by modules wifi ip).
*****ENSURE winsock mode is set to RAW****** (little radio button on port tab)
Click connect.

Wifi module should announce "client connected" over the serial connection.

On the send tab, select a file to send and click send (delays can be set to 0). Once its uploaded you can then move onto the Oric.

On the Oric
-----------
Running OricI2C.tap should first set up the assembly routine and then give you an option to send or receive.
Send is not fully implemented but you can send text strings back to the terminal emulator.

Receive you get an option to receive text or hires. It will then ask how many bytes to receive.
If you pick text then after a short while (depending on how many bytes) it will display the received text on screen.
It will be unformatted with no line breaks as the code just pokes values onto the screen avoiding the firast 2 columns.

In hires the picture will appear as it is being received.


How it Works
============
The oric communicates with the wifi module over I2C (address 4 is set in Socket_Server_3) withe the Oric being the
master and the module being the slave.

Each transferred byte is stored in a chunk of memory (#6000) for text and #A000 for hires.
There are several zero page locations documented in GenericI2c.s that can be altered to change these as require.
In theory setting the memory location to #500 could load a basic program into memory. Remember tap files sent to the oric would
need the header removing , but you can use header.exe as part of the OSDK to do that.

Something to try maybe? - Design a font on your pc/mac/whatever and set the receive memory location to #B400 to upload the font
over wifi to the Oric.

Future Developments - if possible
=================================
Replace the basic code (which is just a proof of concept) with assembly that can be located anywhere.

The send routine to include sending blocks of memory so can save programs over wifi.

A better interface on the PC/mac etc that acts more like a file server that could be controlled by the oric.

SD card addition to the Wifi module so could transfer files from pc to module.

Allowing the Oric to set the SSID and Password of the Wifi network so that its portable without uploading new code to the module.

Anything else, either I or anyone else can think of.









