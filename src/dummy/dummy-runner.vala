// This file is part of GNOME Games. License: GPL-3.0+.

private class Games.DummyRunner : Object, Runner {
	public bool can_fullscreen {
		get { return false; }
	}

	public bool can_resume {
		get { return false; }
	}

	public bool supports_savestates {
		get { return false; }
	}

	public bool can_support_savestates {
		get { return false; }
	}

	public MediaSet? media_set {
		get { return null; }
	}

	public InputMode input_mode {
		get { return InputMode.NONE; }
		set { }
	}

	public bool try_init_phase_one (out string error_message) {
		error_message = "";

		return true;
	}

	public Gtk.Widget get_display () {
		return new DummyDisplay ();
	}

	public Gtk.Widget? get_extra_widget () {
		return null;
	}

	public void capture_current_state_pixbuf () {
	}

	public void preview_current_state () {
	}

	public void preview_savestate (Savestate savestate) {
	}

	public void start () throws Error {
	}

	public void resume () {
	}

	public void pause () {
	}

	public void stop () {
	}

	public bool try_create_savestate (bool is_automatic) {
		return false;
	}

	public void load_savestate (Savestate savestate) {
	}

	public Savestate[] get_savestates () {
		return {};
	}

	public InputMode[] get_available_input_modes () {
		return { };
	}

	public bool key_press_event (Gdk.EventKey event) {
		return false;
	}

	public bool gamepad_button_press_event (uint16 button) {
		return false;
	}
}
