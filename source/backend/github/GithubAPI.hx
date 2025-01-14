package backend.github;

#if GITHUB_ALLOWED
import haxe.Json;
import haxe.Http;
import haxe.Exception;

class GithubAPI {
    public static function getLatestCommits():String {
        var sha_id:GithubCommits = getCommits("VsFoxaDevs", "VsFoxa")[0];
        return sha_id.sha;
    }

	static function getCommits(user:String, commits:String, ?onError:Exception->Void) {
		try {
			var url:String = 'https://api.github.com/repos/${user}/${commits}/commits';
			var data = getGitToJSON(url);

			if (!(data is Array))
				getGitException(data);

			return data;
		} catch(exception) {
			if (onError != null) onError(exception);
		}

		return [];
	}

	static function getGitException(object:Dynamic):GitException {
		var problem:String = "No problems here.";
		if (Reflect.hasField(object, "message"))
			problem = Reflect.field(object, "message");
		return new GitException(problem);
	}

	static function getGitToJSON(url:String) {
		var http = new Http(url);
		http.setHeader("User-Agent", "request");

		var r:Dynamic = null;
		http.onData = function(data) {r = data;}
		http.onError = function(exception) {throw exception;}
		http.request(false);
		return Json.parse(r);
	}
}
#else
class GithubAPI {
    public static function getLatestCommits():String {
        return 'This build does not have Github support. Cannot return latest commits.';
    }

	static function getCommits(user:String, commits:String, ?onError:Exception->Void) {
		return [];
	}

	static function getGitException(object:Dynamic):GitException {
		return new GitException("This build does not have Github support.");
	}

	static function getGitToJSON(url:String) {
		return null;
	}
}
#end