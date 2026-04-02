You can check if the player has licenses like this:
local result = doesPlayerHasLicense("driver", 2)

2 is the server id of the player, and you can check for weapon or driver license

And to give player a license
setPlayerLicense(2, "weapon", 1)
2 is player id
weapon is type
1 means has license and 0 means false