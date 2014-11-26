/* Copyright 2014 Ryan Sipes
*
* This file is part of Chimera Journal.
*
* Chimera Journal is free software: you can redistribute it
* and/or modify it under the terms of the GNU General Public License as
* published by the Free Software Foundation, either version 3 of the
* License, or (at your option) any later version.
*
* Chimera Journal is distributed in the hope that it will be
* useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General
* Public License for more details.
*
* You should have received a copy of the GNU General Public License along
* with Chimera Journal. If not, see http://www.gnu.org/licenses/.
*/

int main(string[] args){
  Gtk.init (ref args);

  var notebook = new ChimeraJournal.ChimeraNotebook();
  var win = new ChimeraJournal.ChimeraWindow ();
  win.MainWindow(notebook);

  win.delete_event.connect((win,e) => { Gtk.main_quit (); return false; });
  win.present ();

  Gtk.main ();

  return 0;
}
