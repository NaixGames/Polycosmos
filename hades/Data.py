from dataclasses import dataclass

# ----------- Mirror Upgrade Locations -----------
@dataclass
class MirrorUpgradeData:
    name:str
    max_level:int

mirror_upgrades = [
    MirrorUpgradeData("Shadow Presence", 5),
    MirrorUpgradeData("Chthonic Vitality", 3),
    MirrorUpgradeData("Death Defiance", 3),
    MirrorUpgradeData("Greater Reflex", 1),
    MirrorUpgradeData("Boiling Blood", 5),
    MirrorUpgradeData("Infernal Soul", 2),
    MirrorUpgradeData("Deep Pockets", 10),
    MirrorUpgradeData("Thick Skin", 10),
    MirrorUpgradeData("Privileged Status", 2),
    MirrorUpgradeData("Olympian Favor", 40),
    MirrorUpgradeData("Gods' Pride", 20),
    MirrorUpgradeData("Fated Authority", 8),
    MirrorUpgradeData("Fiery Presence", 5),
    MirrorUpgradeData("Dark Regeneration", 2),
    MirrorUpgradeData("Stubborn Defiance", 1),
    MirrorUpgradeData("Ruthless Reflex", 1),
    MirrorUpgradeData("Abyssal Blood", 5),
    MirrorUpgradeData("Stygian Soul", 2),
    MirrorUpgradeData("Golden Touch", 3),
    MirrorUpgradeData("High Confidence", 5),
    MirrorUpgradeData("Family Favorite", 2),
    MirrorUpgradeData("Dark Foresight", 10),
    MirrorUpgradeData("Gods' Legacy", 10),
    MirrorUpgradeData("Fated Persuasion", 4),
]