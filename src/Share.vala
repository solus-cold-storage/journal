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
using Json;
using Soup;

namespace EvolveJournal {

  public class Share {

    public void generate_paste (string text, Window window) {
      Gdk.Display display = window.get_display();

      //Create Clipboard
      Gtk.Clipboard clipboard = Gtk.Clipboard.get_for_display(display, Gdk.SELECTION_CLIPBOARD);

      //API URL and post info.
      string url = "http://hastebin.com/documents";

      //Create Session
      var session = new Soup.Session();

      var message = new Soup.Message("POST", url);
      message.set_request("data", MemoryUse.COPY, text.data);

      MainLoop loop = new MainLoop ();

    	// Send a request:
    	session.queue_message (message, (sess, mess) => {
    		// Process the result:
        var parser = new Parser();
    		stdout.printf ("Status Code: %u\n", mess.status_code);
    		stdout.printf ("Message length: %lld\n", mess.response_body.length);
    		stdout.printf ("Data: \n%s\n", (string) mess.response_body.data);
        var dialog = new Dialog.with_buttons("Hastebin Link", window,
          DialogFlags.MODAL,
          "OK",
          ResponseType.OK, null);
        var content_area = dialog.get_content_area();
        parser.load_from_data((string)mess.response_body.data, -1);
        var root_object = parser.get_root().get_object();
        string id = root_object.get_string_member("key");
        string link = "http://hastebin.com/" + (string)id;
        var label = new Label("Link Copied to Clipboard:\n" + link);
        clipboard.set_text(link, -1);
        content_area.add(label);
        dialog.response.connect (on_response);

        dialog.show_all();

    		loop.quit ();
    	});

    	loop.run ();

    }
    void on_response (Dialog dialog, int response_id) {
                dialog.destroy();
    }
  }
}
