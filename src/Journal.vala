/* Copyright 2014 Ryan Sipes
*
* This file is part of Evolve Journal.
*
* Evolve Journal is free software: you can redistribute it
* and/or modify it under the terms of the GNU General Public License as
* published by the Free Software Foundation, either version 2 of the
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

using GLib;

namespace EvolveJournal{

public class App : Gtk.Application{

	public bool window_created;
	public DynamicList<EvolveJournal.EvolveWindow> wins;
	private File[] loaded_files;
	public bool scheme_action_added;
	private string current_scheme;

	public bool show_tabs { public set; public get; default = true; }

	public App() {
		Object(application_id:"com.evolve-os.journal", 
			flags:ApplicationFlags.HANDLES_OPEN);
		this.wins = new DynamicList<EvolveJournal.EvolveWindow>();
	}

	public override void activate(){
		run_application();	
	}

	//Global Setters and Getters

	public void set_current_scheme(string scheme){
		current_scheme = scheme;
		for (int count = 0; count < wins.length; count++){
			wins[count].change_scheme(scheme);
		}
	}

	public string get_current_scheme(){
		return current_scheme;
	}

	public override void open(File[] files, string hint){
		//Load any files requested at startup.
		loaded_files = files;
		run_application();
	}

	public void run_application(){
		if (window_created == false){
			this.wins.add(new EvolveJournal.EvolveWindow (this));
			window_created = true;

			if (loaded_files != null){
				foreach (File file in loaded_files){
					EvolveJournal.Files file_class = new EvolveJournal.Files();
					file_class.open_at_start(wins[0].get_notebook(), file.get_path(), file.get_basename());	
				}
				wins[0].set_loaded(true);
			}
			else {
				message("No files loaded.");
				wins[0].set_loaded(false);
			}

			wins[0].open_tabs();
			
			wins[0].delete_event.connect((win, e) => { Gtk.main_quit (); return false; });
			wins[0].present ();	

			Gtk.main();
		}
		else {
			wins[0].present();
		}
	}

}

} // End namespace

static int main(string[] args){
	return new EvolveJournal.App ().run (args);
}
