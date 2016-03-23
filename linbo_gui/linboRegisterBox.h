#ifndef LINBOREGISTERBOX_H
#define LINBOREGISTERBOX_H

#include <qobject.h>
#include <qdialog.h>

namespace Ui {
class linboRegisterBox;
}

class linboRegisterBox : public QDialog
{
    Q_OBJECT

public:
    linboRegisterBox( QWidget* parent = 0);
    linboRegisterBox( QWidget* parent, QString& roomName, QString& clientName,
                      QString& ipAddress, QString& clientGroup);
    ~linboRegisterBox();

signals:
    void finished(QString& roomName, QString& clientName, QString& ipAddress, QString& clientGroup);

private slots:
    void accept();

private:
    Ui::linboRegisterBox *ui;
};
#endif
