#ifndef FILTER_H
#define FILTER_H

#include <qbytearray.h>

class Filter
{
public:
    Filter();
    int maximum(const QByteArray& output);
    int value(const QByteArray& output);
};

#endif // FILTER_H
