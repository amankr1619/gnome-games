// This file is part of GNOME Games. License: GPL-3.0+.

[GtkTemplate (ui = "/org/gnome/Games/ui/display-view.ui")]
private class Games.DisplayView: Gtk.Bin, ApplicationView {
	public signal void back ();

	[GtkChild]
	public DisplayBox box;
	[GtkChild]
	public DisplayHeaderBar header_bar;

	public Gtk.Widget titlebar {
		get { return header_bar; }
	}

	private bool _is_view_active;
	public bool is_view_active {
		get { return _is_view_active; }
		set {
			if (is_view_active == value)
				return;

			_is_view_active = value;
		}
	}

	public ApplicationWindow window { get; construct set; }

	public bool on_button_pressed (Gdk.EventButton event) {
		return false;
	}

	public bool on_key_pressed (Gdk.EventKey event) {
		return false;
	}

	public bool gamepad_button_press_event (Manette.Event event) {
		return false;
	}

	public bool gamepad_button_release_event (Manette.Event event) {
		return false;
	}

	public bool gamepad_absolute_axis_event (Manette.Event event) {
		return false;
	}

	[GtkCallback]
	private void on_display_back () {
		back ();
	}
}
