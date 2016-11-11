#!/usr/bin/python3
#
# j_linbo.py
# thomas@linuxmuster.net
# 20161111
#

import configparser
import constants
import os
import re

from functions import setupComment
from functions import backupCfg

print ('### ' + os.path.basename(__file__))

# read INIFILE, get schoolname
i = configparser.ConfigParser()
i.read(constants.SETUPINI)
adminpw = i.get('setup', 'adminpw')
serverip = i.get('setup', 'serverip')

# rsyncd secrets
configfile = '/etc/rsyncd.secrets'

# create filedata
filedata = setupComment() + '\n' + 'linbo:' + adminpw + '\n'

# write configfile
try:
    with open(configfile, 'w') as outfile:
        outfile.write(filedata)
except:
    print('Cannot write ' + configfile + '!')
    exit(1)

# permissions
os.system('chmod 600 ' + configfile)

# restart services
os.system('service rsync restart')

# linbofs update
os.system('update-linbofs')

