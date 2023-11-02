import typing

from BaseClasses import Location


hades_base_location_id = 666000

#Todo: automate creating of this tables to allow also to make a point based progresion system for Locations

location_table_tartarus = {
    'Clear Room01': hades_base_location_id+0,
    'Clear Room02': hades_base_location_id+1,
    'Clear Room03': hades_base_location_id+2,
    'Clear Room04': hades_base_location_id+3,
    'Clear Room05': hades_base_location_id+4,
    'Clear Room06': hades_base_location_id+5,
    'Clear Room07': hades_base_location_id+6,
    'Clear Room08': hades_base_location_id+7,
    'Clear Room09': hades_base_location_id+8,
    'Clear Room10': hades_base_location_id+9,
    'Clear Room11': hades_base_location_id+10,
    'Clear Room12': hades_base_location_id+11,
    'Clear Room13': hades_base_location_id+12,
    'Clear Room14': hades_base_location_id+13,
    'Beat Meg': None,
}

location_table_asphodel = {
    'Clear Room15': hades_base_location_id+14,
    'Clear Room16': hades_base_location_id+15,
    'Clear Room17': hades_base_location_id+16,
    'Clear Room18': hades_base_location_id+17,
    'Clear Room19': hades_base_location_id+18,
    'Clear Room20': hades_base_location_id+19,
    'Clear Room21': hades_base_location_id+20,
    'Clear Room22': hades_base_location_id+21,
    'Clear Room23': hades_base_location_id+22,
    'Clear Room24': hades_base_location_id+23,
    'Clear Room25': hades_base_location_id+24,
    'Clear Room26': hades_base_location_id+25,
    'Clear Room27': hades_base_location_id+26,
    'Clear Room28': hades_base_location_id+27,
    'Beat Lernie': None,
}

location_table_elyseum = {
    'Clear Room29': hades_base_location_id+28,
    'Clear Room30': hades_base_location_id+29,
    'Clear Room31': hades_base_location_id+30,
    'Clear Room32': hades_base_location_id+31,
    'Clear Room33': hades_base_location_id+32,
    'Clear Room34': hades_base_location_id+33,
    'Clear Room35': hades_base_location_id+34,
    'Clear Room36': hades_base_location_id+35,
    'Clear Room37': hades_base_location_id+36,
    'Clear Room38': hades_base_location_id+37,
    'Clear Room39': hades_base_location_id+38,
    'Clear Room40': hades_base_location_id+39,
    'Clear Room41': hades_base_location_id+40,
    'Clear Room42': hades_base_location_id+41,
    'Beat Bros': None,
}

location_table_styx = {
    'Clear Room43': hades_base_location_id+42,
    'Clear Room44': hades_base_location_id+43,
    'Clear Room45': hades_base_location_id+44,
    'Clear Room46': hades_base_location_id+45,
    'Clear Room47': hades_base_location_id+46,
    'Clear Room48': hades_base_location_id+47,
    'Clear Room49': hades_base_location_id+48,
    'Clear Room50': hades_base_location_id+49,
    'Clear Room51': hades_base_location_id+50,
    'Clear Room52': hades_base_location_id+51,
    'Clear Room53': hades_base_location_id+52,
    'Clear Room54': hades_base_location_id+53,
    'Clear Room55': hades_base_location_id+54,
    'Clear Room56': hades_base_location_id+55,
    'Clear Room57': hades_base_location_id+56,
    'Clear Room58': hades_base_location_id+57,
    'Clear Room59': hades_base_location_id+58,
    'Clear Room60': hades_base_location_id+59,
    'Clear Room61': hades_base_location_id+60,
    'Clear Room62': hades_base_location_id+61,
    'Clear Room63': hades_base_location_id+62,
    'Clear Room64': hades_base_location_id+63,
    'Clear Room65': hades_base_location_id+64,
    'Clear Room66': hades_base_location_id+65,
    'Clear Room67': hades_base_location_id+66,
    'Clear Room68': hades_base_location_id+67,
    'Clear Room69': hades_base_location_id+68,
    'Clear Room70': hades_base_location_id+69,
    'Clear Room71': hades_base_location_id+70,
    'Clear Room72': hades_base_location_id+71,
    'Beat Hades': None,
}

def setup_location_table():
    location_table = {
        **location_table_tartarus, 
        **location_table_asphodel,
        **location_table_elyseum,
        **location_table_styx,
    }    
    return location_table

class HadesLocation(Location):
    game: str = "Hades"

    def __init__(self, player: int, name: str, address=None, parent=None):
        super(HadesLocation, self).__init__(player, name, address, parent)
        if address is None:
            self.event = True
            self.locked = True