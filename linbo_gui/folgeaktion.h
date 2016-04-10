#ifndef FOLGEAKTION_H
#define FOLGEAKTION_H

#include <qstring.h>

enum FolgeAktion {
    None,
    Reboot,
    Shutdown
};

extern QString folgeAktionQString[];

#endif // FOLGEAKTION_H
