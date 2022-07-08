package options;

#if desktop
import Discord.DiscordClient;
#end
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import lime.utils.Assets;
import flixel.FlxSubState;
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxSave;
import haxe.Json;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;
import flixel.input.keyboard.FlxKey;
import flixel.graphics.FlxGraphic;
import Controls;

using StringTools;

class VisualsUISubState extends BaseOptionsMenu
{
	public function new()
	{
		title = 'Visuals and UI';
		rpcTitle = 'Visuals & UI Settings Menu'; //for Discord Rich Presence

		var option:Option = new Option('Note Splashes',
			"If unchecked, hitting \"Sick!\" notes won't show particles.",
			'noteSplashes',
			'bool',
			true);
		addOption(option);

		var option:Option = new Option('Hide HUD',
			'If checked, hides most HUD elements.',
			'hideHud',
			'bool',
			false);
		addOption(option);
		
		var option:Option = new Option('Time Bar:',
			"What should the Time Bar display?",
			'timeBarType',
			'string',
			'Time Left',
			['Time Left', 'Time Elapsed', 'Song Name', 'Disabled']);
		addOption(option);

		var option:Option = new Option('Flashing Lights',
			"Uncheck this if you're sensitive to flashing lights!",
			'flashing',
			'bool',
			true);
		addOption(option);

		var option:Option = new Option('Camera Zooms',
			"If unchecked, the camera won't zoom in on a beat hit.",
			'camZooms',
			'bool',
			true);
		addOption(option);

		var option:Option = new Option('Score Text Zoom on Hit',
			"If unchecked, disables the Score text zooming\neverytime you hit a note.",
			'scoreZoom',
			'bool',
			true);
		addOption(option);

		var option:Option = new Option('Health Bar Transparency',
			'How much transparent should the health bar and icons be.',
			'healthBarAlpha',
			'percent',
			1);
		option.scrollSpeed = 1.6;
		option.minValue = 0.0;
		option.maxValue = 1;
		option.changeValue = 0.1;
		option.decimals = 1;
		addOption(option);
		
		var option:Option = new Option('Camera Move Intensity',
			'How far should the camera move when a note gets hit.',
			'cameraMoveIntensity',
			'int',
			70);
		option.displayFormat = "%v pixels";
		option.scrollSpeed = 0;
		option.minValue = 0;
		option.maxValue = 200;
		option.changeValue = 10;
		addOption(option);

		var option:Option = new Option('Miss Shake Intensity',
			'How much does the screen shake when missing a note',
			'missShakeIntensity',
			'float',
			0.3);
		option.scrollSpeed = 0.5;
		option.minValue = 0.0;
		option.maxValue = 2;
		option.changeValue = 0.1;
		option.onChange = onChangeMissShakeIntensity;
		addOption(option);

		var option:Option = new Option('Advanced Score Text', //Name
			'If checked, there will be additional information displayed in score text.', //Description
			'advancedScoreTxt', //Save data variable name
			'bool', //Variable type
			true); //Default value
		addOption(option);

		var option:Option = new Option('Score Text Underlay Opacity',
			'How opaque should be an underlay for score text.',
			'scoreTxtUnderlayOpacity',
			'percent',
			0.3);
		addOption(option);
		option.scrollSpeed = 1.6;
		option.minValue = 0.0;
		option.maxValue = 1;
		option.changeValue = 0.1;
		option.decimals = 1;

		var option:Option = new Option('Health Bar:',
			"How should the Health Bar be positioned?",
			'healthBarType',
			'string',
			'Horizontal',
			['Vertical (left)', 'Vertical (right)', 'Horizontal', 'Disabled']);
		addOption(option);

		var option:Option = new Option('Vignette Strength',
			'Defines the strength of an effect that will darken your screen if your health gets low\nThe effect is proportional to maximum health',
			'vignetteStrength',
			'percent',
			0.7);
		addOption(option);
		option.scrollSpeed = 0;
		option.minValue = 0.0;
		option.maxValue = 1;
		option.changeValue = 0.05;

		var option:Option = new Option('Camera Zoom',
			"Overrides the camera zoom value for all stages.\nSet to 1.0 to use the stage's zoom value",
			'cameraZoom',
			'float',
			1);
		addOption(option);
		option.scrollSpeed = 1.3;
		option.minValue = 0.1;
		option.maxValue = 2.0;
		option.changeValue = 0.1;
		option.decimals = 1;

		var option:Option = new Option('Player Lane Underlay Opacity',
			'How opaque should be an underlay for the player lane.',
			'playerLaneUnderlayOpacity',
			'percent',
			0);
		addOption(option);
		option.scrollSpeed = 1.6;
		option.minValue = 0.0;
		option.maxValue = 1;
		option.changeValue = 0.1;
		option.decimals = 1;

		var option:Option = new Option('Opponent Lane Underlay Opacity',
			'How opaque should be an underlay for the opponent lane.',
			'opponentLaneUnderlayOpacity',
			'percent',
			0);
		addOption(option);
		option.scrollSpeed = 1.6;
		option.minValue = 0.0;
		option.maxValue = 1;
		option.changeValue = 0.1;
		option.decimals = 1;

		#if !mobile
		var option:Option = new Option('FPS Counter',
			'If unchecked, hides FPS Counter.',
			'showFPS',
			'bool',
			true);
		addOption(option);
		option.onChange = onChangeFPSCounter;
		#end
		
		var option:Option = new Option('Pause Screen Song:',
			"What song do you prefer for the Pause Screen?",
			'pauseMusic',
			'string',
			'Tea Time',
			['None', 'Breakfast', 'Tea Time']);
		addOption(option);
		option.onChange = onChangePauseMusic;
		
		#if CHECK_FOR_UPDATES
		var option:Option = new Option('Check for Updates',
			'On Release builds, turn this on to check for updates when you start the game.',
			'checkForUpdates',
			'bool',
			true);
		addOption(option);
		#end

		super();
	}

	var changedMusic:Bool = false;
	function onChangePauseMusic()
	{
		if(ClientPrefs.pauseMusic == 'None')
			FlxG.sound.music.volume = 0;
		else
			FlxG.sound.playMusic(Paths.music(Paths.formatToSongPath(ClientPrefs.pauseMusic)));

		changedMusic = true;
	}
	function onChangeMissShakeIntensity()
	{
		FlxG.camera.shake(ClientPrefs.missShakeIntensity * 0.01);
	}

	override function destroy()
	{
		if(changedMusic) FlxG.sound.playMusic(Paths.music('freakyMenu'));
		super.destroy();
	}

	#if !mobile
	function onChangeFPSCounter()
	{
		if(Main.fpsVar != null)
			Main.fpsVar.visible = ClientPrefs.showFPS;
	}
	#end
}