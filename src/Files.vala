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
using GLib;

namespace EvolveJournal {

	private Window TextFileViewer;
	private string text_buffer_load;

	public class Files {

		public string on_open_clicked (EvolveNotebook notebook) {
			var file_chooser = new FileChooserDialog("Open File", TextFileViewer,
				FileChooserAction.OPEN, "Cancel", ResponseType.CANCEL,
				"Open", ResponseType.ACCEPT);
			file_chooser.set_select_multiple(true);
			file_chooser.set_local_only(true);
			if (file_chooser.run () == ResponseType.ACCEPT) {
				foreach (File file in file_chooser.get_files()){
					//This is needed to pull the filename out (and not the whole path)
					text_buffer_load = open_file (file.get_path ());
					notebook.new_tab(text_buffer_load, true, file.get_path());
					notebook.set_label(file.get_basename());
					EvolveTab tab = (EvolveTab)notebook.get_nth_page(notebook.get_current_page());
					tab.set_lang(file);
				}
			}
			else {
				text_buffer_load = null;
			}
			file_chooser.destroy();
			return text_buffer_load;
		}

		public string open_at_start(EvolveNotebook notebook, string file_path, string file_name){
			string success = "open_at_start, started!" + "\n";
			text_buffer_load = open_file(file_path);
			notebook.new_tab(text_buffer_load, true, file_path);
			notebook.set_label(file_name);
			EvolveTab tab = (EvolveTab)notebook.get_nth_page(notebook.get_current_page());
			File file = File.new_for_path(file_path);
			tab.set_lang(file);
			return success;
		}

		private string open_file (string filename) {
			string text;
			try {
				FileUtils.get_contents(filename, out text);
			} catch (Error e) {
				text = "";
				stderr.printf("Error: %s\n", e.message);
			}
			return text;
		}

		public void on_save_clicked(string text_to_save, EvolveNotebook notebook) {
			EvolveTab tab = (EvolveTab)notebook.get_nth_page(notebook.get_current_page());
			if (tab.saved == false){
				var file_chooser = new FileChooserDialog("Save File", TextFileViewer,
					FileChooserAction.SAVE, "Cancel", ResponseType.CANCEL, "Save", ResponseType.ACCEPT);
				file_chooser.set_local_only(true);
				file_chooser.set_do_overwrite_confirmation(true);
				file_chooser.set_create_folders(true);
				if (file_chooser.run () == ResponseType.ACCEPT){
					try {
						FileUtils.set_contents(file_chooser.get_filename(), text_to_save);
						notebook.set_label(file_chooser.get_current_name());
						tab.save_path = file_chooser.get_filename();
						tab.saved = true;
						tab.set_lang(file_chooser.get_file());
					}
					catch(Error e) {
						stderr.printf("Error: %s\n", e.message);
					}
				}
				else {
					stdout.printf("FileChooserDialog cancelled.");
				}
				file_chooser.destroy();
			}
			else{
				try {
					FileUtils.set_contents(tab.save_path, text_to_save);
				}
				catch(Error e){
					stderr.printf("Error: %s\n", e.message);
				}
			}
		}
	}
}