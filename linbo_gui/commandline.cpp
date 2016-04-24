#include <qfile.h>
#include <qtextstream.h>
#include <qstringlist.h>

#include "commandline.h"

const QString CommandLine::NOAUTO = QString("noauto");
const QString CommandLine::NOBUTTONS = QString("nobuttons");
const QString CommandLine::AUTOSTART = QString("autostart");
const QString CommandLine::CONF = QString("conf");

CommandLine::CommandLine(): args(),autostart(-1),conf(NULL),extraconf(NULL)
{
    QFile cmdline("/proc/cmdline");
    if(!cmdline.open(QIODevice::ReadOnly)){
        qWarning<<"Could not open /proc/cmdline\n";
        return;
    }
    QTextStream ts( cmdline );
    args = ts.readAll().split(" ");
    foreach(QString s : args){
        if(s.matches(AUTOSTART + QString("=*"),Qt::CaseInsensitive)){
            QString value = s.split("=")[1];
            if(value.compare("no") == 0)
                autostart = -1;
            else
                autostart = value.toInt();
        }
        else if(s.matches(CONF + QString("=*"))){
            QString value = s.split("=")[2];
            if(value.contains(":")){
                conf = value.split(":")[0];
                extraconf = value.split(":")[1];
            }
            else {
                conf = value;
            }
        }
    }
}

bool CommandLine::noAuto()
{
    return args != NULL && args.contains(NOAUTO, Qt::CaseInsensitive);
}

bool CommandLine::noButtons()
{
    return args != NULL && args.contains(NOBUTTONS, Qt::CaseInsensitive);
}

int CommandLine::getAutostart()
{
    return autostart;
}
