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

	public override void activate(){
		EvolveJournal.EvolveNotebook notebook = get_notebook();
		run_application(notebook);	
	}

	public override void open(File[] files, string hint){
		foreach (File file in files){
			EvolveJournal.EvolveNotebook notebook = get_notebook();
			EvolveJournal.Files file_class = new EvolveJournal.Files();
			file_class.open_at_start(notebook, file.get_path(), file.get_basename());	
			run_application(notebook);
		}
	}

	public Application(){
		Object(application_id:"com.evolve-os.journal", 
			flags:ApplicationFlags.HANDLES_OPEN);
	}

	public EvolveJournal.EvolveNotebook get_notebook(){
		var notebook = new EvolveJournal.EvolveNotebook();
		return notebook;
	}

	public void run_application(EvolveJournal.EvolveNotebook notebook){
		var win = new EvolveJournal.EvolveWindow ();
		win.MainWindow(notebook);

		win.delete_event.connect((win,e) => { Gtk.main_quit (); return false; });
		win.present ();	

		Gtk.main();
	}

}

static int main(string[] args){
	return new Application ().run (args);
}