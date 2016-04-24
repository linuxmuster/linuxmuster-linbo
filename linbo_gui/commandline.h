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
    int autostart;
    QString conf;
    QString extraconf;

public:
    CommandLine();
    bool noAuto();
    bool noButtons();
    int getAutostart();
    const QString& getConf();
    const QString& getExtraConf();
};

#endif // COMMANDLINE_H
