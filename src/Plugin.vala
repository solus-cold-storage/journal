/* Copyright 2014 John Hamernick-Ramseier
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
*
* JPI = Journal Programming Interface
*/


namespace SolusJournal{
 public class API : GLib.Object
    {
        public App app;

        public API (App app)
        {
            this.app = app;
        }

    }

    public class SolusPluginManager
    {
        private App app;
        Peas.Engine engine;
        Peas.ExtensionSet exts;

        public API plugin_iface { private set; public get; }

        public SolusPluginManager (App app)
        {
            this.app = app;
            plugin_iface = new API (app);

            engine = Peas.Engine.get_default ();
            engine.enable_loader ("python");
            engine.enable_loader ("gjs");
            engine.add_search_path (".", null);

            /* Our extension set */
            Parameter param = Parameter();
            param.value = plugin_iface;
            param.name = "object";
            exts = new Peas.ExtensionSet (engine, typeof(Peas.Activatable), "object", plugin_iface, null);
            // Load all the plugins found
            foreach (var plug in engine.get_plugin_list ()) {
                if (engine.try_load_plugin (plug)) {
                    debug ("Plugin Loaded:" +plug.get_name ());
                } else {
                    warning ("Could not load plugin:" +plug.get_name ());
                }
            }

            exts.extension_removed.connect(on_extension_removed);
            exts.foreach (extension_foreach);

        }


        void extension_foreach (Peas.ExtensionSet set, Peas.PluginInfo info, Peas.Extension extension) {
            debug ("Extension added");
            ((Peas.Activatable) extension).activate ();
        }

        void on_extension_removed (Peas.PluginInfo info, Object extension) {
            ((Peas.Activatable) extension).deactivate ();
        }
    }
}//end of namespace
