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

  public class EvolveNotebook: Gtk.Notebook{

    public Gtk.Box newtabbuttonbox;
    public Gtk.Button newtabbutton;
    public string null_buffer = "";
    public bool use_linenum;

      public EvolveNotebook()
      {
        //Old Construct Stuff
        this.show_border = false;
        this.set_scrollable(true);
        use_linenum = true;
        //Done here.
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
        EvolveTab tab = new EvolveJournal.EvolveTab (this);
        tab.set_content("Untitled");
        append_page (tab, tab.get_content());
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
        tab.change_focus(this);
      } 

      public string get_text(){
        EvolveTab tab = (EvolveTab)this.get_nth_page(this.get_current_page());
        SourceBuffer buffer = tab.text_buffer;
        string typed_text = buffer.text;
        return typed_text;
      }

      public void set_label(string label_name){
        EvolveTab tab = (EvolveTab)this.get_nth_page(this.get_current_page());
        tab.set_content(label_name);
        this.set_tab_label(tab, tab.get_content());
      }

      public bool get_linenum(){
        return use_linenum;
      }

  }
}
