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

namespace EvolveJournal{

  public class EvolveNotebook: Notebook{

    public Gtk.Box newtabbuttonbox;
    public Gtk.Button newtabbutton;
    public int tab_count;
    public string null_buffer = "";

    construct {
        this.show_border = false;
        this.set_scrollable(true);
        int tab_count = 0;
      }

      public EvolveNotebook()
      {
        this.newtabbuttonbox = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 8);
        this.newtabbuttonbox.show_all();
        this.newtabbutton = new Gtk.Button();
        this.newtabbutton.show_all();
        this.newtabbutton.set_border_width(4);
        this.newtabbutton.clicked.connect (() => {
          this.new_tab(null_buffer, false, "");
          });
        this.newtabbutton.set_relief(Gtk.ReliefStyle.NONE);
        this.newtabbutton.set_image(new Gtk.Image.from_icon_name("tab-new-symbolic", Gtk.IconSize.MENU));
        this.newtabbuttonbox.add(this.newtabbutton);
        this.set_action_widget(this.newtabbuttonbox, Gtk.PackType.END);
      }

      public void new_tab (string text, bool open_file, string save_path)
      {
        EvolveTab tab = new EvolveJournal.EvolveTab ();
        int tab_number = tab_count;
        append_page (tab, tab.create_content(this, tab_number));
        tab.set_text(text);
        if (open_file == true){
          tab.save_path = save_path;
          tab.saved = true;
        }
        else {
          stdout.printf("This is a new tab\n");
        }
        stdout.printf(text);
        tab.show ();
        tab_count += 1;
        tab.move_focus(this);
      } 

      public string get_text(){
        EvolveTab scroller = (EvolveTab)this.get_nth_page(this.get_current_page());
        TextView text_view = scroller.text_view;
        string typed_text = text_view.get_buffer().text;
        return typed_text;
      }

      public void set_label(string label_name){
        EvolveTab tab = (EvolveTab)this.get_nth_page(this.get_current_page());
        this.set_tab_label(tab, tab.update_content(this, label_name));
      }

  }
}
