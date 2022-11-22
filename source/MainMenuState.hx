package;

#if desktop
import Discord.DiscordClient;
#end
#if MODS_ALLOWED
import sys.FileSystem;
#end
import flixel.FlxSubState;
import flixel.input.gamepad.FlxGamepad;
import flixel.group.FlxGroup;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxCamera;
import flixel.addons.transition.FlxTransitionableState;
import flixel.effects.FlxFlicker;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.math.FlxMath;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import lime.app.Application;
import Achievements;
import editors.MasterEditorMenu;
import flixel.input.keyboard.FlxKey;
import openfl.Assets;

using StringTools;

class MainMenuState extends MusicBeatState
{
	public static var projectFnfVersion:String = '2.6-ALPHA';
	public static var psychEngineVersion:String = '0.6.3'; //This is also used for Discord RPC
	public static var curSelected:Int = 0;
	public static var activatedLogo:Bool = false;
	public static var mustUpdate:Bool = false; // TODO: outdated notifications
	public static var initialized:Bool = false;
	public static var instance:MainMenuState = null;

	public static var muteKeys = [FlxKey.ZERO];
	public static var volumeDownKeys = [FlxKey.NUMPADMINUS, FlxKey.MINUS];
	public static var volumeUpKeys = [FlxKey.NUMPADPLUS, FlxKey.PLUS];

	var menuItems:FlxTypedGroup<FlxSprite>;
	private var camMain:FlxCamera;
	public var camOther:FlxCamera;
	private var camAchievement:FlxCamera;
	
	var optionShit:Array<String> = [
		'story_mode',
		'freeplay',
		#if MODS_ALLOWED 'mods', #end
		#if ACHIEVEMENTS_ALLOWED 'awards', #end
		'credits',
		#if !switch 'donate', #end
		'options'
	];

	public var bg:FlxSprite;
	var magenta:FlxSprite;
	var camFollow:FlxObject;
	var camFollowPos:FlxObject;
	var debugKeys:Array<FlxKey>;

	public var logo:FlxSprite;
	public var logoBl:FlxSprite;
	var swagShader:ColorSwap;
	var credGroup:FlxGroup = new FlxGroup();
	var ngSpr:FlxSprite;
	var curWacky:Array<String> = [];
	

