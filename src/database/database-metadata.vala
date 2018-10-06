// This file is part of GNOME Games. License: GPL-3.0+.

private class Games.DatabaseMetadata : Object {
	private const string LOAD_QUERY = """
		SELECT
			cooperative,
			description,
			developer,
			genre
		FROM game_metadata WHERE uid=$UID;
	""";

	private const string ADD_GAME_QUERY = """
		INSERT OR IGNORE INTO game_metadata (uid) VALUES ($UID);
	""";

	private const string SAVE_COOPERATIVE_QUERY = """
		UPDATE game_metadata SET cooperative=$COOPERATIVE WHERE uid=$UID;
	""";

	private const string SAVE_DESCRIPTION_QUERY = """
		UPDATE game_metadata SET description=$DESCRIPTION WHERE uid=$UID;
	""";

	private const string SAVE_DEVELOPER_QUERY = """
		UPDATE game_metadata SET developer=$DEVELOPER WHERE uid=$UID;
	""";

	private const string SAVE_GENRE_QUERY = """
		UPDATE game_metadata SET genre=$GENRE WHERE uid=$UID;
	""";

	private Game game;
	private Uid uid;
	private Cooperative cooperative;
	private Description description;
	private Developer developer;
	private Genre genre;

	private string uid_value;
	private bool cooperative_value;
	private string description_value;
	private string developer_value;
	private string[] genre_value;

	private Sqlite.Statement add_game_statement;
	private Sqlite.Statement load_statement;
	private Sqlite.Statement save_cooperative_statement;
	private Sqlite.Statement save_description_statement;
	private Sqlite.Statement save_developer_statement;
	private Sqlite.Statement save_genre_statement;

	public bool cooperative_loaded { get; set; }
	public bool description_loaded { get; set; }
	public bool developer_loaded { get; set; }
	public bool genre_loaded { get; set; }

	private bool game_added;

	public DatabaseMetadata (Sqlite.Database database, Game game) {
		this.game = game;

		uid = game.get_uid ();
		cooperative = game.get_cooperative ();
		description = game.get_description ();
		developer = game.get_developer ();
		genre = game.get_genre ();

		try {
			uid_value = game.get_uid ().get_uid ();

			add_game_statement = Database.prepare (database, ADD_GAME_QUERY);
			load_statement = Database.prepare (database, LOAD_QUERY);
			save_cooperative_statement = Database.prepare (database, SAVE_COOPERATIVE_QUERY);
			save_description_statement = Database.prepare (database, SAVE_DESCRIPTION_QUERY);
			save_developer_statement = Database.prepare (database, SAVE_DEVELOPER_QUERY);
			save_genre_statement = Database.prepare (database, SAVE_GENRE_QUERY);

			load_metadata ();
		}
		catch (Error e) {
			warning (e.message);
		}
	}

	public bool get_cooperative () {
		if (!cooperative_loaded) {
			on_cooperative_loaded ();
			cooperative.notify.connect (on_cooperative_loaded);
			return cooperative.get_cooperative ();
		}

		return cooperative_value;
	}

	public string get_description () {
		if (!description_loaded) {
			on_description_loaded ();
			description.notify.connect (on_description_loaded);
			return description.get_description ();
		}

		return description_value;
	}

	public string get_developer () {
		if (!developer_loaded) {
			on_developer_loaded ();
			developer.notify.connect (on_developer_loaded);
			return developer.get_developer ();
		}

		return developer_value;
	}

	public unowned string[] get_genre () {
		if (!genre_loaded) {
			on_genre_loaded ();
			genre.notify.connect (on_genre_loaded);
			return genre.get_genre ();
		}

		return genre_value;
	}

	private void on_cooperative_loaded () {
		if (!cooperative.has_loaded)
			return;

		cooperative_value = cooperative.get_cooperative ();
		cooperative_loaded = true;

		add_game ();
		save_cooperative ();
	}

	private void on_description_loaded () {
		if (!description.has_loaded)
			return;

		description_value = description.get_description ();
		description_loaded = true;

		add_game ();
		save_description ();
	}

	private void on_developer_loaded () {
		if (!developer.has_loaded)
			return;

		developer_value = developer.get_developer ();
		developer_loaded = true;

		add_game ();
		save_developer ();
	}

	private void on_genre_loaded () {
		if (!genre.has_loaded)
			return;

		genre_value = genre.get_genre ().copy ();
		genre_loaded = true;

		add_game ();
		save_genre ();
	}

	private void save_cooperative () {
		try {
			save_cooperative_statement.reset ();
			Database.bind_text (save_cooperative_statement, "$UID", uid_value);
			Database.bind_int (save_cooperative_statement, "$COOPERATIVE", cooperative_value ? 1 : 0);

			if (save_cooperative_statement.step () != Sqlite.DONE)
				warning ("Execution failed.");
		}
		catch (Error e) {
			warning (e.message);
		}
	}

	private void save_description () {
		try {
			save_description_statement.reset ();
			Database.bind_text (save_description_statement, "$UID", uid_value);
			Database.bind_text (save_description_statement, "$DESCRIPTION", description_value);

			if (save_description_statement.step () != Sqlite.DONE)
				warning ("Execution failed.");
		}
		catch (Error e) {
			warning (e.message);
		}
	}

	private void save_developer () {
		try {
			save_developer_statement.reset ();
			Database.bind_text (save_developer_statement, "$UID", uid_value);
			Database.bind_text (save_developer_statement, "$DEVELOPER", developer_value);

			if (save_developer_statement.step () != Sqlite.DONE)
				warning ("Execution failed.");
		}
		catch (Error e) {
			warning (e.message);
		}
	}

	private void save_genre () {
		try {
			var variant = new Variant.strv (genre_value);
			var string_value = variant.print (false);

			save_genre_statement.reset ();
			Database.bind_text (save_genre_statement, "$UID", uid_value);
			Database.bind_text (save_genre_statement, "$GENRE", string_value);

			if (save_genre_statement.step () != Sqlite.DONE)
				warning ("Execution failed.");
		}
		catch (Error e) {
			warning (e.message);
		}
	}

	private void add_game () {
		if (game_added)
			return;

		game_added = true;

		try {
			add_game_statement.reset ();

			Database.bind_text (add_game_statement, "$UID", uid_value);

			if (add_game_statement.step () != Sqlite.DONE)
				warning ("Execution failed.");
		}
		catch (Error e) {
			warning (e.message);
		}
	}

	private void load_metadata () throws Error {
		load_statement.reset ();

		Database.bind_text (load_statement, "$UID", uid_value);

		if (load_statement.step () == Sqlite.ROW) {
			if (load_statement.column_type (0) != Sqlite.NULL) {
				cooperative_value = load_statement.column_int (0) == 1;
				cooperative_loaded = true;
			}

			if (load_statement.column_type (1) != Sqlite.NULL) {
				description_value = load_statement.column_text (1);
				description_loaded = true;
			}

			if (load_statement.column_type (2) != Sqlite.NULL) {
				developer_value = load_statement.column_text (2);
				developer_loaded = true;
			}

			if (load_statement.column_type (3) != Sqlite.NULL) {
				var string_value = load_statement.column_text (3);
				var variant = Variant.parse (VariantType.STRING_ARRAY, string_value);
				genre_value = variant.get_strv ();

				genre_loaded = true;
			}
		}
	}
}
