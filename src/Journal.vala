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

using GLib;

namespace SolusJournal{

public class App : Gtk.Application{

	private bool window_created = false;
	private File[] loaded_files;
	public bool scheme_action_added;
	private string current_scheme;
	private Settings settings;

	public bool show_tabs { public set; public get; default = false; }

	public App() {
		Object(application_id:"com.solus-project.journal", 
			flags:ApplicationFlags.HANDLES_OPEN);
		settings = new Settings("com.solus-project.journal");
		on_settings_change("scheme");
	}

	public override void activate(){
		run_application();	
	}

	//Global Setters and Getters

	public void set_current_scheme(string scheme){
		current_scheme = scheme;
		this.get_windows().foreach((win)=>{
			(win as SolusJournal.SolusWindow).change_scheme(scheme);
		});
		set_settings("scheme", scheme);
	}

	public string get_current_scheme(){
		return current_scheme;
	}

	public void set_settings(string key, string val){
		settings.set_string(key, val);
	}

	public string get_saved_folder(){
		return settings.get_string("file-location");
	}

	public void set_window_settings(string key, int val){
		settings.set_int(key, val);
	}

	public int get_window_settings(string key){
		return settings.get_int(key);
	}

	protected void on_settings_change(string key){
		if (key == "scheme"){
			var val = settings.get_string(key);
			set_current_scheme(val);
		}
	}

	public override void open(File[] files, string hint){
		//Load any files requested at startup.
		loaded_files = files;
		if (window_created == false){
			run_application();
		}
		else {
			foreach (File file in loaded_files){
				SolusJournal.Files file_class = new SolusJournal.Files();
				var active_win = (SolusWindow)this.get_active_window();
				file_class.open_at_start(active_win.get_notebook(), file.get_path(), file.get_basename());
			}
		}
	}

	public SolusWindow create_window(){
		SolusWindow new_window = new SolusWindow(this);
		return new_window;
	}

	public void run_application(){
		SolusWindow first_window = create_window();

		if (loaded_files != null){
			foreach (File file in loaded_files){
				SolusJournal.Files file_class = new SolusJournal.Files();
				file_class.open_at_start(first_window.get_notebook(), file.get_path(), file.get_basename());	
			}
			first_window.set_loaded(true);
		}
		else {
			message("No files loaded.");
			first_window.set_loaded(false);
		}

			first_window.open_tabs();
			first_window.present ();	
			window_created = true;
		}
	}

} // End namespace

static int main(string[] args){
	return new SolusJournal.App ().run (args);
}