	override function create()
	{
		instance = this;
		#if MODS_ALLOWED
		Paths.pushGlobalMods();
		#end
		WeekData.loadTheFirstEnabledMod();

		FlxG.game.focusLostFramerate = 60;
		FlxG.sound.muteKeys = muteKeys;
		FlxG.sound.volumeDownKeys = volumeDownKeys;
		FlxG.sound.volumeUpKeys = volumeUpKeys;
		FlxG.keys.preventDefaultKeys = [TAB];

		PlayerSettings.init();
		FlxG.save.bind('funkin', 'ninjamuffin99');
		ClientPrefs.loadPrefs();
		Highscore.load();
		if (!initialized) {
			if (FlxG.save.data != null && FlxG.save.data.fullscreen)
				FlxG.fullscreen = FlxG.save.data.fullscreen;
		} 
		persistentUpdate = true;
		persistentDraw = true;
		if (FlxG.sound.music == null) {
			FlxG.sound.playMusic(Paths.music('freakyMenu'), 0);
			Conductor.changeBPM(102);
		}

		if (FlxG.save.data.weekCompleted != null)
			StoryMenuState.weekCompleted = FlxG.save.data.weekCompleted;
		FlxG.mouse.visible = false;

		if(FlxG.save.data.flashing == null && !FlashingState.leftState) {
			FlxTransitionableState.skipNextTransIn = true;
			FlxTransitionableState.skipNextTransOut = true;
			MusicBeatState.switchState(new FlashingState());
		} else {
			#if desktop
			if (!DiscordClient.isInitialized) {
				DiscordClient.initialize();
				Application.current.onExit.add (function (exitCode) {
					DiscordClient.shutdown();
				});
			}
			#end
		}

		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("Main Menu", null);
		#end
		debugKeys = ClientPrefs.copyKey(ClientPrefs.keyBinds.get('debug_1'));

		camMain = new FlxCamera();
		camOther = new FlxCamera();
		camOther.bgColor.alpha = 0;
		camAchievement = new FlxCamera();
		camAchievement.bgColor.alpha = 0;

		FlxG.cameras.reset(camMain);
		FlxG.cameras.add(camOther, false);
		FlxG.cameras.add(camAchievement, false);
		FlxG.cameras.setDefaultDrawTarget(camMain, true);
		if (!sawCoolText) camMain.visible = false;

		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		var yScroll:Float = Math.max(0.25 - (0.05 * (optionShit.length - 4)), 0.1);
		bg = new FlxSprite(-80).loadGraphic(Paths.image('menuBG'));
		bg.scrollFactor.set(0, yScroll);
		bg.setGraphicSize(Std.int(bg.width * 1.175));
		bg.updateHitbox();
		bg.screenCenter();
		bg.antialiasing = ClientPrefs.globalAntialiasing;
		add(bg);

		camFollow = new FlxObject(0, 0, 1, 1);
		camFollowPos = new FlxObject(0, 0, 1, 1);
		add(camFollow);
		add(camFollowPos);

		magenta = new FlxSprite(-80).loadGraphic(Paths.image('menuDesat'));
		magenta.scrollFactor.set(0, yScroll);
		magenta.setGraphicSize(Std.int(magenta.width * 1.175));
		magenta.updateHitbox();
		magenta.screenCenter();
		magenta.visible = false;
		magenta.antialiasing = ClientPrefs.globalAntialiasing;
		magenta.color = 0xFFfd719b;
		add(magenta);
		
		// magenta.scrollFactor.set();

		menuItems = new FlxTypedGroup<FlxSprite>();
		add(menuItems);

		var scale:Float = 1;
		/*if(optionShit.length > 6) {
			scale = 6 / optionShit.length;
		}*/

		var scr:Float = 0;
		for (i in 0...optionShit.length)
		{
			var offset:Float = 108 - (Math.max(optionShit.length, 4) - 4) * 80;
			var menuItem:FlxSprite = new FlxSprite(0, (i * 140)  + offset);
			menuItem.scale.x = scale;
			menuItem.scale.y = scale;
			menuItem.frames = Paths.getSparrowAtlas('mainmenu/menu_' + optionShit[i]);
			menuItem.animation.addByPrefix('idle', optionShit[i] + " basic", 24);
			menuItem.animation.addByPrefix('selected', optionShit[i] + " white", 24);
			menuItem.animation.play('idle');
			menuItem.ID = i;
			menuItem.x = activatedLogo ? (FlxG.width - menuItem.width) / 6 : -FlxG.width;
			menuItems.add(menuItem);
			scr = (optionShit.length - 4) * 0.135;
			if(optionShit.length < 6) scr = 0;
			menuItem.scrollFactor.set(0, scr);
			menuItem.antialiasing = ClientPrefs.globalAntialiasing;
			//menuItem.setGraphicSize(Std.int(menuItem.width * 0.58));
			menuItem.updateHitbox();
		}

		var versionShit:FlxText = new FlxText(12, FlxG.height - 90, FlxG.width - 24, "ProjectFNF v" + projectFnfVersion, 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionShit);
		var versionShit:FlxText = new FlxText(12, FlxG.height - 70, FlxG.width - 24, "Psych Engine v" + psychEngineVersion, 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionShit);
		var versionShit:FlxText = new FlxText(12, FlxG.height - 50, FlxG.width - 24, "Friday Night Funkin' v" + Application.current.meta.get('version'), 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		versionShit.wordWrap = false;
		add(versionShit);

		swagShader = new ColorSwap();
		if (FileSystem.exists(Paths.modsImages('logoBumpin')) && !FileSystem.exists(Paths.modsImages('titlelogo'))) {
			logoBl = new FlxSprite(FlxG.width * (4 / 7), 0);
			logoBl.frames = Paths.getSparrowAtlas('logoBumpin');

			logoBl.antialiasing = ClientPrefs.globalAntialiasing;
			logoBl.animation.addByPrefix('bump', 'logo bumpin', 24, false);
			logoBl.animation.play('bump');
			logoBl.updateHitbox();
			logoBl.shader = swagShader.shader;
			logoBl.scrollFactor.set(0, scr * 0.75);
			add(logoBl);
		} else {
			logo = new FlxSprite(FlxG.width * (4 / 7), 0).loadGraphic(Paths.image('titlelogo'));
			logo.antialiasing = ClientPrefs.globalAntialiasing;
			logo.shader = swagShader.shader;
			logo.scrollFactor.set(0, scr * 0.75);
			add(logo);
		}

		// NG.core.calls.event.logEvent('swag').send();

		if (!activatedLogo) {
			var logo = logoBl != null ? logoBl : logo;
			logo.x = (FlxG.width - logo.width) / 2;
			camFollow.setPosition(logo.x, logo.y);
		} else changeItem();

		ngSpr = new FlxSprite(0, FlxG.height * 0.52).loadGraphic(Paths.image('newgrounds_logo'));
		ngSpr.visible = false;
		ngSpr.setGraphicSize(Std.int(ngSpr.width * 0.8));
		ngSpr.updateHitbox();
		ngSpr.screenCenter(X);
		ngSpr.antialiasing = ClientPrefs.globalAntialiasing;
		ngSpr.cameras = [camOther];
		add(ngSpr);

		curWacky = FlxG.random.getObject(getIntroTextShit());
		add(credGroup);

		#if ACHIEVEMENTS_ALLOWED
		Achievements.loadAchievements();
		var leDate = Date.now();
		if (leDate.getDay() == 5 && leDate.getHours() >= 18) {
			var achieveID:Int = Achievements.getAchievementIndex('friday_night_play');
			if(!Achievements.isAchievementUnlocked(Achievements.achievementsStuff[achieveID][2])) { //It's a friday night. WEEEEEEEEEEEEEEEEEE
				Achievements.achievementsMap.set(Achievements.achievementsStuff[achieveID][2], true);
				giveAchievement();
				ClientPrefs.saveSettings();
			}
		}
		#end

		initialized = true;
		super.create();
	}

	#if ACHIEVEMENTS_ALLOWED
	// Unlocks "Freaky on a Friday Night" achievement
	function giveAchievement() {
		add(new AchievementObject('friday_night_play', camAchievement));
		FlxG.sound.play(Paths.sound('confirmMenu'), 0.7);
		trace('Giving achievement "friday_night_play"');
	}
	#end

	var selectedSomethin:Bool = false;
	var somewhereElse:Bool = false;

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music != null)
		{
			if (FlxG.sound.music.volume < 0.8) {
				FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
				if(FreeplaySubstate.vocals != null) FreeplaySubstate.vocals.volume += 0.5 * elapsed;
			}
			Conductor.songPosition = FlxG.sound.music.time;
		}
		if(swagShader != null)
		{
			if(controls.UI_LEFT) swagShader.hue -= elapsed * 0.1;
			if(controls.UI_RIGHT) swagShader.hue += elapsed * 0.1;
		}

