#Solus Journal

A lightweight text editor written in Vala, with advanced features available that can be enabled for advanced users.

###Version: 1.0.1 (Stable)
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

____
###TODO
 * Add "Go to Line" feature.
 * Add "Search and Replace" feature.
 * Develop a flexible plug-in manager.
 * Add a drop-down terminal plug-in.
 * Fix keyboard shortcuts when multiple windows are open.
 * Add print functionality.
 * Add font selection menu.
 * Add more themes to the appearance menu.

____
###Icons

* Journal icon copyright of Alejandro Seoane, many thanks!

To use the new icons, after having had Journal previously installed, run this command:
>sudo gtk-update-icon-cache /usr/share/icons/hicolor

###License

Journal is licensed under GPLv2, see COPYING
