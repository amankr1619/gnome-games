// This file is part of GNOME Games. License: GPL-3.0+.

private class Games.RetroSimpleGameUriAdapter : GameUriAdapter, Object {
	private RetroSimpleType simple_type;
	private RetroPlatform platform;

	public RetroSimpleGameUriAdapter (RetroSimpleType simple_type, RetroPlatform platform) {
		this.simple_type = simple_type;
		this.platform = platform;
	}

	public async Game game_for_uri (Uri uri) throws Error {
		Idle.add (this.game_for_uri.callback);
		yield;

		var uid = new FingerprintUid (uri, simple_type.prefix);
		var title = new FilenameTitle (uri);
		var media = new GriloMedia (title, simple_type.mime_type);
		var cover = new CompositeCover ({
			new LocalCover (uri),
			new GriloCover (media, uid)});
		var release_date = new GriloReleaseDate (media);
		var developer = new GriloDeveloper (media);
		var core_source = new RetroCoreSource (platform);

		var builder = new RetroRunnerBuilder ();
		builder.core_source = core_source;
		builder.uri = uri;
		builder.uid = uid;
		builder.title = title;
		var runner = builder.to_runner ();

		var game = new GenericGame (uid, title, platform, runner);
		game.set_cover (cover);
		game.set_release_date (release_date);
		game.set_developer (developer);

		return game;
	}
}
