#ifndef COMMAND_H
#define COMMAND_H

#include <vector>

#include <qprocess.h>
#include <qstring.h>
#include <qstringlist.h>

#include "configuration.h"
#include "image_description.h"
#include "downloadtype.h"

class Command
{
private:
    static const QString USER;

    Configuration *conf;
    QString password;

    void saveappend( QStringList& command, const QString& item );
    QStringList parseWrapperCommand(const QString& input);

public:
    Command(Configuration *conf);
    ~Command();

    static const QString BASEIMGEXT;
    static const QString INCIMGEXT;
    static const QString DESCEXT;
    static const QString TMPDIR;
    static const QString LINBOCMDSEP;

    vector<QStringList> parseWrapperCommands(const QString& input);

    QStringList mkstartcommand(unsigned int osnr, int imnr = -1);
    QStringList mksyncstartcommand(unsigned int osnr, int imnr = -1, bool format = false);
    QStringList mksynccommand(unsigned int osnr, int imnr = -1);
    QStringList mksyncrcommand(unsigned int osnr, int imnr = -1);
    QStringList mkpartitioncommand();
    QStringList mkpartitioncommand_noformat();
    QStringList mkcacheinitcommand(bool formatCache, DownloadType type);
    QStringList mklinboupdatecommand();

    QString doSimpleCommand(const QString& cmd);
    QString doSimpleCommand(const QString& cmd, const QString& arg);
    bool doAuthenticateCommand(const QString& password);
    void clearPassword();

    void doReadfileCommand(const QString &source, const QString &destination);
    void doWritefileCommand(const QString &source, const QString &destination);


    QStringList mkcreatecommand(unsigned int nr, const QString& imageName, const QString& baseImage);
    QStringList mkuploadcommand(const QString& imageName);
    QStringList mkpreregistercommand();
    QStringList mkregistercommand(QString& roomName, QString& clientName,
                                  QString& ipAddress, QString& clientGroup);
};

#endif // COMMAND_H
