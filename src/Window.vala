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

namespace SolusJournal {

public string buffer;

private bool file_loaded;

public class SolusWindow : Gtk.ApplicationWindow {

	private Gtk.Button save_button;
	public Gtk.HeaderBar headbar;
	private SolusNotebook notebook;

	public signal void change_scheme(string scheme);


	public SolusWindow (SolusJournal.App application) 
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
        
        	var switchtab1_action = new SimpleAction("switchtab1_action", null);
		switchtab1_action.activate.connect(()=> {
			message("Switching To Tab 1...");
            		notebook.set_current_page(0);
		});
        
        	var switchtab2_action = new SimpleAction("switchtab2_action", null);
		switchtab2_action.activate.connect(()=> {
			message("Switching To Tab 2...");
            		notebook.set_current_page(1);
		});
        
        	var switchtab3_action = new SimpleAction("switchtab3_action", null);
		switchtab3_action.activate.connect(()=> {
			message("Switching To Tab 3...");
            		notebook.set_current_page(2);
		});
        
		var switchtab4_action = new SimpleAction("switchtab4_action", null);
		switchtab4_action.activate.connect(()=> {
			message("Switching To Tab 4...");
            		notebook.set_current_page(3);
		});
        
        	var switchtab5_action = new SimpleAction("switchtab5_action", null);
		switchtab5_action.activate.connect(()=> {
			message("Switching To Tab 5...");
            		notebook.set_current_page(4);
		});
        
        	var switchtab6_action = new SimpleAction("switchtab6_action", null);
		switchtab6_action.activate.connect(()=> {
			message("Switching To Tab 6...");
            		notebook.set_current_page(5);
		});
        
        	var switchtab7_action = new SimpleAction("switchtab7_action", null);
		switchtab7_action.activate.connect(()=> {
			message("Switching To Tab 7...");
            		notebook.set_current_page(6);
		});
        
        	var switchtab8_action = new SimpleAction("switchtab8_action", null);
		switchtab8_action.activate.connect(()=> {
			message("Switching To Tab 8...");
            		notebook.set_current_page(7);
		});
        
        	var switchtab9_action = new SimpleAction("switchtab9_action", null);
		switchtab9_action.activate.connect(()=> {
			message("Switching To Tab 9...");
            		notebook.set_current_page(8);
		});
        
        	var quit_action = new SimpleAction("quit_action", null);
		quit_action.activate.connect(()=> {
			message("Closing...");
            		this.destroy();
        	});

		var show_tabs_action = new PropertyAction("show_tabs_action", application, "show-tabs");

		var about_action = new SimpleAction("about_action", null);
		about_action.activate.connect(()=> {
			queue_draw();
			Idle.add(()=>{
				Gtk.show_about_dialog(this,
					"program-name", "Journal",
					"copyright", "Copyright \u00A9 2015 Ryan Sipes",
					"website", "https://solus-project.com",
					"website-label", "Solus Project",
					"license-type", Gtk.License.GPL_2_0,
					"comments", "A simple text-editor with sharing features.",
					"version", "1.0.1 (Stable)",
					"logo-icon-name", "journal",
					"artists", new string[]{
					  "Alejandro Seoane <asetrigo@gmail.com>"
					},
					"authors", new string[]{
					  "Ryan Sipes <ryan@evolve-os.com>",
					  "Ikey Doherty <ikey@evolve-os.com>",
					  "Barry Smith <barry.of.smith@gmail.com>",
                                          "Michael Rutherford <michaellogan.rutherford@gmail.com>"
					});
				return false;
				});
		});

		var hastebin_action = new SimpleAction("hastebin_action", null);
		hastebin_action.activate.connect(()=> {
			if (notebook.get_n_pages() <= 0){
				message("No pages! \n");
			} else{
				string typed_text = notebook.get_text();
				var share = new SolusJournal.Share();
				share.generate_paste(typed_text, this);
			}
		});
                
