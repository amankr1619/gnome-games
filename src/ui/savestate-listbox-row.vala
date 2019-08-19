// This file is part of GNOME Games. License: GPL-3.0+.

[GtkTemplate (ui = "/org/gnome/Games/ui/savestate-listbox-row.ui")]
private class Games.SavestateListBoxRow : Gtk.ListBoxRow {
	public const int THUMBNAIL_SIZE = 64;

	[GtkChild]
	private Gtk.DrawingArea image;
	[GtkChild]
	private Gtk.Label name_label;
	[GtkChild]
	private Gtk.Label date_label;
	[GtkChild]
	private Gtk.Revealer revealer;

	private Savestate _savestate;
	public Savestate savestate {
		get { return _savestate; }
		set {
			_savestate = value;

			if (savestate.is_automatic ())
				name_label.label = _("Autosave");
			else
				name_label.label = savestate.get_name ();

			var creation_date = savestate.get_creation_date ();

			/* Translators: this is the day number followed
             * by the abbreviated month name followed by the year followed
             * by a time in 24h format i.e. "3 Feb 2015 23:04:00" */
            /* xgettext:no-c-format */
			date_label.label = creation_date.format (_("%-e %b %Y %X"));

			load_thumbnail ();
		}
	}

	private Gdk.Pixbuf pixbuf;

	construct {
		image.set_draw_func (draw_image);
	}

	public SavestateListBoxRow (Savestate savestate) {
		Object (savestate: savestate);
	}

	private void load_thumbnail () {
		if (savestate == null)
			return;

		var screenshot_path = savestate.get_screenshot_path ();
		var screenshot_width = 0;
		var screenshot_height = 0;

		Gdk.Pixbuf.get_file_info (screenshot_path, out screenshot_width, out screenshot_height);

		var aspect_ratio = (double) savestate.get_screenshot_aspect_ratio ();

		// A fallback for migrated savestates
		if (aspect_ratio == 0)
			aspect_ratio = (double) screenshot_width / screenshot_height;

		var thumbnail_width = screenshot_width;
		var thumbnail_height = (int) (screenshot_width / aspect_ratio);

		if (thumbnail_width > thumbnail_height) {
			thumbnail_width = THUMBNAIL_SIZE;
			thumbnail_height = (int) (THUMBNAIL_SIZE / aspect_ratio);
		}
		else {
			thumbnail_height = THUMBNAIL_SIZE;
			thumbnail_width = (int) (THUMBNAIL_SIZE * aspect_ratio);
		}

		thumbnail_width *= scale_factor;
		thumbnail_height *= scale_factor;

		try {
			pixbuf = new Gdk.Pixbuf.from_file_at_scale (screenshot_path,
			                                            thumbnail_width,
			                                            thumbnail_height,
			                                            false);
		}
		catch (Error e) {
			warning ("Failed to load savestate thumbnail: %s", e.message);
		}
	}

	[GtkCallback]
	private void on_scale_factor_changed () {
		load_thumbnail ();
	}

	public void set_name (string name) {
		name_label.label = name;
		savestate.set_name (name);
	}

	public void reveal () {
		revealer.reveal_child = true;
	}

	public void remove_animated () {
		selectable = false;
		revealer.notify["child-revealed"].connect(() => {
//			get_parent ().remove (this);
		});
		revealer.reveal_child = false;
	}

	public void draw_image (Gtk.DrawingArea area, Cairo.Context cr, int width, int height) {
		cr.save ();
		cr.scale (1.0 / scale_factor, 1.0 / scale_factor);

		var mask = get_mask (width, height);

		var x_offset = (width * scale_factor - pixbuf.width) / 2;
		var y_offset = (height * scale_factor - pixbuf.height) / 2;

		Gdk.cairo_set_source_pixbuf (cr, pixbuf, x_offset, y_offset);

		cr.mask_surface (mask, 0, 0);

		cr.restore ();
	}

	// TODO: Share this with GameThumbnail
	private Cairo.Surface get_mask (int width, int height) {
		var mask = new Cairo.ImageSurface (Cairo.Format.A8, width * scale_factor, height * scale_factor);

		var style = image.get_style_context ();
		var border_radius = (int) style.get_property (Gtk.STYLE_PROPERTY_BORDER_RADIUS);
		border_radius = border_radius.clamp (0, int.max (width / 2, height / 2));

		var cr = new Cairo.Context (mask);
		cr.scale (scale_factor, scale_factor);
		cr.set_source_rgb (0, 0, 0);
		rounded_rectangle (cr, 0.5, 0.5, width - 1, height - 1, border_radius);
		cr.fill ();

		return mask;
	}

	// TODO: Share this with GameThumbnail
	private void rounded_rectangle (Cairo.Context cr, double x, double y, double width, double height, double radius) {
		const double ARC_0 = 0;
		const double ARC_1 = Math.PI * 0.5;
		const double ARC_2 = Math.PI;
		const double ARC_3 = Math.PI * 1.5;

		cr.new_sub_path ();
		cr.arc (x + width - radius, y + radius,	         radius, ARC_3, ARC_0);
		cr.arc (x + width - radius, y + height - radius, radius, ARC_0, ARC_1);
		cr.arc (x + radius,         y + height - radius, radius, ARC_1, ARC_2);
		cr.arc (x + radius,         y + radius,          radius, ARC_2, ARC_3);
		cr.close_path ();
	}
}