		if (subState != null) {
			super.update(elapsed);
			return;
		}
		camMain.follow(camFollowPos, null, 1);

		var lerpVal:Float = CoolUtil.boundTo(elapsed * 7.5, 0, 1);
		camFollowPos.setPosition(FlxMath.lerp(camFollowPos.x, camFollow.x, lerpVal), FlxMath.lerp(camFollowPos.y, camFollow.y, lerpVal));

		if (!selectedSomethin && activatedLogo && sawCoolText)
		{
			if (controls.UI_UP_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(-1);
			}

			if (controls.UI_DOWN_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(1);
			}

			if (controls.BACK)
			{
				FlxG.sound.play(Paths.sound('cancelMenu'));
				activatedLogo = false;
				var logo:FlxSprite = logoBl != null ? logoBl : logo;
				FlxTween.tween(logo, {x: (FlxG.width - logo.width) / 2}, 0.75, {ease: FlxEase.expoInOut});
				camFollow.setPosition(logo.x, logo.y);
				menuItems.forEach(function(spr:FlxSprite) {
					FlxTween.tween(spr, {x: -FlxG.width}, 0.75, {ease: FlxEase.expoInOut});
				});
			}

			if (controls.ACCEPT)
			{
				if (optionShit[curSelected] == 'donate')
				{
					CoolUtil.browserLoad('https://ninja-muffin24.itch.io/funkin');
				}
				else
				{
					selectedSomethin = true;
					FlxG.sound.play(Paths.sound('confirmMenu'));

					if(ClientPrefs.flashing) FlxFlicker.flicker(magenta, 1.1, 0.15, false);

					menuItems.forEach(function(spr:FlxSprite)
					{
						if (curSelected != spr.ID)
						{
							FlxTween.tween(spr, {x: -FlxG.width}, 0.75, {
								ease: FlxEase.expoInOut,
							});
						}
						else
						{
							FlxFlicker.flicker(spr, 1, 0.06, true, false, function(flick:FlxFlicker)
							{
								var daChoice:String = optionShit[curSelected];

								switch (daChoice)
								{
									case 'story_mode':
										MusicBeatState.switchState(new StoryMenuState());
									case 'freeplay':
										somewhereElse = true;
										camOther.alpha = 0;
										openSubState(new FreeplaySubstate());
									#if MODS_ALLOWED
									case 'mods':
										MusicBeatState.switchState(new ModsMenuState());
									#end
									case 'awards':
										MusicBeatState.switchState(new AchievementsMenuState());
									case 'credits':
										MusicBeatState.switchState(new CreditsState());
									case 'options':
										LoadingState.loadAndSwitchState(new options.OptionsState());
								}
								spr.x = -FlxG.width;
							});
						}
					});
				}
			}
			#if desktop
			else if (FlxG.keys.anyJustPressed(debugKeys))
			{
				selectedSomethin = true;
				MusicBeatState.switchState(new MasterEditorMenu());
			}
			#end
		}

