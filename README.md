--DESIGN DOCUMENT - IN PROGRESS (POSSIBLY OUTDATED TOO)--
General Overview:

For our Game 1 in this class, we created a rather finished tower defense game. It had an impressive amount of towers, waves, and maps, including different enemy types and a freeplay mode after all rounds passed. It even had a story (though it was not included in the gameplay).

We hope to continue this to a game 2, but an issue we faced was wondering just how we could make this game 2 step forward and feel like a proper sequel. While it will be quite a challenge to do better than what we have, we have plans to set our sequel apart not just from our game, but other tower defense games in general.

 Our main draw for this game is a new game mechanic: manifestation. Manifestation is a mechanic that allows the player to, at any time during gameplay, select and take control of a tower. Every tower plays entirely differently when selected, and any tower can be selected at any time. 
This creates a very dynamic mechanic in mid-gameplay that allows strategic gameplay mid-game (a common flaw of tower defense games having nothing to do mid-round). Does the player control the blade circle and wind it up before the enemy nears it, or due they use a fire pit to deal some damage? Do they control the hale howitzer from far away to provide support? Perhaps they try to do some extra damage with the Sharp Shooter that the enemies have almost passed by? 
This creates exciting and, more interestingly, emergent gameplay based on what towers the player has placed and where in a round. If properly balanced, it could make our game feel truly unique.

Another draw our game will have is a fully featured campaign. Our first game has an arcade style of gameplay where you go as long as you can, facing preset waves until the ever increasing difficulty of free play mode. Our game 2 will contain a decently long campaign, hopefully 7-10 levels (varying based on the time we have) with unique tilemaps, waves, and hopefully even mechanics/music. Some specific details are left to be decided, but we will have a full draft of the plot done early.
	
The first level of the game will be a tutorial. It will be easy enough for a new player in terms of difficulty, requiring less in terms of strategy and such. The tutorial’s specialty is that, throughout the first half of the level, the player will have text boxes appear on the sides describing the rules of the game. The story idea behind this level (not the actual plot, but an idea behind the level) is written here from an old English class story. This also should hopefully give an idea of the game’s plot in general: Writing Ex #4.
	
As the games goes on, special mechanics (often increasing game difficulty) will appear to keep gameplay fresh). Some current examples include a night level where you have to reveal parts of the map, and a level where you play against an enemy AI aligned with Milit.

Finally, at the end of every level the player will unlock a new tower (or, near the end of the game, small upgrades). This steady stream of new options keeps things fresh and varied in regards to tactics, yet also prevents choice paralysis in the early game. The last few levels giving upgrades prevents the last towers unlocked from being unusable for as long.

New towers will be implemented into the game. We hope to have 10 in total by the end of development, though this may increase or decrease based on the time we have. We don’t plan to add many more than 10 towers however, as the game may feel bloated and having so many would be very tough to balance.

Enemy types would become much more varied, often having special abilities as the game goes on. New ones would be introduced in each level.

General changes would be made to the game. One important thing we will do is to have scrap generated not from destroying enemies, but instead being automatically generated at a preet rate. The current scrap system is very tough to balance, and it also punishes players who are struggling by giving them no scrap from leaked enemies.



Now onto concrete details.

Currently planned new towers include:

The Sharp Shooter: Can be placed down to fire angled, simulated projectiles with a high velocity and decent range. When manifested,the player gains control of the angle it fires in while making it autofire at double speed. Can be turned 360 degrees with left turning it counterclockwise and right turning it clockwise. It keeps its exact angle when unmanifested, allowing it to be very versatile in terms of position

Fighter Factory: A special tower that attacks enemies directly, but instead slowly constructs robots who travel across the lane in a reverse direction. Upon contacting enemies, they deal damage and stop them in their tracks until those enemies destroy them. Enemy damage is dependent on how many lives those enemies cost when they leak.
Acid Accumulator: An acid oriented fountain tower with details to be decided.


Manifest modes:

Sword Circle: The Sword Circle stops attacking, and instead allows the player to rotate it as a sort of skill based minigame. The player must press, clockwise, WASD and repeat as fast as they can to add momentum to the tower. The faster the press, the less time it takes to reach maximum speed and attack up to 3 times faster!

Hale Howitzer: The Hale Howitzer also stops attacking, instead aiming upwards toward the sky. The player keeps their ui selector but it turns blue. When the player presses the O button anywhere on the screen, the Hale Howitzer fires upward and has its projectile hit the target after a 0.5 second delay like an actual mortar. Upon impact, it explodes in an icy, 3x3 cross that freezes and deals decent damage to all targets. Has a cooldown of 2 seconds between shots. While it can fire anywhere on the screen (and is thus useful in areas that have no defense currently), it’s at its best when it is used to support strongpoints that lack a Hale Howitzer already.

