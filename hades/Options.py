import typing
from Options import TextChoice, Option, Range, Toggle, DeathLink


class InitialWeapon(TextChoice):
    """Chose your initial weapon. Although this does not do anything now.
     """
    display_name = "weapon"
    option_Sword = 0
    option_Bow = 1


hades_options: typing.Dict[str, type(Option)] = {
    "weapon": InitialWeapon,
    "death_link": DeathLink
}
