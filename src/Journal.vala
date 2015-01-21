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
	
	public void save_temp()
	{
		stdout.printf("SAVE CODE");
	}
	
    	private const string SAVE_NAME = "save";
    	
    	private const ActionEntry[] window_entries =
    	{
        	{ SAVE_NAME, save_temp},
    	};

	public Application(){
		Object(application_id:"com.evolve-os.journal", 
			flags:ApplicationFlags.HANDLES_OPEN);
	}

	public override void activate(){
		set_notebook();
		notebook = get_notebook();
		notebook.new_tab (notebook.null_buffer, false, "");
		//string accels = ;
		
		//set_accels_for_action("win."+, "<Control>s");
               /*const Accel[] single_accels = {
                        {"app.new", "<Primary>N",},
                        {"app.quit", "<Primary>Q"},
                        {"app.help", "F1"},
 
                        {"win.search", "<Primary>F"},
                        {"win.gear-menu", "F10"},
                        {"win.open-repository", "<Primary>O"},
                        {"win.close", "<Primary>W"}
                };*/
                
                stdout.printf ("...Before set_accels...\n");
                win.add_action_entries (window_entries, this);
		set_accels_for_action("win."+SAVE_NAME,{"<Control>S"});
		win.enable_window_action (SAVE_NAME);
		stdout.printf ("...After...\n");
		
		run_application(notebook);
		stdout.printf ("...Program End\n");
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

	public void set_notebook(){
		notebook = new EvolveJournal.EvolveNotebook();
	}

	public EvolveJournal.EvolveNotebook get_notebook(){
		return notebook;
	}

	public void run_application(EvolveJournal.EvolveNotebook notebook){
		if (window_created == false){
			var win = new EvolveJournal.EvolveWindow ();
			win.MainWindow(notebook, this);
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
