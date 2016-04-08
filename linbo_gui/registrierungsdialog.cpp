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

RegistrierungsDialog::RegistrierungsDialog(  QWidget* parent, QString& roomName, QString& clientName,
                                     QString& ipAddress, QString& clientGroup) :
    QDialog(parent), ui(new Ui::RegistrierungsDialog)
{
  ui->setupUi(this);

  ui->roomName->setText(roomName);
  ui->clientName->setText(clientName);
  ui->ipAddress->setText(ipAddress);
  ui->clientGroup->setText(clientGroup);

  Qt::WindowFlags flags;
  flags = Qt::Dialog | Qt::WindowStaysOnTopHint | Qt::WindowTitleHint;
  setWindowFlags( flags );

}

void RegistrierungsDialog::accept()
{
    QString *roomName = new QString(ui->roomName->text());
    QString *clientName = new QString(ui->clientName->text());
    QString *ipAddress = new QString(ui->ipAddress->text());
    QString *clientGroup = new QString(ui->clientGroup->text());

    emit(finished(*roomName, *clientName, *ipAddress, *clientGroup));
    close();
}
