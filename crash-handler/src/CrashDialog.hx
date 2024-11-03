package;

import haxe.ui.HaxeUIApp;
import haxe.ui.components.Button;
import haxe.ui.components.Label;
import haxe.ui.core.Component;
import haxe.ui.macros.ComponentMacros;
import sys.io.File;
import sys.io.Process;

class CrashDialog
{
	/*
		massive thanks to gedehari for the crash dialog code
	 */
	static final quotes:Array<String> = [
		"oops -CharlesCatYT",
		"Blueballed. -gedehari",
		"bruh lmfao -CharlesCatYT",
		"i hope you go mooseing and get fucked by a campfire  cyborg henry stickmin",
		"old was better - TheAnimateMan",
		"what the actual fuck -cyborg henry stickmin",
		"L -Dark",
		"You did something, didn't you? -LightyStarOfficial",
		"HA! -Dark",
		"you aren't struggling, are you? -CharlesCatYT",
		"WHY -CharlesCatYT",
		"What have you done, you killed it! -crowplexus",
		"Have you checked if the variable exists? -crowplexus",
		"Have you even read the wiki before trying that? -crowplexus",
		"you like the new crash handler? -CharlesCatYT",
		"i love flixel -CharlesCatYT",
		"i love openfl -CharlesCatYT",
		"i love lime -CharlesCatYT",
		"i love lua -CharlesCatYT",
		"i love haxe -CharlesCatYT",
		"i love hscript -CharlesCatYT",
		"check for any semicolon, dude -CharlesCatYT",
		"more null object references, okay... -CharlesCatYT",
		"gedehari made the crash dialog but what happened? -CharlesCatYT"
	];

	public static function main()
	{
		var args:Array<String> = Sys.args();

		if (args[0] == null) Sys.exit(1);
		else {
			var path:String = args[0];
			var contents:String = File.getContent(path);
			var split:Array<String> = contents.split("\n");

			var app = new HaxeUIApp();

			app.ready(() -> {
				var mainView:Component = ComponentMacros.buildComponent("assets/main-view.xml");
				app.addComponent(mainView);

				var messageLabel:Label = mainView.findComponent("message-label", Label);
				messageLabel.text = quotes[Std.random(quotes.length)] + '\n\nWell, Alleyway Engine crashed, that\'s a bummer.\nBut yeah, just figure it out.';
				messageLabel.percentWidth = 100;
				messageLabel.textAlign = "center";

				var callStackLabel:Label = mainView.findComponent("call-stack-label", Label);
				callStackLabel.text = "";
				for (i in 0...split.length - 4)
				{
					if (i == split.length - 5) callStackLabel.text += split[i];
					else callStackLabel.text += split[i] + "\n";
				}

				var crashReasonLabel:Label = mainView.findComponent("crash-reason-label", Label);
				crashReasonLabel.text = "";
				for (i in split.length - 3...split.length - 1)
				{
					if (i == split.length - 2) crashReasonLabel.text += split[i];
					else crashReasonLabel.text += split[i] + "\n";
				}

				mainView.findComponent("view-crash-dump-button", Button).onClick = function(_)
				{
					#if windows
					Sys.command("start", [path]);
					#elseif linux
					Sys.command("xdg-open", [path]);
					#end
				};

				mainView.findComponent("restart-button", Button).onClick = function(_)
				{
					new Process('${#if linux "./" #else "" #end}AlleywayEngine', []);
					Sys.exit(0);
				};

				mainView.findComponent("close-button", Button).onClick = function(_) {
					Sys.exit(0);
				};

				app.start();
			});
		}
	}
}
