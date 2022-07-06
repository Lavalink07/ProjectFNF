package options;

class ModifiersSubState extends BaseOptionsMenu
{
	public function new()
	{
		title = 'Modifiers';
		rpcTitle = 'Modifiers Menu'; // for Discord Rich Presence

		// I'd suggest using "Downscroll" as an example for making your own option since it is the simplest here
		//var option:Option = new Option('Downscroll', // Name
		//	'If checked, notes go Down instead of Up, simple enough.', // Description
		//	'downScroll', // Save data variable name
		//	'bool', // Variable type
		//	false); // Default value
		//addOption(option);

		var option:Option = new Option('Damage from Opponent Notes', // Name
			'How much health will the opponent reduce by hitting a note', // Description
			'damageFromOpponentNotes', // Save data variable name
			'float', // Variable type
			0); // Default value
		option.displayFormat = "%v%";
		option.scrollSpeed = 3.3;
		option.minValue = 0.0;
		option.maxValue = 10.0;
		option.changeValue = 0.1;
		option.decimals = 1;
		addOption(option);

		var option:Option = new Option('Opponent Notes Can Kill', // Name
			'If checked, damage from opponent notes can be lethal.', // Description
			'opponentNotesCanKill', // Save data variable name
			'bool', // Variable type
			false); // Default value
		addOption(option);

		var option:Option = new Option('Stuns Block Inputs', // Name
			'For how long are inputs blocked after a miss', // Description
			'stunsBlockInputs', // Save data variable name
			'float', // Variable type
			0); // Default value
		option.displayFormat = "%v seconds";
		option.scrollSpeed = 1.7;
		option.minValue = 0.0;
		option.maxValue = 5.0;
		option.changeValue = 0.1;
		option.decimals = 1;
		addOption(option);

		var option:Option = new Option('Misses Decrease Max Health', // Name
			'If checked, misses will lower your maximum health by damage taken.', // Description
			'missesDecreaseMaxHealth', // Save data variable name
			'bool', // Variable type
			false); // Default value
		addOption(option);

		super();
	}
}
