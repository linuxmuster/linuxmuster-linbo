#ifndef FILTERTIME_H
#define FILTERTIME_H

#include <QTimeEdit>
#include <QTime>
#include <QObject>
#include <QString>

#include "filter.h"

class FilterTime : public Filter
{

private:
    QTimeEdit *timer;
private slots:
    void timeChanged(const QTime& time);

public:
    virtual void filter(const QByteArray &output);
    FilterTime(QObject *parent, QTimeEdit *new_timer);
};

#endif // FILTERTIME_H
