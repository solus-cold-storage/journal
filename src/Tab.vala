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

namespace EvolveJournal
{
  public class EvolveTab : Gtk.Box
  {
    public ScrolledWindow scroller;
    public SourceView text_view;
    public SourceBuffer text_buffer = new SourceBuffer(null);
    public Label label;
    //private SourceUndoManager undo_manager;
    public string save_path;
    public bool saved;
    public SourceStyleSchemeManager style_scheme_manager;
    public string language;

    public EvolveTab(){
      scroller = new ScrolledWindow (null, null);
      scroller.set_policy (PolicyType.AUTOMATIC, PolicyType.AUTOMATIC);
      scroller.set_shadow_type (ShadowType.NONE);
      text_view = new SourceView.with_buffer (text_buffer);
      /*The following causing the text to go to next line instead of going on
      horizonally forever.*/
      text_view.set_wrap_mode(Gtk.WrapMode.WORD);
      text_view.editable = true;
      text_view.cursor_visible = true;
      text_view.set_show_line_numbers(true);
      text_view.set_auto_indent(true);

      var s =  SourceStyleSchemeManager.get_default();
      message("Found %d styles", s.get_scheme_ids().length);

      foreach (var v in s.get_scheme_ids()){
        message("Got style %s", v);
      }

      var scheme = s.get_scheme("oblivion");
      text_buffer.set_style_scheme(scheme);
      text_buffer.set_highlight_syntax(true);

      scroller.add (text_view);

      pack_start(scroller, true, true, 0);

      text_view.show();
      scroller.show();

    }

    public Gtk.Box create_content(EvolveNotebook notebook, int tab_number){
      Label label = new Label("Untitled " + tab_number.to_string());
        label.show();
        //Close Button here.
        Button close_btn = new Button.from_icon_name("window-close", IconSize.BUTTON);
        close_btn.set_relief(Gtk.ReliefStyle.NONE);
        close_btn.show();
        //(Label) Content Box here.
        Box content = new Gtk.Box(Orientation.HORIZONTAL, 0);
        content.pack_start(label, false, false, 0);
        content.pack_end(close_btn, false, false, 0);
        content.show();
        close_btn.clicked.connect(() => {
            notebook.remove_page(notebook.page_num(this));
          });
        return content;
    }

    public Gtk.Box update_content(EvolveNotebook notebook, string label_name){
      Label label = new Label(label_name);
        label.show();
        //Close Button here.
        Button close_btn = new Button.from_icon_name("window-close", IconSize.BUTTON);
        close_btn.show();
        //(Label) Content Box here.
        Box content = new Gtk.Box(Orientation.HORIZONTAL, 0);
        content.pack_start(label, false, false, 0);
        content.pack_end(close_btn, false, false, 0);
        content.show();
        close_btn.clicked.connect(() => {
            notebook.remove_page(notebook.page_num(this));
          });
        return content;
    }

    public void change_focus(EvolveNotebook notebook){
      notebook.set_current_page(notebook.page_num(scroller));
    }

    public void set_text(string text){
      text_view.buffer.text = text;
    }

    public string get_text()
    {
      return text_view.get_buffer().text;
    }

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
      text_buffer.set_language(language_manager.guess_language(file.get_path(), mime_type));
      language = language_manager.guess_language(file.get_path(), mime_type).get_name();
      stdout.printf(language + "\n");
    }
  }
}