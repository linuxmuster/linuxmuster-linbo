#include "linboremote.h"
#include <QStringList>
#include <QProcess>
#include <QFile>

const QString LinboRemote::LINBOREMOTE = QString("linbo_wrapper");
//const QString LinboRemote::LINBOREMOTE = QString("mount.exfat");//TEST

bool LinboRemote::is_running()
{
    return get_pid() != 0;
}

int LinboRemote::get_pid()
{
    QProcess pgrep;
    QString cmd = QString("pidof");
    QStringList args = QStringList() << LinboRemote::LINBOREMOTE;
    pgrep.start(cmd, args);
    pgrep.waitForReadyRead();
    QByteArray bytes = pgrep.readAllStandardOutput();
    if(!bytes.isEmpty()){
        bool ok;
        int pid = QString(bytes).split("\n").at(0).split(" ").at(0).toInt(&ok);
        if(ok){
            return pid;
        }
    }
    return 0;
}

QStringList LinboRemote::get_commandline()
{
    int pid = get_pid();
    if(pid < 1){
        return QStringList();
    }
    QFile cmdline(QString("/proc/")+QString::number(pid)+QString("/cmdline"));
    if(!cmdline.open(QIODevice::ReadOnly)){
        return QStringList();
    }
    QByteArray bytes = cmdline.readAll();
    if(bytes.isEmpty()){
        return QStringList();
    }
    bytes.replace(0,'\n');
    QStringList lines = QString(bytes).split("\n", QString::SkipEmptyParts);

    return lines;
}
