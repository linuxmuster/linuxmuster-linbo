#!/usr/bin/python3
#
# j_linbo.py
# thomas@linuxmuster.net
# 20160916
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

# atftpd options
OPTIONS = '--daemon --bind-address ' + serverip + ' --tftpd-timeout 300 --retry-timeout 5 --maxthread 100 --verbose=5 ' + constants.LINBODIR

# atftpd default configuration file
configfile = '/etc/default/atftpd'

# read configfile
try:
    with open(configfile, 'r') as infile:
        filedata = infile.read()
except:
    print('Cannot read ' + configfile + '!')
    exit(1)

# replace old setup comment
filedata = re.sub(r'# modified by linuxmuster-setup.*\n', '', filedata)

# add newline at the end
if not filedata[-1] == '\n':
    filedata = filedata + '\n'

# change options
filedata = re.sub(r'\nUSE_INETD=.*\n', '\nUSE_INETD=false\n', filedata)
filedata = re.sub(r'\nOPTIONS=.*\n', '\nOPTIONS="' + OPTIONS + '"\n', filedata)

# set comment
filedata = setupComment() + filedata

# write configfile
try:
    with open(configfile, 'w') as outfile:
        outfile.write(filedata)
except:
    print('Cannot write ' + configfile + '!')
    exit(1)

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
os.system('service atftpd restart')

# linbofs update
os.system('update-linbofs')

