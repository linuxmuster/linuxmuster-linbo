#ifndef LINBOIMAGEWIDGET_H
#define LINBOIMAGEWIDGET_H

#include <qwidget.h>

namespace Ui {
    class LinboImageWidget;
}

class LinboImageWidget : public QWidget
{
    Q_OBJECT
    Q_PROPERTY(QString osname READ osname WRITE setOsname NOTIFY osnameChanged)

public:
    LinboImageWidget(QWidget *parent = 0);
    QString osname() const;

public slots:
    void setOsname(const QString& new_osname);

signals:
    void osnameChanged(const QString& new_osname);
    void doCreate();
    void doUpload();

private:
    Ui::LinboImageWidget *ui;
};

#endif
