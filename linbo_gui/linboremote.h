#ifndef LINBOREMOTE_H
#define LINBOREMOTE_H

#include <QStringList>

class LinboRemote
{
private:
    static const QString LINBOREMOTE;

public:
    bool static is_running();
    int static get_pid();
    static QStringList get_commandline();
};

#endif // LINBOREMOTE_H
