#ifndef COMMAND_H
#define COMMAND_H

#include <vector>

#include <qstring.h>
#include <qstringlist.h>

#include "configuration.h"
#include "image_description.h"

class Command
{
private:
    Configuration *conf;
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
};

#endif // COMMAND_H
