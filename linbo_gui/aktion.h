#ifndef AKTION_H
#define AKTION_H

#include <qstring.h>
#include <cassert>

class Aktion
{
public:
    typedef enum
    {
        None,
        Reboot,
        Shutdown,
        Partition,
        InitCache,
        Autostart
   } enum_type;

private:
    enum_type _val;

public:

    Aktion(enum_type val = None);
    operator enum_type() const;
    QString toQString();
};

#endif // AKTION_H
