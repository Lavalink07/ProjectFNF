package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.effects.FlxFlicker;
import lime.app.Application;
import flixel.addons.transition.FlxTransitionableState;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;

class OutdatedState extends MusicBeatState
{
	public static var leftState:Bool = false;

	var warnText:FlxText;
	override function create()
	{
		super.create();

		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		add(bg);

		warnText = new FlxText(1500, 0, FlxG.width,
			"Sup bro, looks like you're running an   \n
			outdated version of ProjectFNF (" + MainMenuState.projectFnfVersion + "),\n
			please update to " + TitleState.updateVersion + "!\n
			Press ESCAPE to proceed anyway.\n
			\n
			Thank you for using the Mod!",
			32);
		warnText.setFormat("VCR OSD Mono", 32, FlxColor.WHITE, CENTER);
		warnText.screenCenter(Y);
		add(warnText);
		FlxTween.tween(warnText, {x: 0}, 1.2, {ease: flixel.tweens.FlxEase.expoInOut});
	}

	override function update(elapsed:Float)
	{
		if(!leftState) {
			if (controls.ACCEPT) {
				leftState = true;
				CoolUtil.browserLoad("https://github.com/l1ttleO/ProjectFNF/releases/latest");
			}
			else if(controls.BACK) {
				leftState = true;
			}

			if(leftState)
			{
				FlxG.sound.play(Paths.sound('cancelMenu'));
				FlxTween.tween(warnText, {alpha: 0}, 1, {
					onComplete: function (twn:FlxTween) {
						MusicBeatState.switchState(new MainMenuState());
					}
				});
				FlxTween.tween(warnText, {x: -1500}, 1.2, {ease: flixel.tweens.FlxEase.expoInOut});
			}
		}
		super.update(elapsed);
	}
}
