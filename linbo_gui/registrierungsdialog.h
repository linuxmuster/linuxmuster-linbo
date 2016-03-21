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
    ~RegistrierungsDialog();

private:
    Ui::RegistrierungsDialog *ui;
};

#endif // REGISTRIERUNGSDIALOG_H
