Diablo-like gears for RPG Maker XP
==========================
This script provides ways to generate randomized gears for games created by RPG Maker XP. The suffix and postfix modifiers are easily managed in RMXP's database editor.

Compatibility
------------
This script might not be compatible with many other gear modifying modules.

In RMXP's original setting, gears created by a same database prototype share a same object, thus making property variations for gears from same prototype impossible. For example, adding "1 atk" to an iron sword in game makes all iron swords in the game world share that plus attack.

In order to solve this problem, this script represents each gear with its own object, while keeping most of the original gear object interface to cope with the rest of the RMXP system. The gears may still walk like a duck and quark like a duck, but any other module that messes with the gear internals would surely post compatibility issues.

Screenshots
------------
![equip interface](https://raw.github.com/leav/diablo-like-gears/master/screenshot01.jpg)

![database editor](https://raw.github.com/leav/diablo-like-gears/master/screenshot02.jpg)