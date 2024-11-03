package;

#if android
import android.content.Context;
#end
import flixel.graphics.FlxGraphic;
import flixel.FlxGame;
import haxe.io.Path;
import openfl.Assets;
import openfl.Lib;
import openfl.display.Sprite;
import openfl.display.Bitmap;
import openfl.events.Event;
import openfl.display.StageScaleMode;
import lime.app.Application;
import states.TitleState;
import flixel.math.FlxMath;
import flixel.util.FlxColor;
import lime.app.Application;
import haxe.EnumFlags;
import haxe.Exception;
import flixel.text.FlxBitmapText;
import flixel.graphics.frames.FlxBitmapFont;

import backend.ColorBlindness;
import debug.FPSCounter;

#if linux
import lime.graphics.Image;
#end

//crash handler stuff
#if CRASH_HANDLER
import openfl.events.UncaughtErrorEvent;
import haxe.CallStack;
import haxe.io.Path;
#end
import sys.FileSystem;
import sys.io.File;
import sys.io.Process;

#if linux
@:cppInclude('./external/gamemode_client.h')
@:cppFileCode('
	#define GAMEMODE_AUTO
')
#end

class Main extends Sprite
{
	var game = {
		width: 1280, // WINDOW width
		height: 720, // WINDOW height
		zoom: -1.0, // game state bounds
		initialState: () -> new StartingState(), // initial game state
		framerate: 60, // default framerate
		skipSplash: true, // if the default flixel splash screen should be skipped
		startFullscreen: false // if the game should start at fullscreen mode
	};

	// changes how modifier keys are shown in UI.
	// small heads-up Command is mapped to WINDOWS in Haxeflixel, Option is curiously mapped to ALT still though.
	public static var modifier_keys:Array<String> = #if !mac ['Control', 'Alt']; #else['Command', 'Option']; #end

	public static var fpsVar:FPSCounter;
	public static var watermark:Sprite;
	public static var colorFilter:ColorBlindness;

	public static var instance:Main;

	// You can pretty much ignore everything from here on - your code should go in your states.

	public static function main():Void
	{
		Lib.current.addChild(new Main());
	}

	public function new() {
		super();

		// Credits to MAJigsaw77 (he's the og author for this code)
		// just for easy porting y'know, but still just get a pc damnit
		#if android
		Sys.setCwd(Path.addTrailingSlash(Context.getExternalFilesDir()));
		#elseif ios
		Sys.setCwd(lime.system.System.applicationStorageDirectory);
		#end

		#if windows
		@:functionCode("
		#include <windows.h>
		#include <winuser.h>
		setProcessDPIAware() // allows for more crisp visuals
		DisableProcessWindowsGhosting() // lets you move the window and such if it's not responding
		")
		#end

		instance = this;

		if (stage != null) init();
		else addEventListener(Event.ADDED_TO_STAGE, init);

		#if VIDEOS_ALLOWED
		hxvlc.util.Handle.init();
		#end
	}

	private function init(?E:Event):Void {
		if (hasEventListener(Event.ADDED_TO_STAGE))
			removeEventListener(Event.ADDED_TO_STAGE, init);

		setupGame();
	}

	private function setupGame():Void {
		final stageWidth:Int = Lib.current.stage.stageWidth;
		final stageHeight:Int = Lib.current.stage.stageHeight;

		if (game.zoom == -1.0)
		{
			final ratioX:Float = stageWidth / game.width;
			final ratioY:Float = stageHeight / game.height;
			game.zoom = Math.min(ratioX, ratioY);
			game.width = Math.ceil(stageWidth / game.zoom);
			game.height = Math.ceil(stageHeight / game.zoom);
		}

		// flixel.FlxG.plugins.add(new flixel.addons.plugin.ScreenShotPlugin());
	
		#if LUA_ALLOWED Lua.set_callbacks_function(cpp.Callable.fromStaticFunction(psychlua.CallbackHandler.call)); #end
		Controls.instance = new Controls();
		ClientPrefs.loadDefaultKeys();
		#if ACHIEVEMENTS_ALLOWED Achievements.load(); #end
		#if (cpp && windows) CppAPI.darkMode(); #end
		addChild(new FlxGame(game.width, game.height, game.initialState, game.framerate, game.framerate, game.skipSplash, game.startFullscreen));

		cppthing.CppAPI.darkMode();
		
		#if !mobile fpsVar = new FPSCounter(10, 3);
		addChild(fpsVar);
		Lib.current.stage.align = "tl";
		Lib.current.stage.scaleMode = StageScaleMode.NO_SCALE;
		if (fpsVar != null) fpsVar.visible = ClientPrefs.data.showFPS;
        #end

		// Mic'd Up SC code :D
		var bitmapData = Assets.getBitmapData("assets/shared/images/foxaIcon.png");
		watermark = new Sprite();
		watermark.addChild(new Bitmap(bitmapData)); // Sets the graphic of the sprite to a Bitmap object, which uses our embedded BitmapData class.
		watermark.alpha = 0.4;
		watermark.x = Lib.application.window.width - 10 - watermark.width;
		watermark.y = Lib.application.window.height - 10 - watermark.height;
		addChild(watermark);
		if (watermark != null) watermark.visible = ClientPrefs.data.watermarkIcon;

		#if linux
		var icon = Image.fromFile("icon.png");
		Lib.current.stage.window.setIcon(icon);
		#end

		#if html5 FlxG.autoPause = FlxG.mouse.visible = false; #end
		
		#if (CRASH_HANDLER && !hl) Lib.current.loaderInfo.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, onCrash); #end
		#if (CRASH_HANDLER && hl) hl.Api.setErrorHandler(onCrash); #end
		#if desktop DiscordClient.start(); #end

		// shader coords fix
		FlxG.signals.gameResized.add((w, h) -> {
		     if (FlxG.cameras != null) {
			   for (cam in FlxG.cameras.list) {
				@:privateAccess
				if (cam != null && cam.filters != null) resetSpriteCache(cam.flashSprite);
			   }
		     }

		     if (FlxG.game != null)
			 resetSpriteCache(FlxG.game);
		});
	}

	static function resetSpriteCache(sprite:Sprite):Void {
		@:privateAccess {
		        sprite.__cacheBitmap = null;
			sprite.__cacheBitmapData = null;
		}
	}

	#if CRASH_HANDLER
	function onCrash(e:UncaughtErrorEvent):Void {
		var errMsg:String = "";
		var path:String;
		var callStack:Array<StackItem> = CallStack.exceptionStack(true);
		var dateNow:String = Date.now().toString().replace(" ", "_").replace(":", "-");

		path = './crash/AlleywayFoxa_$dateNow.txt';

		for (stackItem in callStack) {
			switch (stackItem) {
				case FilePos(s, file, line, column): errMsg += file + " (line " + line + ")\n";
				default: Sys.println(stackItem);
			}
		}

		errMsg += "\nUncaught Error: " + e.error // + "\nPlease report this error to the pursnake in Discord\n";
			+ "\n";
		if (!FileSystem.exists("./crash/")) FileSystem.createDirectory("./crash/");

		File.saveContent(path, errMsg + "\n");

		Sys.println(errMsg);
		Sys.println("Crash dump saved in " + Path.normalize(path));

		var crashDialoguePath:String = "AlleywayCrashHandler" #if windows + ".exe" #end;

		if (FileSystem.exists("./" + crashDialoguePath))
		{
			Sys.println("Found crash dialog: " + crashDialoguePath);
			#if linux
			crashDialoguePath = "./" + crashDialoguePath;
			#end
			new Process(crashDialoguePath, [path]);
		}
		else
		{
			// I had to do this or the stupid CI won't build :distress:
			Sys.println("No crash dialog found! Making a simple alert instead...");
			Application.current.window.alert(errMsg, "Critical Error!");
		}
		DiscordClient.shutdown();
		Sys.exit(1);
	}
	#end
}
