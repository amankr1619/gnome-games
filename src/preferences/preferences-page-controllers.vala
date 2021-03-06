// This file is part of GNOME Games. License: GPL-3.0+.

[GtkTemplate (ui = "/org/gnome/Games/preferences/preferences-page-controllers.ui")]
private class Games.PreferencesPageControllers : PreferencesPage {
	[GtkChild]
	private Hdy.PreferencesGroup gamepads_group;
	[GtkChild]
	private Hdy.PreferencesGroup keyboard_group;

	private Manette.Monitor monitor;

	construct {
		monitor = new Manette.Monitor ();
		monitor.device_connected.connect (rebuild_gamepad_list);
		monitor.device_disconnected.connect (rebuild_gamepad_list);
		build_gamepad_list ();
		build_keyboard_list ();
	}

	private void rebuild_gamepad_list () {
		clear_gamepad_list ();
		build_gamepad_list ();
	}

	private void build_gamepad_list () {
		Manette.Device device = null;
		var i = 0;
		var iterator = monitor.iterate ();

		while (iterator.next (out device)) {
			var row = new Hdy.ActionRow ();
			row.title = device.get_name ();
			row.add (new Gtk.Image.from_icon_name ("go-next-symbolic", Gtk.IconSize.BUTTON));
			row.activatable = true;

			// The original device variable will be overwritten on the
			// next iteration, while this one will remain there and can
			// be used in the event handler.
			var this_device = device;

			row.activated.connect (() => {
				window.open_subpage (new PreferencesSubpageGamepad (this_device));
			});

			row.show_all ();
			gamepads_group.add (row);

			i += 1;
		}

		gamepads_group.visible = i > 0;
	}

	private void clear_gamepad_list () {
		gamepads_group.foreach ((child) => child.destroy ());
	}

	private void build_keyboard_list () {
		var row = new Hdy.ActionRow ();
		row.title = _("Keyboard");
		row.add (new Gtk.Image.from_icon_name ("go-next-symbolic", Gtk.IconSize.BUTTON));
		row.activatable = true;

		row.activated.connect (() => {
			window.open_subpage (new PreferencesSubpageKeyboard ());
		});

		row.show_all ();
		keyboard_group.add (row);
	}
}
