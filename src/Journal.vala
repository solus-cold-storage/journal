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

class Application : Gtk.Application{

	public bool window_created;
	public EvolveJournal.EvolveWindow win;
	private File[] loaded_files;

	public Application(){
		Object(application_id:"com.evolve-os.journal", 
			flags:ApplicationFlags.HANDLES_OPEN);
	}

	public override void activate(){
		run_application();	
	}

	public override void open(File[] files, string hint){
		//Load any files requested at startup.
		loaded_files = files;
		run_application();
	}

	public void run_application(){
		if (window_created == false){
			win = new EvolveJournal.EvolveWindow (this);
			window_created = true;

			if (loaded_files != null){
				foreach (File file in loaded_files){
					EvolveJournal.Files file_class = new EvolveJournal.Files();
					file_class.open_at_start(win.get_notebook(), file.get_path(), file.get_basename());	
				}
				win.set_loaded(true);
			}
			else {
				message("No files loaded.");
				win.set_loaded(false);
			}

			win.open_tabs();
			
			win.delete_event.connect((win,e) => { Gtk.main_quit (); return false; });
			win.present ();	

			Gtk.main();
		}
		else {
			win.present();
		}
	}

}

static int main(string[] args){
	return new Application ().run (args);
}