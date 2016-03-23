#include <unistd.h>
#include <qprogressbar.h>
#include <qapplication.h>
#include <QtGui>
#include <QDesktopWidget>

#include "linboRegisterBox.h"
#include "ui_linboRegisterBox.h"


linboRegisterBox::linboRegisterBox(  QWidget* parent) :
    QDialog(parent), ui(new Ui::linboRegisterBox)
{
  ui->setupUi(this);

  Qt::WindowFlags flags;
  flags = Qt::Dialog | Qt::WindowStaysOnTopHint | Qt::WindowTitleHint;
  setWindowFlags( flags );

}

linboRegisterBox::linboRegisterBox(  QWidget* parent, QString& roomName, QString& clientName,
                                     QString& ipAddress, QString& clientGroup) :
    QDialog(parent), ui(new Ui::linboRegisterBox)
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

linboRegisterBox::~linboRegisterBox()
{
} 

void linboRegisterBox::accept()
{
    QString *roomName = new QString(ui->roomName->text());
    QString *clientName = new QString(ui->clientName->text());
    QString *ipAddress = new QString(ui->ipAddress->text());
    QString *clientGroup = new QString(ui->clientGroup->text());

    emit(finished(*roomName, *clientName, *ipAddress, *clientGroup));
    close();
}
