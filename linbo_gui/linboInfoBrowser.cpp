#include <unistd.h>
#include <qapplication.h>
#include <QtGui>
#include <qtextstream.h>
#include <QDesktopWidget>

#include "linboInfoBrowser.h"
#include "ui_linboInfoBrowser.h"

linboInfoBrowser::linboInfoBrowser(QWidget* parent, const QString& newFilename, const QString& newInfo, bool newReadOnly ) : QDialog( parent ),
filename(newFilename), ui(new Ui::linboInfoBrowser)
{
   ui->setupUi(this);
   ui->editor->setText(newInfo);
    if ( newReadOnly ) {
      ui->saveButton->setText("Speichern");
      ui->saveButton->setEnabled( true );
      ui->editor->setReadOnly( false );
    } else {
      ui->saveButton->setText("Schliessen");
      ui->saveButton->setEnabled( true );
      ui->editor->setReadOnly( true );
    }
}

linboInfoBrowser::~linboInfoBrowser()
{
  delete ui;
} 

void linboInfoBrowser::on_saveButton_clicked()
{
    if(! ui->editor->isReadOnly() ){
        emit( writeInfo( filename, ui->editor->toPlainText() ));
    }
    this->accept();
}
