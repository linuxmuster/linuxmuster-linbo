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
    static const QString CACHE;

    unsigned int autostart;
    QString partition;
    QString extraconf;
    QString linbocmds;
    QString server;
    QString cache;

    bool findArg(const QString& string);

public:
    CommandLine();
    bool noAuto();
    bool noButtons();
    unsigned int getAutostart();
    const QString& getConfPartition();
    const QString& getExtraConf();
    const QString& getLinbocmd();
    const QString& getServer();
    const QString& getCache();
};

#endif // COMMANDLINE_H
