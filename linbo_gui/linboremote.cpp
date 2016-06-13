#include "linboremote.h"
#include <QStringList>
#include <QProcess>

const QString LinboRemote::LINBOREMOTE = QString("linbo_wrapper");

bool LinboRemote::is_running()
{
    QProcess pgrep;
    QString cmd = QString("pgrep");
    QStringList args = QStringList() << LinboRemote::LINBOREMOTE;
    pgrep.start(cmd, args);
    pgrep.waitForReadyRead();
    QByteArray bytes = pgrep.readAllStandardOutput();
    return !bytes.isEmpty();
}

QStringList LinboRemote::get_commandline()
{
    QProcess ps;
    QString cmd = QString("ps");
    QStringList args  = QStringList() << "-C";
    args << LinboRemote::LINBOREMOTE;
    args << "--no-headers" << "-o" << "command";
    ps.start(cmd,args);
    ps.waitForReadyRead();
    QByteArray bytes = ps.readAllStandardOutput();
    if(!bytes.isEmpty()){
        QStringList lines = QString(bytes).split("\n").at(0).split(" ");
        return lines;
    } else {
        return QStringList();
    }
}
