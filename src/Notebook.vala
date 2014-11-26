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

namespace ChimeraJournal{

  public class ChimeraNotebook: Notebook{

    public Gtk.Box newtabbuttonbox;
    public Gtk.Button newtabbutton;
    public Button close_btn;
    public Box content;
    public Label label;
    public ChimeraTab tab;

    construct {
        this.show_border = false;
        this.new_tab ();
        this.set_scrollable(true);
        this.popup_enable();
      }

      public ChimeraNotebook()
      {
        this.newtabbuttonbox = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 8);
        this.newtabbuttonbox.show_all();
        this.newtabbutton = new Gtk.Button();
        this.newtabbutton.show_all();
        this.newtabbutton.set_border_width(4);
        this.newtabbutton.clicked.connect (this.new_tab);
        this.newtabbutton.set_relief(Gtk.ReliefStyle.NONE);
        this.newtabbutton.set_image(new Gtk.Image.from_icon_name("tab-new-symbolic", Gtk.IconSize.MENU));
        this.newtabbuttonbox.add(this.newtabbutton);
        this.set_action_widget(this.newtabbuttonbox, Gtk.PackType.END);
      }

      public void new_tab ()
      {
        this.tab = new ChimeraJournal.ChimeraTab ();
        this.get_tab_reorderable(this.tab);
        //Label here.
        this.label = new Label("Untitled");
        this.label.show();
        //Close Button here.
        this.close_btn = new Button.from_icon_name("window-close", IconSize.BUTTON);
        this.close_btn.show();
        //(Label) Content Box here.
        this.content = new Gtk.Box(Orientation.HORIZONTAL, 0);
        this.content.pack_start(this.label, false, false, 0);
        this.content.pack_end(this.close_btn, false, false, 0);
        this.content.show();
        this.close_btn.clicked.connect(() => {
            this.remove_page(this.page_num(this.content));
          });
        this.append_page (this.tab.create_scroller(), this.content);
        this.tab.show ();
      }

  }
}
