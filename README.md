**Important Notice**  
Feature requests for this development branch of linbo are no longer accepted. Only bugs will be fixed until July 31 2021. The further development then ends.
Feel free to place your request with the successor [linuxmuster-linbo7](https://github.com/linuxmuster/linuxmuster-linbo7).

![linbo icon](graphics/linbo_icon_194x194.png)  

**linuxmuster-linbo** is the free and opensource imaging solution for linuxmuster.net. It handles Windows 7 & 10 and Linux operating systems. Via TFTP and Grub's PXE implementation it boots a small linux system (linbofs) with a gui, which can manage all the imaging tasks on the client. Console tools are also available to manage clients and imaging remotely via the server.

Build instructions:

* Install 64bit Ubuntu 18.04.

* Add 32bit Architecture:  
  `sudo dpkg --add-architecture i386`  
  `sudo apt update`

* If you are using Ubuntu server or minimal:
  `sudo apt install dpkg-dev`

* Install build depends (uses sudo):  
  `./get-depends.sh`

* Build package:  
  `./buildpackage.sh`

For more information take a look at the  [wiki](https://github.com/linuxmuster/linuxmuster-linbo/wiki)
