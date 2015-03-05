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

using Gtk;

namespace EvolveJournal {

public string buffer;

private bool file_loaded;

public class EvolveWindow : Gtk.ApplicationWindow {

	private Gtk.Button save_button;
	public Gtk.HeaderBar headbar;
	private EvolveNotebook notebook;

	public signal void change_scheme(string scheme);

	public EvolveWindow (EvolveJournal.App application) 
	{
		Object(application: application);

		//Save settings before quitting.
		this.delete_event.connect(()=>{
			int width, height;
			this.get_size(out width, out height);
			application.set_window_settings("window-width", width);
			application.set_window_settings("window-height", height);
			return false;
			});

		this.window_position = WindowPosition.CENTER;
		set_default_size (application.get_window_settings("window-width"), 
			application.get_window_settings("window-height"));

		headbar = new HeaderBar();
		headbar.set_title("Journal");
		headbar.set_show_close_button(true);
		this.set_titlebar(headbar);

		set_notebook();

		var new_button = new Button.from_icon_name("tab-new-symbolic", IconSize.SMALL_TOOLBAR);
		headbar.add (new_button);
		new_button.show();
		new_button.set_tooltip_text("New Tab");
		new_button.clicked.connect(()=> {
			notebook.new_tab(notebook.null_buffer, false, "");
		});

		var open_button = new Button.from_icon_name("document-open-symbolic", IconSize.SMALL_TOOLBAR);
		headbar.add (open_button);
		open_button.show();
		open_button.set_tooltip_text("Open");
		open_button.clicked.connect (() => {
			open_file(notebook);
		});

		var share_button = new Button.from_icon_name("emblem-shared-symbolic", IconSize.SMALL_TOOLBAR);
		share_button.show();
		share_button.set_tooltip_text("Share");
		share_button.clicked.connect (() => {
			if (notebook.get_n_pages() <= 0){
				message("No pages! \n");
			} else{
				string typed_text = notebook.get_text();
				var share = new EvolveJournal.Share();
				share.generate_paste(typed_text, this);
			}
		});

		save_button = new Button.from_icon_name("document-save-symbolic", IconSize.SMALL_TOOLBAR);
		headbar.add (save_button);
		save_button.show();
		save_button.set_tooltip_text("Save");
		save_button.clicked.connect (() => {
			save_file(notebook, false);
		});

		//Define actions.
		var save_action = new SimpleAction("save_action", null);
		save_action.activate.connect(()=> {
			message("Saving...");
			save_file(notebook, false);
		});

		var open_action = new SimpleAction("open_action", null);
		open_action.activate.connect(()=> {
			message("Opening...");
			open_file(notebook);
		});

		var undo_action = new SimpleAction("undo_action", null);
		undo_action.activate.connect(()=> {
			message("Undo...");
			notebook.undo_source();
		});

		var redo_action = new SimpleAction("redo_action", null);
		redo_action.activate.connect(()=> {
			message("Redo...");
			notebook.redo_source();
		});

		var print_action = new SimpleAction("print_action", null);
		print_action.activate.connect(()=> {
			message("Printing...");
			Gtk.PrintOperation print_operation = new Gtk.PrintOperation();
			try {
				print_operation.run(Gtk.PrintOperationAction.PRINT_DIALOG, this);
			} catch (Error e) {
				warning("Error printing: %s", e.message);
			}
		});

		var saveas_action = new SimpleAction("saveas_action", null);
		saveas_action.activate.connect(()=> {
			message("Saving As...");
			save_file(notebook, true);
		});

		var newtab_action = new SimpleAction("newtab_action", null);
		newtab_action.activate.connect(()=> {
			message("Generating Tab...");
			notebook.new_tab(notebook.null_buffer, false, "");
		});

		var show_tabs_action = new PropertyAction("show_tabs_action", application, "show-tabs");

		var about_action = new SimpleAction("about_action", null);
		about_action.activate.connect(()=> {
			queue_draw();
			Idle.add(()=>{
				Gtk.show_about_dialog(this,
					"program-name", "Journal",
					"copyright", "Copyright \u00A9 2015 Ryan Sipes",
					"website", "https://evolve-os.com",
					"website-label", "Evolve OS",
					"license-type", Gtk.License.GPL_2_0,
					"comments", "A simple text-editor with sharing features.",
					"version", "1.0 (Stable)",
					"logo-icon-name", "journal",
					"artists", new string[]{
					  "Alejandro Seoane <asetrigo@gmail.com>"
					},
					"authors", new string[]{
					  "Ryan Sipes <ryan@evolve-os.com>",
					  "Ikey Doherty <ikey@evolve-os.com>",
					  "Barry Smith <barry.of.smith@gmail.com>"
					});
				return false;
				});
		});

		//Set accelerators
		application.set_accels_for_action("app.save_action", {"<Ctrl>S"});
		application.set_accels_for_action("app.open_action", {"<Ctrl>O"});
		application.set_accels_for_action("app.undo_action", {"<Ctrl>Z"});
		application.set_accels_for_action("app.redo_action", {"<Shift><Ctrl>Z"});
		application.set_accels_for_action("app.newtab_action", {"<Ctrl>N"});
		application.set_accels_for_action("app.saveas_action", {"<Shift><Ctrl>S"});

		//add actions to the application.
		application.add_action(save_action);
		application.add_action(open_action);
		application.add_action(undo_action);
		application.add_action(redo_action);
		application.add_action(print_action);
		application.add_action(saveas_action);
		application.add_action(newtab_action);
		application.add_action(about_action);
		application.add_action(show_tabs_action);

		//Menu button + Menu
		MenuButton menu_button = new MenuButton();
		var popover = new Popover(menu_button);
		popover.set_modal(true);  
		GLib.Menu action_menu = new GLib.Menu();

		GLib.Menu file_menu = new GLib.Menu();
		GLib.MenuItem file_menu_item = new GLib.MenuItem.submenu("File", file_menu);
		action_menu.append_item(file_menu_item);
		GLib.MenuItem saveas_item = new GLib.MenuItem("Save As...", "app.saveas_action");
		file_menu.append_item(saveas_item);

		GLib.Menu view_menu = new GLib.Menu();
		GLib.MenuItem view_menu_item = new GLib.MenuItem.submenu("View", view_menu);
		action_menu.append_item(view_menu_item);
		GLib.MenuItem show_tabs_item = new GLib.MenuItem("Always Show Tabs", "app.show_tabs_action");
		view_menu.append_item(show_tabs_item);

		GLib.Menu appearance_menu = new GLib.Menu();
		GLib.MenuItem appearance_item = new GLib.MenuItem.submenu("Appearance", appearance_menu);
		action_menu.append_item(appearance_item);

		GLib.MenuItem about_item = new GLib.MenuItem("About", "app.about_action");
		action_menu.append_item(about_item);

		string[] schemes = Gtk.SourceStyleSchemeManager.get_default().get_scheme_ids();
		foreach (var scheme in schemes) {
			appearance_menu.append(scheme, "app." + scheme + "_action");
			if ((application as EvolveJournal.App).scheme_action_added != true){
				var scheme_action = new SimpleAction(scheme+"_action", null);
				scheme_action.activate.connect(()=> {
					change_action(scheme);
				});
				application.add_action(scheme_action);
			} else {
				message("Actions already exist.");
			}
		}
		(application as EvolveJournal.App).scheme_action_added = true;

		menu_button.image = new Image.from_icon_name("open-menu-symbolic", IconSize.SMALL_TOOLBAR);
		menu_button.set_use_popover(true);
		menu_button.set_popover(popover);
		menu_button.show();
		menu_button.set_menu_model(action_menu);
		headbar.pack_end (menu_button);
		headbar.pack_end (share_button);

		var vbox = new Box (Orientation.VERTICAL, 0);

		vbox.pack_start(notebook, true, true, 0);
		vbox.show_all();
		this.add (vbox);
		notebook.show_all();
		headbar.show_all();
	}

