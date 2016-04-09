#include <unistd.h>
#include <qprogressbar.h>
#include <qapplication.h>
#include <qlistwidget.h>
#include <QtGui>
#include <QDesktopWidget>

#include "linboImageUpload.h"
#include "ui_linboImageUpload.h"
#include "image_description.h"

linboImageUpload::linboImageUpload(  QWidget* parent, int newnr, vector<image_item>* newImage ) : QDialog(parent),
     nr(newnr), image(newImage), ui(new Ui::linboImageUpload)
{
    ui->setupUi(this);
    if( image != NULL){
        for(int i=0; i < image->size(); i++){
            ui->listBox->addItem(image->at(i).get_image());
        }
    }
}

linboImageUpload::~linboImageUpload()
{
    delete ui;
} 

QListWidgetItem* linboImageUpload::findImageItem(QString imageItem)
{
    QList<QListWidgetItem*> result = ui->listBox->findItems(imageItem, Qt::MatchCaseSensitive);
    if( result.size() > 0 ) {
        return result.first();
    } else {
        return NULL;
    }
}

void linboImageUpload::on_okButton_clicked()
{
    QString imageName = ui->listBox->currentItem()->text();
    FolgeAktion aktion;
    if( ui->checkReboot->isChecked())
        aktion = FolgeAktion::Reboot;
    else if( ui->checkShutdown->isChecked())
        aktion = FolgeAktion::Shutdown;
    else
        aktion = FolgeAktion::None;

    emit(finished(nr, imageName, aktion));
    this->accept();
}
