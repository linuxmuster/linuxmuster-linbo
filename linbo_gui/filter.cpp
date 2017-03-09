#include "filter.h"

Filter::Filter()
{

}

int Filter::maximum(const QByteArray& output)
{
    return 100;
}

int Filter::value(const QByteArray& output)
{
    return 0;
}
