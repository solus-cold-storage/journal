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

using Gtk;

namespace ChimeraJournal {

  public class ChimeraWindow : Window {

    public Gtk.Window MainWindow (ChimeraJournal.ChimeraNotebook notebook) {

    this.window_position = WindowPosition.CENTER;
    set_default_size (600, 400);

    var headbar = new HeaderBar();
    headbar.set_title("Journal");
    headbar.set_show_close_button(true);
    this.set_titlebar(headbar);

    headbar.show();

    notebook.show();

    var share_button = new Button.from_icon_name("emblem-shared-symbolic", IconSize.SMALL_TOOLBAR);
    headbar.add (share_button);
    share_button.show();
    share_button.clicked.connect (() => {

      int current_tab = notebook.get_current_page();
      stdout.printf(current_tab.to_string() +"\n");
      //stdout.printf(notebook.get_nth_page(current_tab).text_view.buffer.text);*/
      var share = new ChimeraJournal.Share();
      share.generate_paste("test", true, "Chimera Test", "10M", "vala", this);

    });

    var save_button = new Button.from_icon_name("document-save-symbolic", IconSize.SMALL_TOOLBAR);
    headbar.add (save_button);
    save_button.show();

    var vbox = new Box (Orientation.VERTICAL, 0);

    vbox.pack_start(headbar, false, true, 0);
    vbox.pack_start(notebook, true, true, 0);
    vbox.show();
    this.add (vbox);

    headbar.show_all();

    return this;
    }
  }
}
