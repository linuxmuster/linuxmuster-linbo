#include "linboImageUploadImpl.hh"
#include <unistd.h>
#include <q3progressbar.h>
#include <qapplication.h>
#include <q3listbox.h>
#include <QtGui>
#include "linboPushButton.hh"
#include "linboYesNoImpl.hh"

linboImageUploadImpl::linboImageUploadImpl(  QWidget* parent ) : linboDialog()
{
  Ui_linboImageUpload::setupUi((QDialog*)this);
  process = new QProcess( this );

  if( parent )
    myParent = parent;

  connect( cancelButton, SIGNAL(pressed()), this, SLOT(close()) );
  connect( okButton, SIGNAL(pressed()), this, SLOT(postcmd()) );

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

  progwindow = new linboProgressImpl(0);

  logConsole = new linboLogConsole(0);

  QRect qRect(QApplication::desktop()->screenGeometry());
  // open in the center of our screen
  int xpos=qRect.width()/2-this->width()/2;
  int ypos=qRect.height()/2-this->height()/2;
  this->move(xpos,ypos);
  this->setFixedSize( this->width(), this->height() );
}

linboImageUploadImpl::~linboImageUploadImpl()
{
} 

void linboImageUploadImpl::setTextBrowser( const QString& new_consolefontcolorstdout,
				      const QString& new_consolefontcolorstderr,
				      QTextEdit* newBrowser )
{
  logConsole->setLinboLogConsole( new_consolefontcolorstdout,
				  new_consolefontcolorstderr,
				  newBrowser );
}

void linboImageUploadImpl::setMainApp( QWidget* newMainApp ) {
  myMainApp = newMainApp;
}


void linboImageUploadImpl::precmd() {
  // nothing to do
}


void linboImageUploadImpl::postcmd() {
  
  app = static_cast<linboGUIImpl*>( myMainApp );
  
  this->hide();
  arguments[6] = listBox->currentText();

  
  if( app ) {
    // do something

    progwindow->setProcess( process );
    // connect( process, SIGNAL(processExited()), progwindow, SLOT(close()));
    progwindow->show();
    progwindow->raise();
    
    progwindow->setActiveWindow();
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
        progwindow->progressBar->setValue(i);
        progwindow->update();
        
        qApp->processEvents();
      } 
    }
  }

  if ( this->checkShutdown->isChecked() ) {
    system("busybox poweroff");
  } else if ( this->checkReboot->isChecked() ) {
    system("busybox reboot");
  }

  this->close(); 
}

void linboImageUploadImpl::setCommand(const QStringList& arglist)
{
  arguments = arglist; 
}

QStringList linboImageUploadImpl::getCommand()
{
  return arguments; 
}

void linboImageUploadImpl::readFromStdout()
{
  logConsole->writeStdOut( process->readAllStandardOutput() );
}

void linboImageUploadImpl::readFromStderr()
{
  logConsole->writeStdErr( process->readAllStandardError() );
}

void linboImageUploadImpl::processFinished( int retval,
                                             QProcess::ExitStatus status) {

  logConsole->writeResult( retval, status, process->error() );
			   
  app->restoreButtonsState();

  if( progwindow ) {
    progwindow->close();
  }


}
