# SimpleAlarmClock_8051
A simple alarm clock/timer program written in Assembly for the Intel 8051 microcontroller. A university project.

# How to use:
This alarm clock displays the current time and triggers a signal when the time reaches a previously set value. You need an Intel 8051 microcontroller or an emulator program (DSM-51 or similar) to use the .hex file.

Setting up the time:
- Enter the first two-digit number as hours (00-23).
- Then enter the second two-digit number as minutes (00-59).
- Lastly, enter the third two-digit number as seconds (00-59).
- After that, you'll need to set up the alarm.

Setting up the alarm:
- Enter the first two-digit number as hours (00-23).
- Then enter the second two-digit number as minutes (00-59).
- The LCD will now show the current time.
- When the clock reaches the alarm time, it will turn on the LED and the buzzer for 3 seconds.

# Caution
This program does not validate input data! It is not protected against invalid inputs (such as: 24:60:73, 65:86:61, etc.).