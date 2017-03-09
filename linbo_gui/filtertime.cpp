#include "filtertime.h"
#include <QDebug>

FilterTime::FilterTime(QTimeEdit *new_timer = NULL):timer(new_timer)
{

}

int FilterTime::maximum(const QByteArray& output)
{
    qDebug() << output << "\n";
    return 100;
}

int FilterTime::value(const QByteArray& output)
{
    qDebug() << output << "\n";
    return 0;
}
