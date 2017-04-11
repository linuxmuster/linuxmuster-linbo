#ifndef REGISTRIERUNGSDIALOG_H
#define REGISTRIERUNGSDIALOG_H

#include <QDialog>

namespace Ui {
class RegistrierungsDialog;
}

class RegistrierungsDialog : public QDialog
{
    Q_OBJECT

public:
    explicit RegistrierungsDialog(QWidget *parent = 0);
    RegistrierungsDialog( QWidget* parent, QString& roomName, QString& clientName,
                      QString& ipAddress, QString& clientGroup);
    ~RegistrierungsDialog();

signals:
    void finished(QString& roomName, QString& clientName, QString& ipAddress, QString& clientGroup);

private slots:
    virtual void accept();

private:
    Ui::RegistrierungsDialog *ui;
};

#endif // REGISTRIERUNGSDIALOG_H
