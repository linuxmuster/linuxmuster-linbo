#ifndef FILTER_H
#define FILTER_H

#include <QObject>

class Filter : public QObject
{
    Q_OBJECT

public:
    explicit Filter(QObject *parent);
    ~Filter();
    virtual void filter(const QByteArray& output) = 0;

signals:
    void titleChanged(const QString& title);
    void maximumChanged(int maximum);
    void valueChanged(int value);

public slots:
};

#endif // FILTER_H
