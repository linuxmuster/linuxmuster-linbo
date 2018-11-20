#include <unistd.h>
#include <qapplication.h>
#include <QtGui>
#include <qtextstream.h>
#include <QWidget>

#include "linboDescBrowser.h"
#include "ui_linboDescBrowser.h"

linboDescBrowser::linboDescBrowser(QWidget* parent, const QString& newFilename, const QString& newDesc, bool newReadOnly ) : QDialog( parent ),
filename(newFilename), ui(new Ui::linboDescBrowser)
{
   ui->setupUi(this);
   ui->editor->setText(newDesc);
    if ( newReadOnly ) {
        ui->saveButton->setText("Schließen");
        ui->saveButton->setEnabled( true );
        ui->editor->setReadOnly( true );
    } else {
        ui->saveButton->setText("Speichern");
        ui->saveButton->setEnabled( true );
        ui->editor->setReadOnly( false );
    }
}

linboDescBrowser::~linboDescBrowser()
{
  delete ui;
} 

void linboDescBrowser::on_saveButton_clicked()
{
    if(! ui->editor->isReadOnly() ){
        emit( writeDesc( filename, ui->editor->toPlainText() ));
    }
    this->accept();
}
