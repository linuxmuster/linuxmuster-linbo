#include <unistd.h>
#include <qprogressbar.h>
#include <qapplication.h>
#include <qbuttongroup.h>
#include <qlistwidget.h>
#include <QtGui>
#include <qradiobutton.h>
#include <QTextStream>
#include <QDesktopWidget>

#include "linboImageSelector.h"
#include "ui_linboImageSelector.h"
#include "linboImageUpload.h"
#include "aktion.h"

const QString& linboImageSelector::NEWNAME = QString("[Neuer Dateiname]");

linboImageSelector::linboImageSelector(  QWidget* parent, int newnr,
                                         vector<image_item>* new_history,
                                         Command* newCommand ) : QDialog(parent),
    nr(newnr), history(new_history), command(newCommand), upload(false),
    ui(new Ui::linboImageSelector)
{
    ui->setupUi(this);
    if(history != NULL){
        for(vector<image_item>::iterator it = history->begin(); it != history->end();++it)
            ui->listBox->addItem(((image_item)*it).get_image());
    }
    ui->listBox->addItem(NEWNAME);
    ui->listBox->setCurrentRow(0);
}

linboImageSelector::~linboImageSelector()
{
    delete ui;
} 

void linboImageSelector::finish() {
    QString imageName, info;
    bool isnew;
    Aktion folgeAktion;

    imageName = ui->listBox->currentItem()->text();

    isnew = imageName.compare(NEWNAME) == 0;

    if( isnew ){
        imageName = ui->specialName->text();
        if( imageName.isEmpty() )
            return;
        if( ui->incrRadioButton->isChecked() && ! imageName.endsWith(Command::INCIMGEXT))
            imageName += QString(".rsync");
        else if ( ui->baseRadioButton->isChecked() && ! imageName.endsWith(Command::BASEIMGEXT)) {
            imageName += QString(".cloop");
        }
    }

    if( ! ui->infoEditor->toPlainText().isEmpty()){
        info = ui->infoEditor->toPlainText();
    } else if( isnew ){
        info = QString(" Informationen zu " + imageName + ":");
    } else {
        info = QString("Beschreibung");
    }

    folgeAktion = Aktion::None;

    if ( ui->checkShutdown->isChecked() ) {
        folgeAktion = Aktion::Shutdown;
    } else if ( ui->checkReboot->isChecked() ) {
        folgeAktion = Aktion::Reboot;
    } else {
        folgeAktion = Aktion::None;
    }
    emit(finished(nr, imageName, info, isnew, upload, folgeAktion));
}


void linboImageSelector::on_listBox_itemSelectionChanged()
{
    // if(this->isHidden()) return ev. wegen exception im constructor???
    if( ui->listBox->currentItem() == NULL)
        return;
    QString item(ui->listBox->currentItem()->text());
    bool neu = item.compare(NEWNAME) == 0;
    ui->baseRadioButton->setEnabled(neu);
    ui->incrRadioButton->setEnabled(neu);
    ui->specialName->setEnabled(neu);

    if(command != NULL){
        item += command->DESCEXT;
        QString destination(command->TMPDIR + item);
        command->doReadfileCommand(item, destination);
        QFile* file = new QFile( destination );
        // read content
        if( !file->open( QIODevice::ReadOnly ) ) {
            //FIXME: logConsole->writeStdErr( QString("Keine passende Beschreibung im Cache.") );
        }
        else {
            QTextStream ts( file );
            ui->infoEditor->setText( ts.readAll() );
            file->close();
        }
        delete file;
    }
}

void linboImageSelector::on_createButton_clicked()
{
    upload = false;
    finish();
    this->accept();
}

void linboImageSelector::on_createUploadButton_clicked()
{
    upload = true;
    finish();
    this->accept();
}
