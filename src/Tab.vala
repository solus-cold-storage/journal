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

namespace ChimeraJournal
{
  public class ChimeraTab : Gtk.Box
  {
    public ScrolledWindow scroller;
    public TextView text_view;

    public CssProvider style_provider;

    private const string TEXTVIEW_STYLESHEET = """
    .Text_View {
      background-color: #FAE7B6;
      color: #99601F;
    }
    .Text_View:selected {
      background: #F4F2F5;
    }
    """;

    public Gtk.Widget create_scroller(){

      style_provider = new CssProvider();
      scroller = new ScrolledWindow (null, null);
      scroller.set_policy (PolicyType.AUTOMATIC, PolicyType.AUTOMATIC);
      scroller.set_shadow_type (ShadowType.NONE);
      text_view = new TextView ();

      /*The following causing the text to go to next line instead of going on
      horizonally forever.*/
      text_view.set_wrap_mode(Gtk.WrapMode.WORD);
      text_view.editable = true;
      text_view.cursor_visible = true;

      try  {
                style_provider.load_from_data (TEXTVIEW_STYLESHEET, -1);
            } catch (Error e) {
                stderr.printf ("\nCouldn't load style provider.\n");
            }

      text_view.get_style_context().add_class("Text_View");
      text_view.get_style_context().add_provider(style_provider, STYLE_PROVIDER_PRIORITY_APPLICATION);

      scroller.add (text_view);

      text_view.show();
      scroller.show();

      return scroller;
    }

  }
}
