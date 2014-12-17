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

class Application : GLib.Application{

	public string file_to_open;
	public string file_name;
	public int file_count;

	public Application(string[] args){
		Object(application_id:"com.evolve-os.journal", 
			flags:ApplicationFlags.HANDLES_OPEN);
		set_inactivity_timeout(10000);

		var notebook = new EvolveJournal.EvolveNotebook();
		var win = new EvolveJournal.EvolveWindow ();
		win.MainWindow(notebook);

		open_files(notebook);

		win.delete_event.connect((win,e) => { Gtk.main_quit (); return false; });
		win.present ();

	}

	public override void activate() {
		stdout.puts("activated\n");
	}
	
	public override void open(File[] files, string hint){
		if (files == null){
			stdout.printf("No files.");
		}
		else{
			foreach (File file in files){
				file_to_open = file.get_uri();
				stdout.printf(file_to_open + "\n");
				file_name = file.get_basename();
				file_count += 1;
			}
		}	
	}

	public void open_files(EvolveJournal.EvolveNotebook notebook){
		if (file_to_open == null) {
			stdout.printf("open_files could not run, no files to open.\n");
		}
		else{
			EvolveJournal.Files file = new EvolveJournal.Files();
			int i = 0;
			//while(i < file_count){
			file.open_at_start(notebook, file_to_open, file_name);	
			//}
		}
	}

	public void run(){
		Gtk.main();
	}
}

static int main(string[] args){
	Gtk.init(ref args);

	Application application = new Application(args);
	application.run();

	return 0;
}