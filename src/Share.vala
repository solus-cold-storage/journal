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

    public void generate_paste (string text, bool privacy, string name,
      string expire, string format, Window window) {
        //Defining privacy parameters, unlisted or public.
        int paste_private;
        if (privacy != true){
          paste_private = 1;
        }
        else{
          paste_private = 0;
        }

        //Dev Key
        string dev_key = "95b430eb0048d3d416544ae9364d61bd";

        //User
        /*char user_key = '';*/

        //Adding text to be pasted.
        string post = text;

        //Adding title of paste.
        string title = name;

        //Adding expiration.
        string post_expire = expire;

        //Adding format.
        string type = format;

        //API URL and post info.
        string url = "https://paste.ee/api?key=" + dev_key + "&paste=" + post;

        //Create Session
        var session = new Soup.SessionAsync();

        var message = new Soup.Message("POST", url);

        MainLoop loop = new MainLoop ();

      	// Send a request:
      	session.queue_message (message, (sess, mess) => {
      		// Process the result:
            var parser = new Parser();
      		stdout.printf ("Status Code: %u\n", mess.status_code);
      		stdout.printf ("Message length: %lld\n", mess.response_body.length);
      		stdout.printf ("Data: \n%s\n", (string) mess.response_body.data);
            var dialog = new Dialog.with_buttons("Paste.ee Link", window,
                                                    DialogFlags.MODAL,
                                                    Stock.OK,
                                                    ResponseType.OK, null);
            var content_area = dialog.get_content_area();
            parser.load_from_data((string)mess.response_body.data, -1);
            var root_object = parser.get_root().get_object();
            string id = root_object.get_object_member("paste").get_string_member("id");
            var label = new Label("Link Generated is:\n" + "https://paste.ee/p/" + (string)id);
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
