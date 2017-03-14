#ifndef FILTERREGEX_H
#define FILTERREGEX_H

#include <QObject>
#include <QRegularExpression>
#include <QTextCodec>

#include "filter.h"
#include "filter.h"

/*
 * FilterRegex
 * -----------
 *
 * Der Filter wird mit 2-3 Ausdrücken initialisiert, die den Maximalwert und den aktuellen
 * Wert sowie einen Titelanhang aus der gefilteren Ausgabe herausfiltern.
 * Jeder der beiden Ausdrücke enthält genau eine gefilterte ganze Zahl.
 *
 */

class FilterRegex : public Filter
{

private:
    int _maximum;
    int _value;
    QString _title;
    QTextCodec *codec;
    QRegularExpression maxMatcher;
    QRegularExpression valMatcher;
    QRegularExpression titleMatcher;

public:
    FilterRegex(QObject *parent, const QString& valPattern, const QString& maxPattern = 0, const QString& titlePattern = 0);
    virtual ~FilterRegex();
    virtual void filter(const QByteArray &output);
};

#endif // FILTERREGEX_H
