from __future__ import annotations

import ModuleUpdate
ModuleUpdate.update()

from worlds.hades.Client import launch
import Utils

if __name__ == "__main__":
    Utils.init_logging("HadesClient", exception_logger="Client")
    launch()
