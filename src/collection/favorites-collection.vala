// This file is part of GNOME Games. License: GPL-3.0+.

private class Games.FavoritesCollection : Object, Collection {
	private GameModel game_model;

	private Database database;
	private GenericSet<Uid> favorite_game_uids;

	private ulong idle_id = 0;

	construct {
		var game_collection = Application.get_default ().get_collection ();
		game_collection.game_added.connect (on_game_added);
		game_collection.game_removed.connect (on_game_removed);
		game_collection.game_replaced.connect (on_game_replaced);

		favorite_game_uids = new GenericSet<Uid> (Uid.hash, Uid.equal);

		game_model = new GameModel ();
	}

	public FavoritesCollection (Database database) {
		this.database = database;
	}

	public string get_id () {
		return "Favorites";
	}

	public string get_title () {
		return _("Favorites");
	}

	public GameModel get_game_model () {
		return game_model;
	}

	public bool get_hide_stars () {
		return true;
	}

	public void load () {
		try {
			foreach (var uid in database.list_favorite_games ())
				favorite_game_uids.add (new Uid (uid));
		}
		catch (Error e) {
			critical ("Failed to load favorite game uids: %s", e.message);
		}
	}

	public void add_games (Game[] games) {
		foreach (var game in games)
			game.is_favorite = true;
	}

	public void remove_games (Game[] games) {
		foreach (var game in games)
			game.is_favorite = false;
	}

	private void on_is_favorite_changed (Game game) {
		try {
			// Only add/remove games from game_model only if they aren't
			// favorite/non-favorite already. This helps to avoid duplicate
			// thumbnails when using the inspector etc.
			if (database.set_is_favorite (game)) {
				if (game.is_favorite)
					game_model.add_game (game);
				else
					game_model.remove_game (game);

				if (idle_id == 0)
					idle_id = Idle.add (() => {
						games_changed();
						idle_id = 0;
						return Source.REMOVE;
					});
			}
		}
		catch (Error e) {
			critical (e.message);
		}
	}

	public void on_game_added (Game game) {
		game.notify["is-favorite"].connect (() => {
			on_is_favorite_changed (game);
		});

		if (favorite_game_uids.remove (game.uid)) {
			game_model.add_game (game);
			games_changed ();
		}
	}

	public void on_game_removed (Game game) {
		game_model.remove_game (game);
		games_changed ();
	}

	public void on_game_replaced (Game game, Game prev_game) {
		SignalHandler.disconnect_by_data (prev_game, this);
		game.notify["is-favorite"].connect (() => {
			on_is_favorite_changed (game);
		});

		if (prev_game.is_favorite) {
			game.is_favorite = true;
			game_model.replace_game (game, prev_game);
		}
	}
}
