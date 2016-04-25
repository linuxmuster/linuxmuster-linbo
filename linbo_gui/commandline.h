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
    static const QString CONF;
    static const QString LINBOCMD;

    int autostart;
    QString conf;
    QString extraconf;
    QString linbocmds;

    bool findArg(const QString& string);

public:
    CommandLine();
    bool noAuto();
    bool noButtons();
    int getAutostart();
    const QString& getConf();
    const QString& getExtraConf();
    const QString& getLinbocmd();
};

#endif // COMMANDLINE_H
