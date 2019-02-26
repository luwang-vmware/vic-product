from robot.libraries.OperatingSystem import OperatingSystem
from pabot.pabotlib import PabotLib

ROBOT_LISTENER_API_VERSION = 3

dict_rec = dict()

def start_suite(data, result):
    p_lib = PabotLib()
    dict_rec[data.longname] = p_lib
    tt = p_lib.acquire_value_set()
    val = p_lib.get_value_from_set('nimbus_personal_user')
    OperatingSystem().set_environment_variable('NIMBUS_PERSONAL_USER', val)

def end_suite(data, result):
     dict_rec[data.longname].release_value_set()
     del dict_rec[data.longname]
