# Hades Setup Guide

## Required Software

Install the game through Steam. Then install the following mods:

- [ModImporter](https://github.com/SGG-Modding/ModImporter/releases/tag/1.5.2)
- [ModUtils](https://github.com/SGG-Modding/ModUtil)
- [StyxScribe](https://github.com/SGG-Modding/StyxScribe)
- [Polycosmos](https://github.com/Naix99/Polycosmos/tree/main/Polycosmos)


## Configuring your YAML file

### What is a YAML file and why do I need one?

Your YAML file contains a set of configuration options which provide the generator with information about how it should
generate your game. Each player of a multiworld will provide their own YAML file. This setup allows each player to enjoy
an experience customized for their taste, and different players in the same multiworld can all have different options.

### Where do I get a YAML file?

you can customize your settings by using the .yalm in the hades world folder.

### Connect to the MultiServer

For launching the game to play in the multiworld you need to open HadesClient.exe. This opens a window to look for your 
Hades instalation path (the standard steam path being C:\Program Files\Steam\steamapps\common\Hades ). Once the folder is selected
the game this should open Hades, the Archipelago client plus a command terminal. This terminal is what communicates Hades and the Client, SO DO NOT CLOSE IT!

Use the Client window to connect to the Archipelago server before choosing your save file. If this is done correctly you should
be able to start the game and get a location check on the first room, which prints a message on your console. If the connection
is not sucesfully made, you will get an error message on the first room.