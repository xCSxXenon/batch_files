I use these to maintain offline archival of episodic series. Slowly renaming things away from 'podcasts' and towards something more ambiguous.

"[Add Podcast.bat](./Add%20Podcast.bat)" is to add a new series to a registry key that adds context-menu actions that use with "Episode Rename and Sort.bat".

"[Episode Rename and Sort.bat](./Episode%20Rename%20and%20Sort.bat)" is ran on a file from its context-menu. Selecting a series from the menu calls this script with that series as an argument. It then finds that series on my server to determine what season and episode numbers it should be given. New years lead to a new directory being created for that year. For seasonal instead of constant releases, I manually create a new directory. As long as it begins with 'Season XX', the script should work without any other intervention. If the series name doesn't exist yet, it will create it automatically. Makes a copy of the file to be offloaded onto my phone and then sorts the original into the correct path to be dumped onto my server. This is done automatically with ["Dump Videos.bat"](../Dump Videos.bat)

"[Toggle Show.bat](Toggle%20Show.bat)" manages the registry entries used above. As more shows clutter the context menu, this is a "GUI" for disabling the ones that aren't actively being released. Since they may come back or are yearly, this moves them to a different registry location without deleting them entirely. This is a bit easier than having to recreate the keys.

