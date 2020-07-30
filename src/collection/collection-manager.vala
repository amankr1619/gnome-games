// This file is part of GNOME Games. License: GPL-3.0+.

private class Games.CollectionManager : Object {
	public signal void collection_added (Collection collection);
	public signal void collection_removed (Collection collection);
	public signal void collection_empty_changed (Collection collection);

	private HashTable<string, Collection> collections;
	private Database database;

	private FavoritesCollection favorites_collection;
	private RecentlyPlayedCollection recently_played_collection;

	public CollectionManager (Database database) {
		this.database = database;
		collections = new HashTable<string, Collection> (str_hash, str_equal);

		add_favorites_collection ();
		add_recently_played_collection ();

		collections.foreach ((key, val) => {
			val.load ();
		});
	}

	public void toggle_favorite (Game[] games) {
		var is_all_favorite = true;
		foreach (var game in games) {
			if (!game.is_favorite) {
				is_all_favorite = false;
				break;
			}
		}

		if (is_all_favorite)
			favorites_collection.remove_games (games);
		else
			favorites_collection.add_games (games);
	}

	private void add_favorites_collection () {
		favorites_collection = new FavoritesCollection (database);
		favorites_collection.notify["is-empty"].connect (() => {
			Idle.add (() => {
				collection_empty_changed (favorites_collection);
				return Source.REMOVE;
			});
		});
		collections[favorites_collection.get_id ()] = favorites_collection;
		Idle.add (() => {
			collection_added (favorites_collection);
			return Source.REMOVE;
		});
	}

	private void add_recently_played_collection () {
		recently_played_collection = new RecentlyPlayedCollection (database);
		recently_played_collection.notify["is-empty"].connect (() => {
			Idle.add (() => {
				collection_empty_changed (recently_played_collection);
				return Source.REMOVE;
			});
		});
		collections[recently_played_collection.get_id ()] = recently_played_collection;
		Idle.add (() => {
			collection_added (recently_played_collection);
			return Source.REMOVE;
		});
	}
}
