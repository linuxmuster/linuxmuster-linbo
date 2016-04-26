#ifndef COMMANDLINE_H
#define COMMANDLINE_H

#include <qstringlist.h>
#include <qstring.h>

class CommandLine
{
private:
    QStringList args;
    static const QString NOAUTO;
    static const QString NOBUTTONS;
    static const QString AUTOSTART;
    static const QString EXTRACONF;
    static const QString LINBOCMD;
    static const QString SERVER;

    int autostart;
    QString partition;
    QString extraconf;
    QString linbocmds;
    QString server;

    bool findArg(const QString& string);

public:
    CommandLine();
    bool noAuto();
    bool noButtons();
    int getAutostart();
    const QString& getConfPartition();
    const QString& getExtraConf();
    const QString& getLinbocmd();
    const QString& getServer();
};

#endif // COMMANDLINE_H
