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

namespace SolusJournal
{

public class SolusTab : Gtk.Box
{
        public ScrolledWindow scroller;
        public SourceBuffer text_buffer = new SourceBuffer(null);
        public Label label;
        public string label_name;
        private string save_path;
        public bool saved;
        public SourceStyleSchemeManager style_scheme_manager;
        public string language;
        public bool edited = false;
        public Box content;
        public Button close_btn;
        public Image close_btn_indicator;
        public SourceView source_view;

        public SolusTab(SolusNotebook notebook){  
                //Set up Scrolled Window.
                scroller = new ScrolledWindow (null, null);
                scroller.set_policy (PolicyType.AUTOMATIC, PolicyType.AUTOMATIC);       
                //Set up Source View
                source_view = new SourceView();
                source_view.set_wrap_mode(Gtk.WrapMode.WORD);
                source_view.editable = true;
                source_view.cursor_visible = true;
                source_view.set_show_line_numbers(true);
                source_view.set_auto_indent(true);
                source_view.set_buffer(text_buffer);
                source_view.set_highlight_current_line(true);
                //Set the font to monospace.
                var fontdec = new Pango.FontDescription();
                fontdec.set_family("Monospace");
                this.source_view.override_font(fontdec);
                scroller.set_shadow_type (ShadowType.NONE);
                //Watch for the Buffer to change.
                text_buffer.changed.connect(() => {
                        if (edited == false){
                                edited = true;
                                //Change the close button when text has been changed.
                                set_close_btn_indicator();
                        } else {
                                //It is edited.
                        }
                });

                pack_start(scroller, true, true, 0);
                scroller.add(source_view);

                source_view.show();
                scroller.show();

                scheme_selector(notebook);
        }

        public void scheme_selector(SolusNotebook notebook){
                notebook.mother.change_scheme.connect((scheme) => {
                        text_buffer.set_style_scheme(new Gtk.SourceStyleSchemeManager().get_default().get_scheme(scheme)); 
                });
        }

        //Content setter and getter.
        public void set_content(string new_label_name){
                label_name = new_label_name;
                label = new Label(new_label_name);
                close_btn = new Button();
                set_close_btn_indicator();
                close_btn.show();
                label.show();
                content = new Gtk.Box(Orientation.HORIZONTAL, 0);
                content.pack_start(label, false, false, 0);
                content.pack_end(close_btn, false, false, 0);
                content.show();
                close_btn.clicked.connect(remove_tab);
        }

        public Gtk.Box get_content(){
                return content;
        }

        public void remove_tab() {
                SolusNotebook parent_notebook = (SolusNotebook)this.get_parent();
                if (edited == true){
                        SolusWindow win = (SolusWindow)this.get_toplevel();
                        // The MessageDialog
                        Gtk.MessageDialog msg = new Gtk.MessageDialog (win, Gtk.DialogFlags.MODAL, Gtk.MessageType.WARNING, Gtk.ButtonsType.OK_CANCEL, "Close unsaved document?");
                        msg.response.connect ((response_id) => {
                                switch (response_id) {
                                        case Gtk.ResponseType.OK:
                                                stdout.puts ("Ok\n");
                                                parent_notebook.remove_tab(this);
                                        break;
                                                case Gtk.ResponseType.CANCEL:
                                                stdout.puts ("Cancel\n");
                                        break;
                                                case Gtk.ResponseType.DELETE_EVENT:
                                                stdout.puts ("Delete\n");
                                        break;
                                }
                                msg.destroy();
                        });
                        msg.show ();
                } else {
                        parent_notebook.remove_tab(this);
                }
                parent_notebook.update_tab();
        }

        public void set_close_btn_indicator(){
                SolusWindow win = (SolusWindow)this.get_toplevel();
                SolusNotebook parent_notebook = (SolusNotebook)this.get_parent();
                if (edited == true){
                        close_btn.set_image(new Image.from_icon_name("software-update-urgent-symbolic", IconSize.BUTTON));
                        if (parent_notebook.get_n_pages() == 1){
                                win.get_save_button().get_style_context().add_class("suggested-action");
                        } else {
                                message("More than one tab.");
                                win.get_save_button().get_style_context().remove_class("suggested-action");
                        }
                } else {
                        close_btn.set_image(new Image.from_icon_name("window-close-symbolic", IconSize.BUTTON));
                        win.get_save_button().get_style_context().remove_class("suggested-action");
                }
        }

        public void change_focus(SolusNotebook notebook){
                notebook.set_current_page(notebook.page_num(content));
        }

        public void save_file(File file){
                save_path = file.get_path();
                saved = true;
                set_lang(file);
                edited = false;
                set_close_btn_indicator();
        }

        public string get_save_path(){
                return save_path;
        }

        public void set_save_path(string path){
                save_path = path;
        }

        //Edited setter and getter.
        public void set_edited(bool boolean){
                edited = boolean;
        }

        public bool get_edited(){
                return edited;
        }

        //Text setter and getter.
        public void set_text(string text){
                text_buffer.set_text(text);
        }

        public string get_text() {
                return text_buffer.text;
        }

        //Set Language.
        public void set_lang(File file)
        {
                FileInfo? info = null;
                try {
                        info = file.query_info ("standard::*", FileQueryInfoFlags.NONE, null);
                } 
                catch (Error e) {
                        warning (e.message);
                        return;
                }
                var mime_type = ContentType.get_mime_type (info.get_attribute_as_string (FileAttribute.STANDARD_CONTENT_TYPE));
                SourceLanguageManager language_manager = new SourceLanguageManager();
                language = language_manager.guess_language(file.get_path(), mime_type).get_name();
                if (language != null){
                        text_buffer.set_language(language_manager.guess_language(file.get_path(), mime_type));
                        message(language + "\n");
                } else {
                        message("No language.\n");
                }
        }
} 
} // end namespace
