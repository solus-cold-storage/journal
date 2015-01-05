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

using GLib;

class Application : Gtk.Application{

	public bool window_created;
	public EvolveJournal.EvolveWindow win;
	public EvolveJournal.EvolveNotebook notebook;

	public override void activate(){
		set_notebook();
		notebook = get_notebook();
		notebook.new_tab (notebook.null_buffer, false, "");
		run_application(notebook);	
	}

	public override void open(File[] files, string hint){
		if (window_created != true){
			set_notebook();
		}
		//Load any files requested at startup.
		notebook = get_notebook();
		foreach (File file in files){
			EvolveJournal.Files file_class = new EvolveJournal.Files();
			file_class.open_at_start(notebook, file.get_path(), file.get_basename());	
		}
		run_application(notebook);
	}

	public Application(){
		Object(application_id:"com.evolve-os.journal", 
			flags:ApplicationFlags.HANDLES_OPEN);
	}

	public void set_notebook(){
		notebook = new EvolveJournal.EvolveNotebook();
	}

	public EvolveJournal.EvolveNotebook get_notebook(){
		return notebook;
	}

	public void run_application(EvolveJournal.EvolveNotebook notebook){
		if (window_created == false){
			var win = new EvolveJournal.EvolveWindow ();
			win.MainWindow(notebook);
			window_created = true;
			
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