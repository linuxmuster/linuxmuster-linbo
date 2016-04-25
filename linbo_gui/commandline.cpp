#include <qfile.h>
#include <qdebug.h>
#include <qtextstream.h>
#include <qstringlist.h>

#include "commandline.h"

const QString CommandLine::NOAUTO = QString("noauto");
const QString CommandLine::NOBUTTONS = QString("nobuttons");
const QString CommandLine::AUTOSTART = QString("autostart");
const QString CommandLine::CONF = QString("conf");
const QString CommandLine::LINBOCMD = QString("linbocmd");

CommandLine::CommandLine(): args(),autostart(-1),conf(),extraconf()
{
    QFile cmdline("/proc/cmdline");
    if(!cmdline.open(QIODevice::ReadOnly)){
        qWarning()<<"Could not open /proc/cmdline\n";
        return;
    }
    QTextStream ts( &cmdline );
    args = ts.readAll().split(" ");
    foreach(QString s, args){
        if(s.compare(AUTOSTART + QString("=*"),Qt::CaseInsensitive) == 0){
            QString value = s.split("=")[1];
            if(value.compare("no") == 0)
                autostart = -1;
            else
                autostart = value.toInt();
        }
        else if(s.compare(CONF + QString("=*")) == 0){
            QString value = s.split("=")[2];
            if(value.contains(":")){
                conf = value.split(":")[0];
                extraconf = value.split(":")[1];
            }
            else {
                conf = value;
            }
        }
        else if(s.compare(LINBOCMD + QString("=*")) == 0){
            linbocmds = s.split("=")[2];
        }
    }
    // read wrapper commands from downloaded file and remove file
    QFile linbocmdfile("/linbocmd");
    if(!linbocmdfile.open(QIODevice::ReadOnly)){
        qDebug() << "No file /linbocmd found.";
        return;
    }
    else {
        qDebug() << "File /linbocmd found.";
        QTextStream ts(&linbocmdfile);
        if(linbocmds.size() > 0){
            linbocmds.append(";");
            linbocmds.append(linbocmdfile.readAll());
        }
        // TODO: noauto , nobuttons bool create and read from commandline or linbocmd
        system("rm -f /linbocmd");
    }
}

bool CommandLine::findArg(const QString& string)
{
    QStringListIterator it(args);
    while(it.hasNext()){
        if(it.next().compare(string, Qt::CaseInsensitive) == 0)
            return true;
    }
    return false;
}

bool CommandLine::noAuto()
{
    return findArg(NOAUTO);
}

bool CommandLine::noButtons()
{
    return findArg(NOBUTTONS);
}

int CommandLine::getAutostart()
{
    return autostart;
}

const QString& CommandLine::getConf()
{
    return conf;
}

const QString& CommandLine::getExtraConf()
{
    return extraconf;
}

const QString& CommandLine::getLinbocmd()
{
    return linbocmds;
}
