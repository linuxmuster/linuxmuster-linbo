#include <unistd.h>
#include <qapplication.h>

#include "linboMulticastBox.h"
#include "ui_linboMulticastBox.h"
#include "downloadtype.h"

linboMulticastBox::linboMulticastBox(  QWidget* parent, bool formatCache, DownloadType type ) : QDialog(parent), ui(new Ui::linboMulticastBox)
{
  ui->setupUi(this);
  ui->checkFormat->setChecked(formatCache);
  switch(type){
  case RSync:
      ui->rsyncButton->setChecked(true);
      break;
  case Multicast:
      ui->multicastButton->setChecked(true);
      break;
  case Torrent:
      ui->torrentButton->setChecked(true);
      break;
  }
}

linboMulticastBox::~linboMulticastBox()
{
    delete ui;
} 


void linboMulticastBox::on_okButton_clicked()
{
    if(ui->rsyncButton->isChecked())
        emit( finished(ui->checkFormat->isChecked(), DownloadType::RSync));
    else if(ui->multicastButton->isChecked())
        emit( finished(ui->checkFormat->isChecked(), DownloadType::Multicast));
    else
        emit( finished(ui->checkFormat->isChecked(), DownloadType::Torrent));
    this->accept();
}
