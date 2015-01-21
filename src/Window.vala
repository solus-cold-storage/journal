/* Copyright 2014 Ryan Sipes
*
* This file is part of Evolve Journal.
*
* Evolve Journal is free software: you can redistribute it
* and/or modify it under the terms of the GNU General Public License as
* published by the Free Software Foundation, either version 3 of the
* License, or (at your option) any later version.
*
* Evolve Journal is distributed in the hope that it will be
* useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General
* Public License for more details.
*
* You should have received a copy of the GNU General Public License along
* with Evolve Journal. If not, see http://www.gnu.org/licenses/.
*/

using Gtk;

namespace EvolveJournal {

  public string buffer;

  public class EvolveWindow : Window {

    public Gtk.Window EvolveWindow (EvolveJournal.EvolveNotebook notebook, Gtk.Application application) 
    {

    this.window_position = WindowPosition.CENTER;
    set_default_size (600, 400);

    var headbar = new HeaderBar();
    headbar.set_title("Journal");
    headbar.set_show_close_button(true);
    this.set_titlebar(headbar);

    headbar.show();

    notebook.show();

    var open_button = new Button.from_icon_name("emblem-documents-symbolic", IconSize.SMALL_TOOLBAR);
    headbar.add (open_button);
    open_button.show();
    open_button.clicked.connect (() => {
      var file = new EvolveJournal.Files();
      buffer = file.on_open_clicked(notebook);
      });

    var share_button = new Button.from_icon_name("emblem-shared-symbolic", IconSize.SMALL_TOOLBAR);
    headbar.add (share_button);
    share_button.show();
    share_button.clicked.connect (() => {

      int current_tab = notebook.get_current_page();
      stdout.printf(current_tab.to_string() +"\n");
      string typed_text = notebook.get_text();
      var share = new EvolveJournal.Share();
      share.generate_paste(typed_text, true, "Evolve Test", "10M", "vala", this);

    });

    var save_button = new Button.from_icon_name("document-save-symbolic", IconSize.SMALL_TOOLBAR);
    headbar.add (save_button);
    save_button.show();
    save_button.clicked.connect (() => {
        save_file(notebook);
    });

    /*set_accels_for_action("win.EvolveWindow.save_action", {"<Control>s"});

    var action = new SimpleAction("save_action", null);
    action.activate.connect(()=> {
      save_file(notebook);
    });

    application.add_action(action);*/

    MenuButton menu_button = new MenuButton();
    var popover = new Popover(menu_button);
    popover.set_modal(true);
    menu_button.image = new Image.from_icon_name("open-menu-symbolic", IconSize.SMALL_TOOLBAR);
    menu_button.set_popover(popover);
    headbar.pack_end (menu_button);
    menu_button.show();
    GLib.Menu menu = new GLib.Menu();
    menu_button.set_menu_model(menu);
    menu_button.set_use_popover(true);
    menu.append("Use Line Numbers", "linenum");
    
    /* toggle linenum */
    /*var paction = new PropertyAction("linenum", notebook, "use_linenum");
    application.add_action(paction);*/

    // update_actions();

    var vbox = new Box (Orientation.VERTICAL, 0);

    vbox.pack_start(headbar, false, true, 0);
    vbox.pack_start(notebook, true, true, 0);
    vbox.show();
    this.add (vbox);

    headbar.show_all();

    return this;
    }
  }

  public void save_file(EvolveNotebook notebook){
    var file = new EvolveJournal.Files();
    string typed_text = notebook.get_text();
    file.on_save_clicked(typed_text, notebook);
  }
}
