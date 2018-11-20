#include <unistd.h>
#include <qprogressbar.h>
#include <qapplication.h>
#include <qlistwidget.h>
#include <QtGui>
#include <QWidget>

#include "linboImageUpload.h"
#include "ui_linboImageUpload.h"
#include "image_description.h"

linboImageUpload::linboImageUpload(  QWidget* parent, vector<image_item>* new_history ) : QDialog(parent),
     history(new_history), ui(new Ui::linboImageUpload)
{
    ui->setupUi(this);
    if( history != NULL){
        for(vector<image_item>::iterator it = history->begin();it != history->end();++it){
            ui->listBox->addItem(((image_item)*it).get_image());
        }
        if(ui->listBox->count() > 0)
            ui->listBox->setCurrentRow(0);
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
    Aktion aktion;
    if( ui->checkReboot->isChecked())
        aktion = Aktion::Reboot;
    else if( ui->checkShutdown->isChecked())
        aktion = Aktion::Shutdown;
    else
        aktion = Aktion::None;

    emit(finished(imageName, aktion));
    this->accept();
}
