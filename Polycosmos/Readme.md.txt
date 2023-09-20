Polycosmos

---------------------------------

Polycosmos is a mod for the game Hades, which gives it integration with Archipelago Multiworld. Right now Polycosmos is in version:

0.0.0

and up to this version it posses the feature detailed below:

---Modes:

-Reverse Heat: Start the game with High pacts of punishments. The goal is to beat Hades one time.

--Items:

- Pact of Punishment down: an item that turns down the level of pact of punishment. Note the game may load this effect
on the run room, biome or run.

--Locations:

- Rooms: Beating any room counts as a location for the AP.


---------------------------------

Requirements

- At the moment you need to use Hades windows version, installed in a standard path (something like C:\Program Files\Steam\steamapps\common\ ).

-Then you need to use the mod loader to instal ModUtils and StyxScribe. Make sure this works in your computer (normally by executing 
SubsumeHades.py in Hades content folder).

-Now you can use the mod loader to install Polycosmos.

-On your Archipelago folder, copy HadesClient.py on the base folder (where all the clients are) and copy the hadesworld folder
in the worlds folder.

NOTE: up to the time of writting this mod does not warantee any type of compatibility with other Hades mods. You have been
warned!

---------------------------------

How to use Polycosmos

-To use Polycosmos open the HadesClient.py in your Archipelago folder. If everything is working correctly this should open
Hades, the Archipelago client plus a command terminal. This terminal is communicate Hades and the Client, SO DO NOT CLOSE IT!

-Connect to your Archipelago server using the client as you would do with any other AP game. Play the game and have fun ;).

---------------------------------

Understanding how it works

There might be the case in which you want to collaborate to improve this multiworld or want to adapt this to bring other game to Archipelago.
If that is the case; great! You can always put in contact with me at my discord. In any case, here is a broad overview of how this mod is set up.

First, there are 3 ingredients; Polycosmos mod, StyxScribe and the ArchipelagoClient. In a broad way; the Polycosmos 
mod is what can directly influence the game (give Zag items, record when locations have been reached, etc.). The Archipelago Client
is what Comunicate with the AP Server, and can comunicate messages to other clients (for example "HadesPlayer reached a location" or "HadesPlayer have recieved an item"). 
The StyxScribe is what can communicate the Polycosmos mod with the ArchipleagoCLient.

-- Polycosmos mod works like a standard Hades mod. It is written in .lua with some stripped down capabilities (in particular no access to
"require" or related commands). Up to the time of 0.0.0 it is compromised of the following modules:

PolycosmosEvents: reacts to certain important events in the game (location reached, game loaded) by notifying other modules.
PolycosmosHeatManager: manages the current Heat level according to the settings and items it recieves
PolycosmosMessages: It is the module that prints messages to the player.
PolycosmosNetwork: It is the module that sends messages in StyxScribe and also recieve them for other mods to know (normally notifyin PolycosmosEvents). 

Note that while some modules could be mashed together, this different functionalities have been split to be able 
to growth this in the most modular way possible. 

-- StyxScribe is a Hades mod that allow communication between .lua and .py modules. It uses a Hook system with strings;
ie, Allows to execute certain functions in the modules each time a message with a certain prefix have been sent in the console.
Is that by using this hooks that can communicate between Polycosmos and the Archipelago Client. 

As a side note, you might be considering why we even use StyxScribe and not import a .dll to use for the APClient (which already
exists for game running in .lua). The reason is simple: Hades run on a lua compiler that does not allow manul import of external files. 
It is the same reason why StyxScribe was created; this bypass this limitation as painlessly as possible. If other ways are found to also
 bypass this, another implementation of this mod might be possible.

--Archipelago Client is a .py app that can communicate with an Archipelago server to send and recieve items. This server also
deals with game randomization (ie, what item correspond to which other player item). 

The current implementation of the Client differentiate mainly in that it import StyxScribe, creates an instance of its main class,
 and then add all the hook it needs to communicate with StyxScribe. Finally it uses another thread to initiliazes the game+StyxScribe in parallel to it.
 This is how the Client automatically opens the game and set up communication to it. Beside this, the client should not present other main difference
with other AP clients.