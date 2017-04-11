#include "filtertime.h"
#include <QDebug>

FilterTime::FilterTime(QObject *parent, QTimeEdit *new_timer):
    Filter(parent), timer(new_timer)
{
    if(timer != 0){
        connect(timer,&QTimeEdit::timeChanged,this,&FilterTime::timeChanged);
    }
}

void FilterTime::timeChanged(const QTime& time)
{
    valueChanged(time.second()*10/6);
}

void FilterTime::filter(const QByteArray &output){}
