#include "aktion.h"

#include <qstring.h>


Aktion::Aktion(enum_type val): _val(val)
{
    assert(val <= Autostart);
}

Aktion::operator enum_type() const { return _val; }

QString Aktion::toQString(){
    switch(_val){
    default:
    case None:
        return QString("Keine");
    case Reboot:
        return QString("Neustarten");
    case Shutdown:
        return QString("Ausschalten");
    case Partition:
        return QString("Autopartition");
    case InitCache:
        return QString("Autoinitcache");
    case Autostart:
        return QString("Autostart");
    }
}
