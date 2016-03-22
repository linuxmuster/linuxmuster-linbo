#ifndef LINBOOSWIDGET_H
#define LINBOOSWIDGET_H

#include <qwidget.h>
#include <qlabel.h>
#include <qtoolbutton.h>

namespace Ui {
    class LinboOSWidget;
}

class LinboOSWidget : public QWidget
{
    Q_OBJECT
    Q_PROPERTY(QString osname READ osname WRITE setOsname NOTIFY osnameChanged)

public:
    LinboOSWidget(QWidget *parent = 0);
    QString osname() const;

public slots:
    void setOsname(const QString& new_osname);

signals:
    void osnameChanged(const QString& new_osname);
    void doDefault();
    void doStart();
    void doSync();
    void doNew();
    void doInfo();

private:
    Ui::LinboOSWidget *ui;
};

#endif