		var indentwidth8_action = new SimpleAction("indentwidth8_action", null);
		indentwidth8_action.activate.connect(()=> {
			message("Changing Indent Width...");
                        notebook.get_current_tab().source_view.set_indent_width(8);
		});
                
                var indentwidth4_action = new SimpleAction("indentwidth4_action", null);
		indentwidth4_action.activate.connect(()=> {
			message("Changing Indent Width...");
                        notebook.get_current_tab().source_view.set_indent_width(4);
		});

                var indentwidth2_action = new SimpleAction("indentwidth2_action", null);
		indentwidth2_action.activate.connect(()=> {
			message("Changing Indent Width...");
                        notebook.get_current_tab().source_view.set_indent_width(2);
		});
                
                var indentspaces_action = new SimpleAction("indentspaces_action", null);
		indentspaces_action.activate.connect(()=> {
			message("Changing Tabs To Spaces...");
                        notebook.get_current_tab().source_view.set_insert_spaces_instead_of_tabs(true);
		});
                
		//Set accelerators
		application.set_accels_for_action("app.save_action", {"<Ctrl>S"});
		application.set_accels_for_action("app.open_action", {"<Ctrl>O"});
        	application.set_accels_for_action("app.quit_action", {"<Ctrl>Q"});
                application.set_accels_for_action("app.about_action", {"<Ctrl>A"});
        	application.set_accels_for_action("app.switchtab1_action", {"<Alt>1"});
        	application.set_accels_for_action("app.switchtab2_action", {"<Alt>2"});
        	application.set_accels_for_action("app.switchtab3_action", {"<Alt>3"});
	        application.set_accels_for_action("app.switchtab4_action", {"<Alt>4"});
        	application.set_accels_for_action("app.switchtab5_action", {"<Alt>5"});
	        application.set_accels_for_action("app.switchtab6_action", {"<Alt>6"});
	        application.set_accels_for_action("app.switchtab7_action", {"<Alt>7"});
	        application.set_accels_for_action("app.switchtab8_action", {"<Alt>8"});
	        application.set_accels_for_action("app.switchtab9_action", {"<Alt>9"});
		application.set_accels_for_action("app.undo_action", {"<Ctrl>Z"});
		application.set_accels_for_action("app.redo_action", {"<Shift><Ctrl>Z"});
		application.set_accels_for_action("app.newtab_action", {"<Ctrl>N"});
		application.set_accels_for_action("app.saveas_action", {"<Shift><Ctrl>S"});

		//add actions to the application.
		application.add_action(save_action);
	        application.add_action(quit_action);
		application.add_action(open_action);
		application.add_action(undo_action);
		application.add_action(redo_action);
		application.add_action(print_action);
		application.add_action(saveas_action);
                application.add_action(indentwidth8_action);
                application.add_action(indentwidth4_action);
                application.add_action(indentwidth2_action);
                application.add_action(indentspaces_action);
		application.add_action(newtab_action);
	        application.add_action(switchtab1_action);
	        application.add_action(switchtab2_action);
	        application.add_action(switchtab3_action);
	        application.add_action(switchtab4_action);
	        application.add_action(switchtab5_action);
	        application.add_action(switchtab6_action);
	        application.add_action(switchtab7_action);
	        application.add_action(switchtab8_action);
	        application.add_action(switchtab9_action);
		application.add_action(about_action);
		application.add_action(show_tabs_action);
		application.add_action(hastebin_action);

		//Share Button + Menu
		var share_button = new MenuButton();
		share_button.image = new Image.from_icon_name("emblem-shared-symbolic", IconSize.SMALL_TOOLBAR);
		share_button.set_tooltip_text("Share");
		GLib.Menu share_menu = new GLib.Menu();
		GLib.MenuItem hastebin_item = new GLib.MenuItem("Hastebin", "app.hastebin_action");
		share_menu.append_item(hastebin_item);
		var share_popover = new Popover(share_button);
		share_button.set_use_popover(true);
		share_popover.set_modal(true);
		share_button.set_popover(share_popover);
		share_button.show();
		share_button.set_menu_model(share_menu);