Lightning Lance: The Lightning Lance similarly stops attacking normally. Instead, It gets wrapped in electricity and, when the player activates their (now yellow) selector anywhere on the screen, fires a massive 3 tile wide, infinite length beam in the direction dealing good damage. After use, the Lightning Lance has a 6 second cooldown before it can attack again. This cooldown actually charges even if the player manifests, allowing skilled players to fire the lightning lance manifested while manifesting another tower between shops. Compared to the Hale Howitzer, it similarly combines great range, but it sacrifices its support aspect and fire rate for pure damage and area of effect.

Fire Pit (This name kind of feels out of place, maybe call it Torch Trap?): The fire pit still operates as normal, but it now follows wherever the reticle (now restricted to the road) goes! This allows the Torch Trap to go anywhere on the battlefield, and literally lets the player chase enemies as they progress to set them all on fire between other defenses. When the player manifests, the Torch Trap is left where it has moved to, and so this allows permanent relocation of these towers.

Sharp Shooter: The Sharp Shooter begins firing at double speed and the player gains full rotational control of its firing direction. The left arrow key lets the tower slowly rotate counter-clockwise, and the right arrow key lets the tower slowly rotate clockwise. Can fire in 360 degrees and keeps its direction on unmanifesting. Make use of large loops where it can focus on enemies for an extended time, as well as making use of keypoints useless to other towers (for example, it can be placed adjacent to a straight road to fire along it for the most part.

Fighter Factory: Instead of producing more robots, it produces an elite robotic tank piloted by Blitz remotely. The player can move it with arrow keys along the road, and it can fire projectiles with the O button. When destroyed by enemies or unmanifested, it explodes to deal heavy damage before making a new one in 4 seconds.

Acid Accumulator?: Creates a cloud of acid rain that moves along the cursor with a wide area. Details on what this does exactly are to be decided.



Timeline:

Our game will have a very modular development that allows us to extend our final product as much as we need, or take away from it as much as we need, based on the time we have.

Development begins by adding manifest modes for the currently implemented towers:  the Sword Circle, Lightning Lance, Hale Howitzer, and Torch Trap. We will likely have the structure of this system made first, and the four tower modes will stem out of that (these can be built by separate people at the same time).
Development then continues by crafting the tutorial level. Dialogue and story aspects can be added later, but it’s important that we introduce players to how the game works. The level will be quite easy (and therefore easier to balance), but we have to make sure that a tutorial system is built into the game that properly teaches the player.

Now we have a repeating, segmented system for extending the game. As much as we can, we should add a new tower we unlock from the previous level (with its manifest mode) and then we should create the next level of the game. 

First, we should implement the Sharp Shooter (its blueprints lore wise are created from a recycled military weapon from one of the guards in the tutorial lab). Then we should implement the next level, including its tileset, set of waves, new enemies featured, and mechanics (maybe a unique song too, songs will probably be made separate and depending on how many we make we'll integrate them how we see fit).

For this level specifically, it will likely involve TODO

Here, we should implement the Fighter Factory unlocked from the last level. Then, we should implement the level. The level here will involve fighting against an enemy AI, aligned with Milit, called Auxilium. Auxilium is a medical support AI, represented with a green cross rather than Blitz’s lightning bolt, who has been partially reworked for combat after Blitz’s betrayal of Milit. Dialogue will appear before the battle of Blitz talking to Auxilium, with Auxilium calling into question the morality of Blitz’s actions (mainly their killing of scientists) before announcing that they are to battle. Dialogue will be represented with a slash across the screen, Blitz’s terminal on the left and Auxillium on the right, with either one typing in response to the other. Should probably take something like 30 seconds to not drag on, but it should reveal a good amount of the character for both AIs.

The level will involve a mostly normal match with new enemies and such. But Auxilium will exist on the stage from a detour from the main road. They have a Fighter Factory that sends reinforcements from their side (located near their console), in addition to having several unique towers that heal enemies (aligning with Auxilium’s medical theme). The player can either power through with Auxilium making things more difficult, or they can utilize the Fighter Factory they unlocked. All robots will go along Auxilium’s path, and if they reach their console then they will deal damage to their console. Enough robots will defeat Auxilium, taking them out of the battle (though they will continue to appear throughout the story, repaired). This shuts down all of their healing towers and fighter factories, creating an optional objective that makes things easier.

