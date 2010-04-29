#include "linboImageUploadImpl.hh"
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
  flags = Qt::Dialog | Qt::WindowStaysOnTopHint;
  setWindowFlags( flags );

  progwindow = new linboProgressImpl(0);

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

void linboImageUploadImpl::setTextBrowser( QTextEdit* newBrowser )
{
  Console = newBrowser;
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

    Console->setColor( QColor( QString("red") ) );
    Console->append( QString("Executing ") + command + processargs.join(" ") );
    Console->setColor( QColor( QString("white") ) );

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
    Console->append( QString("Test ImageUploadImpl exitCode() == ") + QString::number( process->exitCode() ) );
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
  Console->insert( process->readAllStandardOutput() );
}

void linboImageUploadImpl::readFromStderr()
{
  Console->setColor( QColor( QString("red") ) );
  Console->insert( process->readAllStandardError() );
  Console->setColor( QColor( QString("white") ) );
}

void linboImageUploadImpl::processFinished( int retval,
                                             QProcess::ExitStatus status) {
  Console->setColor( QColor( QString("red") ) );
  Console->append( QString("Command executed with exit value ") + QString::number( retval ) );

  if( status == 0)
    Console->append( QString("Exit status: ") + QString("The process exited normally.") );
  else
    Console->append( QString("Exit status: ") + QString("The process crashed.") );

  if( status == 1 ) {
    int errorstatus = process->error();
    switch ( errorstatus ) {
      case 0: Console->append( QString("The process failed to start. Either the invoked program is missing, or you may have insufficient permissions to invoke the program.") ); break;
      case 1: Console->append( QString("The process crashed some time after starting successfully.") ); break;
      case 2: Console->append( QString("The last waitFor...() function timed out.") ); break;
      case 3: Console->append( QString("An error occurred when attempting to write to the process. For example, the process may not be running, or it may have closed its input channel.") ); break;
      case 4: Console->append( QString("An error occurred when attempting to read from the process. For example, the process may not be running.") ); break;
      case 5: Console->append( QString("An unknown error occurred.") ); break;
    }

  }
  Console->setColor( QColor( QString("white") ) );
			   

   app->restoreButtonsState();

  if( progwindow ) {
    progwindow->close();
  }


}
