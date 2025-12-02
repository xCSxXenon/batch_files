"\[Setup USB.bat]()" asks for a drive letter and desired name. Formats given volume letter as exFAT, gives it an icon, then creates an autorun file so it displays the provided icon and name without the 11-character default limit. Asks to eject it afterwards with \[RemoveDrive](https://www.uwe-sieber.de/drivetools\_e.html). exFAT is used since flash drives are 99% of my use-case. With actual drives, this would still be used so the storage worked on Windows and Mac OS systems. May add parameter flag to overwrite on-demand.



"\[autorun.inf]()" is a template that already contains a line needed to manage icon and label, and another that sets the icon to the one provided.



"\[icon.ico]()" is an icon I found from a .ico database. The original author looks to be \[Laurent Baumann](https://lobau.io/), from their \[Blend](https://lobau.io/old-icons/) icon set in 2007. Released under Creative Commons License.



"\[RemoveDrive.exe](https://www.uwe-sieber.de/drivetools\_e.html) is used from ejecting via CMD. It is allowed for "usage in any environment, including commercial".

