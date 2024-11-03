#if sys
package debug;

import backend.Difficulty;
import backend.Mods;
import backend.Song;
import backend.WeekData;
import options.OptionsState;
#if ACHIEVEMENTS_ALLOWED import states.AchievementsMenuState; #end
import states.CreditsState;
import states.FreeplayState;
import states.MainMenuState;
import states.ModsMenuState;
import states.PlayState;
import states.StoryMenuState;
import states.editors.CharacterEditorState;
import states.editors.ChartingState;
import states.editors.MasterEditorMenu;

using StringTools;

class Argument
{
	public static function parse(args:Array<String>):Bool
	{
		switch (args[0])
		{
			default:
				return false;

			case '-h' | '--help':
				{
					var exePath:Array<String> = Sys.programPath().split(#if windows '\\' #else '/' #end);
					var exeName:String = exePath[exePath.length - 1].replace('.exe', '');

					Sys.println('
Usage:
  ${exeName} (menu | storymode | freeplay | mods ${#if ACHIEVEMENTS_ALLOWED '| awards' #end} | thanks | savefile | credits | options)
  ${exeName} play "Song Name" ["Mod Folder"] [-s | --story] [-d=<val> | --diff=<val>]
  ${exeName} chart "Song Name" ["Mod Folder"] [-d=<val> | --diff=<val>]
  ${exeName} debug ["Mod Folder"]
  ${exeName} editcharacter <char> ["Mod Folder"]
  ${exeName} editweek ["Mod Folder"]
  ${exeName} editcredits ["Mod Folder"]
  ${exeName} editdialogue ["Mod Folder"]
  ${exeName} editdialchar ["Mod Folder"]
  ${exeName} editmenuchar ["Mod Folder"]
  ${exeName} editsplash ["Mod Folder"]
  ${exeName} editcredits ["Mod Folder"]
  ${exeName} setupmod ["Mod Folder"]
  ${exeName} -h | --help
  ${exeName} -v | --version

Options:
  -h       --help        Show this screen.
  -v       --version        Show the current version of the engine.
  -c       --charsel       Enables selecting a character when going to PlayState.
  -s       --story       Enables story mode when in PlayState.
  -d=<val> --diff=<val>  Sets the difficulty for the song. [default: ${Difficulty.getDefault().toLowerCase().trim()}]
');

					Sys.exit(0);
				}

                
			case '-v' | '--version':
				{
					Sys.println('Alleyway Engine v1.0 ALPHA
                    Psych Engine v1.0a
                    Friday Night Funkin\' v0.2.8');

					Sys.exit(0);
				}

			case 'menu':
				{
					LoadingState.loadAndSwitchState(() -> new MainMenuState());
				}

			case 'storymode':
				{
					LoadingState.loadAndSwitchState(() -> new StoryMenuState());
				}

			case 'freeplay':
				{
					LoadingState.loadAndSwitchState(() -> new FreeplayState());
				}

			case 'menu':
				{
					LoadingState.loadAndSwitchState(() -> new SaveFileState());
				}

			case 'mods':
				{
					LoadingState.loadAndSwitchState(() -> new ModsMenuState());
				}

			case 'thanks':
				{
					LoadingState.loadAndSwitchState(() -> new ThanksState());
				}
			case 'thanks':
				{
					LoadingState.loadAndSwitchState(() -> new ThanksState());
				}

			#if ACHIEVEMENTS_ALLOWED
			case 'awards':
				{
					LoadingState.loadAndSwitchState(() -> new AchievementsMenuState());
				}
			#end

			case 'credits':
				{
					LoadingState.loadAndSwitchState(() -> new CreditsState());
				}

			case 'options':
				{
					LoadingState.loadAndSwitchState(() -> new OptionsState());
				}

			case 'play':
				{
					var modFolder:String = null;
					var diff:String = null;
					var characterSelect:Bool = false;
					for (i in 2...args.length)
					{
						if (args[i] == '-c' || args[i] == '--charsel')
							characterSelect = true;
						else if (args[i] == '-s' || args[i] == '--story')
							PlayState.isStoryMode = true;
						else if (args[i].startsWith('-d=') || args[i].startsWith('--diff='))
							diff = (args[i].split('='))[1];
						else if (modFolder != null)
							modFolder = args[i];
					}

					setupSong(args[1], modFolder, diff);
					if (characterSelect)
						LoadingState.loadAndSwitchState(() -> new CharacterSelectionState(), true);
					else
						LoadingState.loadAndSwitchState(() -> new PlayState(), true);
				}

			case 'chart':
				{
					var modFolder:String = null;
					var diff:String = null;
					for (i in 2...args.length)
					{
						if (args[i].startsWith('-d') || args[i].startsWith('--diff'))
							diff = (args[i].split('='))[1];
						else if (modFolder != null)
							modFolder = args[i];
					}

					setupSong(args[1], args[2], diff);
					LoadingState.loadAndSwitchState(() -> new ChartingState(), true);
				}

			case 'debug':
				{
					if (args[1] != null)
						Mods.currentModDirectory = args[1];
					LoadingState.loadAndSwitchState(() -> new MasterEditorMenu());
				}

			case 'editcharacter':
				{
					if (args[2] != null)
						Mods.currentModDirectory = args[2];
					LoadingState.loadAndSwitchState(() -> new CharacterEditorState(args[1]));
				}

			case 'editweek':
				{
					if (args[1] != null)
						Mods.currentModDirectory = args[1];
					LoadingState.loadAndSwitchState(() -> new WeekEditorState());
				}
			case 'editcredits':
				{
					if (args[1] != null)
						Mods.currentModDirectory = args[1];
					LoadingState.loadAndSwitchState(() -> new CreditsEditor());
				}
			case 'editsplash':
				{
					if (args[1] != null)
						Mods.currentModDirectory = args[1];
					LoadingState.loadAndSwitchState(() -> new NoteSplashDebugState());
				}
			case 'editmenuchar':
				{
					if (args[1] != null)
						Mods.currentModDirectory = args[1];
					LoadingState.loadAndSwitchState(() -> new MenuCharacterEditorState());
				}
			case 'editdialogue':
				{
					if (args[1] != null)
						Mods.currentModDirectory = args[1];
					LoadingState.loadAndSwitchState(() -> new DialogueEditorState());
				}
			case 'editdialchar':
				{
					if (args[1] != null)
						Mods.currentModDirectory = args[1];
					LoadingState.loadAndSwitchState(() -> new DialogueCharacterEditorState());
				}
			case 'setupmod':
				{
					if (args[1] != null)
						Mods.currentModDirectory = args[1];
					LoadingState.loadAndSwitchState(() -> new ModsSetupState());
				}
		}

		return true;
	}

	static function setupSong(songName:String, ?modFolder:String, ?diff:String):Void
	{
		WeekData.reloadWeekFiles(PlayState.isStoryMode);

		if (modFolder == null)
		{
			var songFound:Bool = false;
			for (weekData in WeekData.weeksList)
			{
				if (songFound)
					break;

				var week:WeekData = WeekData.weeksLoaded.get(weekData);

				for (weekSong in week.songs)
				{
					if (Paths.formatToSongPath(weekSong[0]) == Paths.formatToSongPath(songName))
					{
						WeekData.setDirectoryFromWeek(week);
						Difficulty.loadFromWeek(week);
						songFound = true;
						break;
					}
				}
			}
		}
		else
		{
			Mods.currentModDirectory = modFolder;
		}

		var defaultDiff:Bool = diff == null || (diff != null && diff.toLowerCase().trim() == Difficulty.getDefault().toLowerCase().trim());
		var jsonName:String = songName + (!defaultDiff ? '-${diff}' : '');
		PlayState.SONG = Song.loadFromJson(jsonName, songName);
	}
}
#end
