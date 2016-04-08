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
#include "folgeaktion.h"

linboImageSelector::linboImageSelector(  QWidget* parent, Command* newCommand ) : QDialog(parent),
    command(newCommand), upload(false), ui(new Ui::linboImageSelector)
{
    ui->setupUi(this);
}

linboImageSelector::~linboImageSelector()
{
    delete ui;
} 

void linboImageSelector::finish() {
    QString imageName, info;
    bool isnew;
    FolgeAktion folgeAktion;

    imageName = ui->listBox->currentItem()->text();

    isnew = imageName.compare("[Neuer Dateiname]") == 0;

    if( isnew ){
        imageName = ui->specialName->text();
        if( imageName.isEmpty() )
            return;
        if( ui->incrRadioButton->isChecked() && ! imageName.endsWith(".rsync"))
            imageName += QString(".rsync");
        else if ( ui->baseRadioButton->isChecked() && ! imageName.endsWith(".cloop")) {
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

    folgeAktion = FolgeAktion::None;

    if ( ui->checkShutdown->isChecked() ) {
        folgeAktion = FolgeAktion::Shutdown;
    } else if ( ui->checkReboot->isChecked() ) {
        folgeAktion = FolgeAktion::Reboot;
    } else {
        folgeAktion = FolgeAktion::None;
    }
    emit(finished(nr, imageName, info, isnew, upload, folgeAktion));
}


void linboImageSelector::on_listBox_itemSelectionChanged()
{
    // if(this->isHidden()) return ev. wegen exception im constructor???
    if( ui->listBox->currentItem() == NULL)
        return;
    QString item(ui->listBox->currentItem()->text());
    bool neu = item.compare(QString("[Neuer Dateiname]")) == 0;
    ui->baseRadioButton->setEnabled(neu);
    ui->incrRadioButton->setEnabled(neu);
    ui->specialName->setEnabled(neu);

    if(command != NULL){
        item += QString(".desc");
        QString destination(QString("/tmp/") + item);
        command->doReadfileCommand(item, destination);
        QFile* file = new QFile( myLoadCommand[4] );
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
