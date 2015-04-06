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
using GLib;

namespace SolusJournal {

private Window TextFileViewer;
private string text_buffer_load;

public class Files {

	public string on_open_clicked (SolusNotebook notebook, bool tab_edited) {
		var file_chooser = new FileChooserDialog("Open File", TextFileViewer,
		FileChooserAction.OPEN, "Cancel", ResponseType.CANCEL,
		"Open", ResponseType.ACCEPT);
		file_chooser.set_select_multiple(true);
		file_chooser.set_local_only(true);
		file_chooser.set_current_folder(get_saved_folder(notebook));
		if (file_chooser.run () == ResponseType.ACCEPT) {
			bool file_open = false;
			foreach (File file in file_chooser.get_files()){
				for (int count = 0; count < notebook.get_n_pages(); count++){
					SolusTab tab = (SolusTab)notebook.get_nth_page(count);
					if (tab.get_save_path() != file.get_path()){

					} else {
						message("File already exists");
						file_open = true;
					}
				}
				if (file_open != true){
					text_buffer_load = open_file (file.get_path ());
					notebook.new_tab(text_buffer_load, true, file.get_path());
					notebook.set_label(file.get_basename());
					file_setup(notebook, file);
				} else {
					message("File is open");
				}
			}
			if (tab_edited == false){
				notebook.remove_tab((SolusTab)notebook.get_nth_page(0));
			}
			else {
				message("First tab edited.");
			}
		}
		else {
			text_buffer_load = null;
		}
		file_chooser.destroy();
		return text_buffer_load;
	}

	public string open_at_start(SolusNotebook notebook, string file_path, string file_name){
		string success = "open_at_start, started!" + "\n";
		text_buffer_load = open_file(file_path);
		notebook.new_tab(text_buffer_load, true, file_path);
		notebook.set_label(file_name);
		File file = File.new_for_path(file_path);
		file_setup(notebook, file);
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

	private void file_setup(SolusNotebook notebook, File file){
		SolusTab tab = (SolusTab)notebook.get_nth_page(notebook.get_current_page());
		tab.set_lang(file);
		tab.set_edited(false);
		tab.set_close_btn_indicator();
		notebook.set_subtitle_text(tab);
		set_saved_folder(notebook, file);
	}

	public void set_saved_folder(SolusNotebook notebook, File file){
		string current_uri = file.get_parent().get_path();
		(notebook.mother.application as SolusJournal.App).set_settings("file-location", current_uri);
	}

	public string get_saved_folder(SolusNotebook notebook){
		return (notebook.mother.application as SolusJournal.App).get_saved_folder();
	}

	public void on_save_clicked(string text_to_save, SolusNotebook notebook, bool save_as) {
		SolusTab tab = (SolusTab)notebook.get_nth_page(notebook.get_current_page());
		if (tab.saved == false || save_as == true) {
			var file_chooser = new FileChooserDialog("Save File", TextFileViewer,
			FileChooserAction.SAVE, "Cancel", ResponseType.CANCEL, "Save", ResponseType.ACCEPT);
			file_chooser.set_local_only(true);
			file_chooser.set_do_overwrite_confirmation(true);
			file_chooser.set_create_folders(true);
			if (file_chooser.run () == ResponseType.ACCEPT){
				try {
					FileUtils.set_contents(file_chooser.get_filename(), text_to_save);
					notebook.set_label(file_chooser.get_current_name());
					tab.save_file(file_chooser.get_file());
					notebook.set_subtitle_text(tab);
				} catch(Error e) {
					stderr.printf("Error: %s\n", e.message);
				}
			} else {
				message("FileChooserDialog cancelled.");
			}
			file_chooser.destroy();
		} else {
			try {
				FileUtils.set_contents(tab.get_save_path(), text_to_save);
				tab.save_file(File.new_for_path(tab.get_save_path()));
				notebook.set_subtitle_text(tab);
			} catch(Error e){
				stderr.printf("Error: %s\n", e.message);
			}
		}
	}
}

} // End namespace
