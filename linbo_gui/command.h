#ifndef COMMAND_H
#define COMMAND_H

#include <vector>

#include <qprocess.h>
#include <qstring.h>
#include <qstringlist.h>

#include "configuration.h"
#include "image_description.h"

class Command
{
private:
    Configuration *conf;
    QString password;

    void saveappend( QStringList& command, const QString& item );

public:
    Command(Configuration *conf);
    ~Command();

    QStringList mksyncstartcommand(int osnr, int imnr);
    QStringList mksynccommand(int osnr, int imnr);
    QStringList mksyncrcommand(int osnr, int imnr);
    QStringList mkpartitioncommand();
    QStringList mkpartitioncommand_noformat();
    // type is 0 for rsync, 1 for multicast, 3 for bittorrent
    QStringList mkcacheinitcommand(const QString& type);
    QStringList mklinboupdatecommand();

    QString doSimpleCommand(const QString& cmd);
    QString doSimpleCommand(const QString& cmd, const QString& arg);
    bool doAuthenticateCommand(const QString& password);
    void clearPassword();

    QStringList mkuploadcommand();
    QStringList mkpreregistercommand();
    QStringList mkregistercommand(QString& roomName, QString& clientName,
                                  QString& ipAddress, QString& clientGroup);
};

#endif // COMMAND_H
