#ifndef FILTERCREATE_H
#define FILTERCREATE_H

#include "filter.h"

class FilterCreate : public Filter
{
public:
    FilterCreate();
    int maximum(const QByteArray& output);
    int value(const QByteArray& output);
};

#endif // FILTERCREATE_H