		var pressedEnter:Bool = FlxG.keys.justPressed.ENTER || controls.ACCEPT;

		#if mobile
		for (touch in FlxG.touches.list) pressedEnter = pressedEnter || touch.justPressed;
		#end

		var gamepad:FlxGamepad = FlxG.gamepads.lastActive;
		if (gamepad != null) {
			pressedEnter = pressedEnter || gamepad.justPressed.START #if switch || gamepad.justPressed.B #end;
		}
		if (pressedEnter) {
			if (!sawCoolText) {
				sickBeats = 16;
				beatHit();
			}
			else if (!selectedSomethin) {
				activatedLogo = true;
				changeItem();
				var logo:FlxSprite = logoBl != null ? logoBl : logo;
				FlxTween.tween(logo, {x: FlxG.width * (4 / 7)}, 0.75, {ease: FlxEase.expoInOut});
				menuItems.forEach(function(spr:FlxSprite) {
					FlxTween.tween(spr, {x: (FlxG.width - spr.width) / 6}, 0.75, {ease: FlxEase.expoInOut});
				});
				FlxG.sound.play(Paths.sound('confirmMenu'));
			}
		}

		super.update(elapsed);
	}

	function changeItem(huh:Int = 0)
	{
		curSelected += huh;

		if (curSelected >= menuItems.length)
			curSelected = 0;
		if (curSelected < 0)
			curSelected = menuItems.length - 1;

		menuItems.forEach(function(spr:FlxSprite)
		{
			spr.animation.play('idle');
			spr.updateHitbox();

			if (spr.ID == curSelected)
			{
				spr.animation.play('selected');
				var add:Float = 0;
				if(menuItems.length > 4) {
					add = menuItems.length * 8;
				}
				camFollow.setPosition(spr.getGraphicMidpoint().x, spr.getGraphicMidpoint().y - add);
				spr.centerOffsets();
			}
		});
	}

	private var sickBeats:Int = 0;
	public static var sawCoolText:Bool = false;
	override function beatHit()
	{
		super.beatHit();

		if (logoBl != null)
			logoBl.animation.play('bump', true);
		if (logo != null) {
			logo.scale.set(1.05, 1.05);
			FlxTween.tween(logo, {'scale.x': 0.95, 'scale.y': 0.95}, 0.1, { ease: FlxEase.bounceInOut });
		}

		if(initialized && !sawCoolText) {
			sickBeats++;
			switch (sickBeats)
			{
				case 1:
					//FlxG.sound.music.stop();
					FlxG.sound.playMusic(Paths.music('freakyMenu'), 0);
					FlxG.sound.music.fadeIn(4, 0, 0.7);
				case 2:
					#if PROJECTFNF_WATERMARKS
					createCoolText(['ProjectFNF by'], 15);
					#elseif PSYCH_WATERMARKS
					createCoolText(['Psych Engine by'], 15);
					#else
					createCoolText(['ninjamuffin99', 'phantomArcade', 'kawaisprite', 'evilsk8er']);
					#end
				// credTextShit.visible = true;
				case 4:
					#if PROJECTFNF_WATERMARKS
					addMoreText('l1ttleO', 15);
					addMoreText('BeastlyGhost', 15);
					addMoreText('aflac', 15);
					#elseif PSYCH_WATERMARKS
					addMoreText('Shadow Mario', 15);
					addMoreText('RiverOaken', 15);
					addMoreText('shubs', 15);
					#else
					addMoreText('present');
					#end
				// credTextShit.text += '\npresent...';
				// credTextShit.addText();
				case 5:
					deleteCoolText();
				// credTextShit.visible = false;
				// credTextShit.text = 'In association \nwith';
				// credTextShit.screenCenter();
				case 6:
					#if (PROJECTFNF_WATERMARKS || PSYCH_WATERMARKS)
					createCoolText(['Not associated', 'with'], -40);
					#else
					createCoolText(['In association', 'with'], -40);
					#end
				case 8:
					addMoreText('newgrounds', -40);
					ngSpr.visible = true;
				// credTextShit.text += '\nNewgrounds';
				case 9:
					deleteCoolText();
					ngSpr.visible = false;
				// credTextShit.visible = false;

				// credTextShit.text = 'Shoutouts Tom Fulp';
				// credTextShit.screenCenter();
				case 10:
					createCoolText([curWacky[0]]);
				// credTextShit.visible = true;
				case 12:
					addMoreText(curWacky[1]);
				// credTextShit.text += '\nlmao';
				case 13:
					deleteCoolText();
				// credTextShit.visible = false;
				// credTextShit.text = "Friday";
				// credTextShit.screenCenter();
				case 14:
					addMoreText('Friday');
				// credTextShit.visible = true;
				case 15:
					addMoreText('Night');
				// credTextShit.text += '\nNight';
				case 16:
					addMoreText('Funkin'); // credTextShit.text += '\nFunkin';

				case 17:
					remove(ngSpr);
					remove(credGroup);
					camMain.visible = true;
					camMain.flash(FlxColor.WHITE, 3);
					sawCoolText = true;
			}
		}
	}

	override function sectionHit() {
		super.sectionHit();
		if (PlayState.SONG != null && PlayState.SONG.notes[curSection] != null && PlayState.SONG.notes[curSection].changeBPM)
			Conductor.changeBPM(PlayState.SONG.notes[curSection].bpm);
	}

	function createCoolText(textArray:Array<String>, ?offset:Float = 0)
	{
		for (i in 0...textArray.length)
		{
			var money:Alphabet = new Alphabet(0, 0, textArray[i], true);
			money.screenCenter(X);
			money.y += (i * 60) + 200 + offset;
			money.cameras = [camOther];
			if(credGroup != null)
				credGroup.add(money);
		}
	}

	function addMoreText(text:String, ?offset:Float = 0)
	{
		if(credGroup != null) {
			var coolText:Alphabet = new Alphabet(0, 0, text, true);
			coolText.screenCenter(X);
			coolText.y += (credGroup.length * 60) + 200 + offset;
			coolText.cameras = [camOther];
			credGroup.add(coolText);
		}
	}

	function deleteCoolText()
	{
		while (credGroup.members.length > 0)
			credGroup.remove(credGroup.members[0], true);
	}

	function getIntroTextShit():Array<Array<String>>
	{
		var fullText:String = Assets.getText(Paths.txt('introText'));

		var firstArray:Array<String> = fullText.split('\n');
		var swagGoodArray:Array<Array<String>> = [];

		for (i in firstArray)
		{
			swagGoodArray.push(i.split('--'));
		}

		return swagGoodArray;
	}

	override function closeSubState() {
		if (somewhereElse) {
			menuItems.forEach(function(spr:FlxSprite) {
				FlxTween.tween(spr, {x: (FlxG.width - spr.width) / 6}, 0.4, {
					ease: FlxEase.expoInOut});
			});
			changeItem();
		}
		selectedSomethin = somewhereElse = false;
		super.closeSubState();
	}
}
