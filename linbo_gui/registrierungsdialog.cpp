#include "registrierungsdialog.h"
#include "ui_registrierungsdialog.h"

RegistrierungsDialog::RegistrierungsDialog(QWidget *parent) :
    QDialog(parent),
    ui(new Ui::RegistrierungsDialog)
{
    ui->setupUi(this);
}

RegistrierungsDialog::~RegistrierungsDialog()
{
    delete ui;
}
