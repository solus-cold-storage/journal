#Evolve Journal

##DISCLAIMER: This project is very much a WIP.
____
###Dependencies

* gtk+-3.0
* libsoup-2.4
* json-glib-1.0
* gtksourceview-3.0

____
###To Build

Change to this folder (Journal's root folder)
   
>mkdir build
> 
>cd build
>
>cmake -DCMAKE_INSTALL_PREFIX=/usr ../
>
>make
>
>sudo make install

Icons
____
* Journal icon copyright of Alejandro Seoane, many thanks!

To use the new icons, after having had Journal previously installed, run this command:
>sudo gtk-update-icon-cache /usr/share/icons/hicolor