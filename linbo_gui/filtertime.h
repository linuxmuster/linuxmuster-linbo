#ifndef FILTERTIME_H
#define FILTERTIME_H

#include <QTimeEdit>
#include "filter.h"

class FilterTime : public Filter
{
    QTimeEdit *timer;

public:
    FilterTime(QTimeEdit *new_timer);
    int maximum(const QByteArray& output);
    int value(const QByteArray& output);
};

#endif // FILTERTIME_H
