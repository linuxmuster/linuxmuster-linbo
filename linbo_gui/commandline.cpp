#include <qfile.h>
#include <qdebug.h>
#include <qtextstream.h>
#include <qstringlist.h>

#include "commandline.h"

const QString CommandLine::NOAUTO = QString("noauto");
const QString CommandLine::NOBUTTONS = QString("nobuttons");
const QString CommandLine::AUTOSTART = QString("autostart");
const QString CommandLine::EXTRACONF = QString("conf");
const QString CommandLine::LINBOCMD = QString("linbocmd");
const QString CommandLine::SERVER = QString("server");
const QString CommandLine::CACHE = QString("cache");

CommandLine::CommandLine(): args(),autostart(-1),extraconf(),server(),cache()
{
    QFile f("/proc/cmdline");
    if(!f.open(QIODevice::ReadOnly)){
        qWarning()<<"Could not open /proc/cmdline\n";
        return;
    }
    QTextStream ts( &f );
    QString cmdline = ts.readAll();
    cmdline = QString("noauto");
    args = cmdline.split(" ");
    foreach(QString s, args){
        if(s.startsWith(AUTOSTART + QString("="),Qt::CaseInsensitive)){
            QString value = s.split("=")[1];
            autostart = value.toUInt();
        }
        else if(s.startsWith(EXTRACONF + QString("="))){
            QString value = s.split("=")[1];
            if(value.contains(":")){
                partition = value.split(":")[0];
                extraconf = value.split(":")[1];
            }
            else {
                extraconf = value;
            }
        }
        else if(s.startsWith(LINBOCMD + QString("="))){
            linbocmds = s.split("=")[1];
        }
        else if(s.startsWith(SERVER + QString("="))){
            server = s.split("=")[1];
        }
        else if(s.startsWith(CACHE + QString("="))){
            cache = s.split("=")[1];
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
            linbocmds.append(",");
            linbocmds.append(linbocmdfile.readAll());
        }
        if(linbocmds.contains(" ")){
            QStringList largs = linbocmds.split(" ");
            linbocmds = largs[0];
            largs.removeFirst();
            foreach(QString s, largs){
                if(s.compare(NOAUTO, Qt::CaseInsensitive) == 0 || s.compare(NOBUTTONS, Qt::CaseInsensitive) == 0){
                    args.append(s);
                }
            }
        }
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

unsigned int CommandLine::getAutostart()
{
    return autostart;
}

const QString& CommandLine::getConfPartition()
{
    return partition;
}

const QString& CommandLine::getExtraConf()
{
    return extraconf;
}

const QString& CommandLine::getLinbocmd()
{
    return linbocmds;
}

const QString& CommandLine::getServer()
{
    return server;
}

const QString& CommandLine::getCache()
{
    return cache;
}
