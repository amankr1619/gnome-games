// This file is part of GNOME Games. License: GPLv3

private class Games.MameTrackerQuery : MimeTypeTrackerQuery {
	public override string get_mime_type () {
		return "application/zip";
	}

	public override Game game_for_uri (string uri) throws Error {
		return new MameGame (uri);
	}
}