		//Menu button + Menu
		MenuButton menu_button = new MenuButton();
		var popover = new Popover(menu_button);
		popover.set_modal(true);  
		GLib.Menu action_menu = new GLib.Menu();

		GLib.Menu file_menu = new GLib.Menu();
		GLib.MenuItem file_menu_item = new GLib.MenuItem.submenu("File", file_menu);
		action_menu.append_item(file_menu_item);
		GLib.MenuItem saveas_item = new GLib.MenuItem("Save As...", "app.saveas_action");
		GLib.MenuItem quit_item = new GLib.MenuItem("Quit", "app.quit_action");
		file_menu.append_item(saveas_item);
	        file_menu.append_item(quit_item);


		GLib.Menu view_menu = new GLib.Menu();
		GLib.MenuItem view_menu_item = new GLib.MenuItem.submenu("View", view_menu);
		action_menu.append_item(view_menu_item);
		GLib.MenuItem show_tabs_item = new GLib.MenuItem("Always Show Tabs", "app.show_tabs_action");
                GLib.Menu indent_width_menu = new GLib.Menu();
		GLib.MenuItem indent_width_item = new GLib.MenuItem.submenu("Indent", indent_width_menu);
                view_menu.append_item(indent_width_item);
                GLib.MenuItem indentspaces_item = new GLib.MenuItem("Spaces", "app.indentspaces_action");
                GLib.MenuItem width8_item = new GLib.MenuItem("8", "app.indentwidth8_action");
                GLib.MenuItem width4_item = new GLib.MenuItem("4", "app.indentwidth4_action");
                GLib.MenuItem width2_item = new GLib.MenuItem("2", "app.indentwidth2_action");
		view_menu.append_item(show_tabs_item);
                indent_width_menu.append_item(indentspaces_item);
                indent_width_menu.append_item(width8_item);
                indent_width_menu.append_item(width4_item);
                indent_width_menu.append_item(width2_item);


		GLib.Menu appearance_menu = new GLib.Menu();
		GLib.MenuItem appearance_item = new GLib.MenuItem.submenu("Appearance", appearance_menu);
		action_menu.append_item(appearance_item);

		GLib.MenuItem about_item = new GLib.MenuItem("About", "app.about_action");
		action_menu.append_item(about_item);

		string[] schemes = Gtk.SourceStyleSchemeManager.get_default().get_scheme_ids();
		foreach (var scheme in schemes) {
			appearance_menu.append(scheme, "app." + scheme + "_action");
			if ((application as SolusJournal.App).scheme_action_added != true){
				var scheme_action = new SimpleAction(scheme+"_action", null);
				scheme_action.activate.connect(()=> {
					change_action(scheme);
				});
				application.add_action(scheme_action);
			} else {
				message("Actions already exist.");
			}
		}
		(application as SolusJournal.App).scheme_action_added = true;

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
		notebook = new SolusNotebook(this);
	}

	public unowned SolusNotebook get_notebook(){
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
		(application as SolusJournal.App).set_current_scheme(new_scheme);
	}

	public void open_file(SolusNotebook open_notebook){
		bool tab_edited = true;
		//Check if the first tab has been edited if there is only one.
		if (open_notebook.get_n_pages() == 1 && open_notebook.get_label() == "Untitled"){
			tab_edited = false;
		}
		var file = new SolusJournal.Files();
		buffer = file.on_open_clicked(open_notebook, tab_edited);
	}

	public void save_file(SolusNotebook save_notebook, bool save_as){
		if (save_notebook.get_n_pages() <= 0){
			message("No pages! \n");
		} else {
            	var file = new SolusJournal.Files();
            	string typed_text = save_notebook.get_text();
            	file.on_save_clicked(typed_text, save_notebook, save_as);
		}
	}
}

} // End namespace