	public void set_notebook(){
		notebook = new EvolveNotebook(this);
	}

	public unowned EvolveNotebook get_notebook(){
		return notebook;
	}

	public void set_loaded(bool loaded){
	file_loaded = loaded;
	}

	public void open_tabs (){
		if (file_loaded != true){
			notebook.new_tab (notebook.null_buffer, false, "");
		} else {
			message("File already loaded.");
		}
	}

	public Gtk.HeaderBar get_headerbar(){
		return headbar;
	}

	public Button get_save_button(){
		return save_button;
	}

	private void change_action(string new_scheme){
		this.change_scheme(new_scheme);
		(application as EvolveJournal.App).set_current_scheme(new_scheme);
	}

	public void open_file(EvolveNotebook open_notebook){
		bool tab_edited = true;
		//Check if the first tab has been edited if there is only one.
		if (open_notebook.get_n_pages() == 1 && open_notebook.get_text() == ""){
			tab_edited = false;
		}
		var file = new EvolveJournal.Files();
		buffer = file.on_open_clicked(open_notebook, tab_edited);
	}

	public void save_file(EvolveNotebook save_notebook, bool save_as){
		if (save_notebook.get_n_pages() <= 0){
			message("No pages! \n");
		} else {
		var file = new EvolveJournal.Files();
		string typed_text = save_notebook.get_text();
		file.on_save_clicked(typed_text, save_notebook, save_as);
		}
	}
}

} // End namespace