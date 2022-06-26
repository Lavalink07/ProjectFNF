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

		super();
	}
}
