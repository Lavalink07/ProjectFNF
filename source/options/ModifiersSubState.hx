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

		var option:Option = new Option('Temp Miss Penalty:', // Name
			'How much health will be slowly drained when missing\nHitting notes will not gain health, but will decrease the penalty', // Description
			'tempMissPenalty', // Save data variable name
			'int', // Variable type
			0); // Default value
		option.displayFormat = "Damage x%v";
		option.scrollSpeed = 2.2;
		option.minValue = 0.0;
		option.maxValue = 25.0;
		option.changeValue = 1;
		addOption(option);

		var option:Option = new Option('Temp Miss Penalty DPS', // Name
			'How much health will temp miss penalty drain per second', // Description
			'tempMissPenaltyDPS', // Save data variable name
			'float', // Variable type
			0); // Default value
		option.displayFormat = "%v%";
		option.scrollSpeed = 1.8;
		option.minValue = 0.0;
		option.maxValue = 15.0;
		option.changeValue = 0.1;
		option.decimals = 1;
		addOption(option);

		var option:Option = new Option('Temp Miss Penalty Can Kill', // Name
			'If checked, temporary miss penalty can be lethal.', // Description
			'tempMissPenaltyCanKill', // Save data variable name
			'bool', // Variable type
			false); // Default value
		addOption(option);

		super();
	}
}
