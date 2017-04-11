#ifndef DOWNLOADTYPE_H
#define DOWNLOADTYPE_H

#include <qstring.h>

enum DownloadType {
    RSync,
    Multicast,
    Torrent
};

extern QString downloadtypeQString[];

#endif // DOWNLOADTYPE_H
