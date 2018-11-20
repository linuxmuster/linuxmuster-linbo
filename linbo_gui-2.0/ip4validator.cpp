#include <QValidator>
#include <QDebug>

#include "ip4validator.h"

IP4Validator::IP4Validator(QObject *parent) : QValidator(parent)
{
}

void IP4Validator::fixup(QString &input) const
{
    while(input.contains(" "))
        input.remove(input.indexOf(" "), 1);
}

QValidator::State IP4Validator::validate(QString &input, int &pos) const {
    qDebug() << "Cursor at pos " << pos;
    if(input.isEmpty()) return Acceptable;
    QStringList slist = input.split(".");
    int s = slist.size();
    if(s>4) return Invalid;
    bool emptyGroup = false;
    for(int i=0;i<s;i++){
        bool ok;
        if(slist[i].isEmpty()){
            emptyGroup = true;
            continue;
        }
        int val = slist[i].toInt(&ok);
        if(!ok || val<0 || val>255) return Invalid;
    }
    if(s<4 || emptyGroup) return Intermediate;
    return Acceptable;
}
