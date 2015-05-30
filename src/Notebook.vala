/* Copyright 2014 Ryan Sipes
*
* This file is part of Solus Journal.
*
* Solus Journal is free software: you can redistribute it
* and/or modify it under the terms of the GNU General Public License as
* published by the Free Software Foundation, either version 2 of the
* License, or (at your option) any later version.
*
* Solus Journal is distributed in the hope that it will be
* useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General
* Public License for more details.
*
* You should have received a copy of the GNU General Public License along
* with Solus Journal. If not, see http://www.gnu.org/licenses/.
*/

using Gtk;

namespace SolusJournal{

public class SolusNotebook: Gtk.Notebook{

        public Gtk.Box newtabbuttonbox;
        public Gtk.Button newtabbutton;
        public string null_buffer = "";
        public bool use_linenum;

        public SolusWindow mother;

        public SolusNotebook(SolusWindow mother)
        {
                this.mother = mother;
                show_border = false;
                set_scrollable(true);
                use_linenum = true;

                //Allow tabs to be moved between notebooks.
                set_group_name("notebook");

                create_window.connect((p, x, y)=> {
                        var w = (mother.application as SolusJournal.App).create_window();
                        w.move(x, y);
                        w.show_all();
                        return w.get_notebook();
                });

                switch_page.connect((page, number)=> {
                        SolusTab tab = (SolusTab)page;
                        set_subtitle_text(tab);
                });

                //Beginning of the code for always keeping a tab around, currently causes segfault if window is closed.
                /*page_removed.connect((c,n)=> {
                        if(this.get_n_pages() <= 0){
                                this.new_tab(this.null_buffer, false, "");
                        }
                });*/

                mother.application.notify["show-tabs"].connect(()=> {
                        bool tabs;
                        mother.application.get("show-tabs", out tabs);
                        if (get_n_pages() != -1 && tabs) {
                                this.show_tabs = true;
                        } else {
                                this.show_tabs = false;
                        }
                });
        }

        public void set_subtitle_text(SolusTab tab){
                var headbar = (Gtk.HeaderBar)mother.get_headerbar();
                headbar.set_subtitle(tab.label_name);
        }

        public void new_tab (string text, bool open_file, string save_path)
        {
                SolusTab tab = new SolusJournal.SolusTab (this);
                tab.set_content("Untitled");
                append_page (tab, tab.get_content());
                update_tab();
                tab.set_text(text);
                if (open_file == true){
                        tab.set_save_path(save_path);
                        tab.saved = true;
                } else {
                        message("New Tab created.\n");
                }
                tab.show ();
                tab.change_focus(this);
                tab.text_buffer.set_style_scheme(new Gtk.SourceStyleSchemeManager().get_default().get_scheme(get_current_scheme())); 
                set_tab_detachable(tab, false);
                set_tab_reorderable(tab, true);
                set_subtitle_text(tab);
        } 

        public void remove_tab(SolusTab tab){
                this.remove_page(this.page_num(tab));
                update_tab();
        }

        public void undo_source(){
                SolusTab tab = (SolusTab)this.get_nth_page(this.get_current_page());
                tab.source_view.undo();         
        }

        public void redo_source(){
                SolusTab tab = (SolusTab)this.get_nth_page(this.get_current_page());
                tab.source_view.redo();
        }

        public string get_text(){
                SolusTab tab = (SolusTab)this.get_nth_page(this.get_current_page());
                SourceBuffer buffer = tab.text_buffer;
                string typed_text = buffer.text;
                return typed_text;
        }

        public void set_label(string label_name){
                SolusTab tab = (SolusTab)this.get_nth_page(this.get_current_page());
                tab.set_content(label_name);
                this.set_tab_label(tab, tab.get_content());
        }

        public string get_label(){
                SolusTab tab = (SolusTab)this.get_nth_page(this.get_current_page());
                return tab.label.get_text();
        }

        public SolusTab get_current_tab(){
                SolusTab tab = (SolusTab)this.get_nth_page(this.get_current_page());
                return tab;
        }

        public void update_tab(){
                bool tabs;
                mother.application.get("show-tabs", out tabs);
                this.set_show_tabs(this.get_n_pages() != 1 | tabs == true);
                SolusTab tab = (SolusTab)this.get_nth_page(this.get_current_page());
                tab.set_close_btn_indicator();
        }

        public string get_current_scheme(){
                string scheme = ((mother.application as SolusJournal.App).get_current_scheme());
                return scheme;
        }

        public bool get_linenum(){
                return use_linenum;
        }
}
 
} // End namespace
