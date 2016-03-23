#include <unistd.h>
#include <qprogressbar.h>
#include <qapplication.h>
#include <qlistwidget.h>
#include <QtGui>
#include <QDesktopWidget>

#include "linboImageUpload.h"
#include "ui_linboImageUpload.h"
#include "linboPushButton.h"
#include "linboYesNo.h"

linboImageUpload::linboImageUpload(  QWidget* parent ) : linboDialog(), ui(new Ui::linboImageUpload)
{
  ui->setupUi(this);
  process = new QProcess( this );

  if( parent )
    myParent = parent;

  connect( ui->cancelButton, SIGNAL(pressed()), this, SLOT(close()) );
  connect( ui->okButton, SIGNAL(pressed()), this, SLOT(postcmd()) );

  // connect SLOT for finished process
  connect( process, SIGNAL(finished(int, QProcess::ExitStatus) ),
           this, SLOT(processFinished(int, QProcess::ExitStatus)) );

  // connect stdout and stderr to linbo console
  connect( process, SIGNAL(readyReadStandardOutput()),
	   this, SLOT(readFromStdout()) );
  connect( process, SIGNAL(readyReadStandardError()),
	   this, SLOT(readFromStderr()) );


  Qt::WindowFlags flags;
  flags = Qt::Dialog | Qt::WindowStaysOnTopHint | Qt::WindowTitleHint;
  setWindowFlags( flags );

  progwindow = new linboProgress(0);

  logConsole = new linboLogConsole(0);

  QRect qRect(QApplication::desktop()->screenGeometry());
  // open in the center of our screen
  int xpos=qRect.width()/2-this->width()/2;
  int ypos=qRect.height()/2-this->height()/2;
  this->move(xpos,ypos);
  this->setFixedSize( this->width(), this->height() );
}

linboImageUpload::~linboImageUpload()
{
} 

void linboImageUpload::setTextBrowser( const QString& new_consolefontcolorstdout,
				      const QString& new_consolefontcolorstderr,
				      QTextEdit* newBrowser )
{
  logConsole->setLinboLogConsole( new_consolefontcolorstdout,
				  new_consolefontcolorstderr,
				  newBrowser );
}

void linboImageUpload::setMainApp( QWidget* newMainApp ) {
  myMainApp = newMainApp;
}


void linboImageUpload::precmd() {
  // nothing to do
}


void linboImageUpload::postcmd() {
  
  app = static_cast<LinboGUI*>( myMainApp );
  
  this->hide();
  arguments[6] = ui->listBox->currentItem()->text();

  
  if( app ) {
    // do something

    progwindow->setProcess( process );
    // connect( process, SIGNAL(processExited()), progwindow, SLOT(close()));
    progwindow->show();
    progwindow->raise();
    
    progwindow->activateWindow();
    progwindow->setUpdatesEnabled( true );
    progwindow->setEnabled( true );
       
    app->disableButtons();


    QStringList processargs( arguments );
    QString command = processargs.takeFirst();

    logConsole->writeStdErr( QString("Executing ") + command + processargs.join(" ") );

    progwindow->startTimer();
    process->start( command, processargs );

    while( process->state() == QProcess::Running ) {
      for( int i = 0; i <= 100; i++ ) {
        usleep(10000);
        progwindow->setProgress(i);
        progwindow->update();
        
        qApp->processEvents();
      } 
    }
  }

  if ( ui->checkShutdown->isChecked() ) {
    system("busybox poweroff");
  } else if ( ui->checkReboot->isChecked() ) {
    system("busybox reboot");
  }

  this->close(); 
}

void linboImageUpload::setCommand(const QStringList& arglist)
{
  arguments = arglist; 
}

QStringList linboImageUpload::getCommand()
{
  return arguments; 
}

void linboImageUpload::readFromStdout()
{
  logConsole->writeStdOut( process->readAllStandardOutput() );
}

void linboImageUpload::readFromStderr()
{
  logConsole->writeStdErr( process->readAllStandardError() );
}

void linboImageUpload::processFinished( int retval,
                                             QProcess::ExitStatus status) {

  logConsole->writeResult( retval, status, process->error() );
			   
  app->restoreButtonsState();

  if( progwindow ) {
    progwindow->close();
  }


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

void linboImageUpload::insertImageItem(QString imageName)
{
    ui->listBox->addItem(new QListWidgetItem(imageName));
}

void linboImageUpload::setCurrentImageItem(QListWidgetItem* imageItem)
{
    ui->listBox->setCurrentItem(imageItem, QItemSelectionModel::SelectCurrent);
}
