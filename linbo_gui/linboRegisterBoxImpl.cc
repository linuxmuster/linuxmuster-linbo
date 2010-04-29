#include "linboRegisterBoxImpl.hh"
#include <q3progressbar.h>
#include <qapplication.h>
#include <QtGui>
#include "linboPushButton.hh"
#include "linboYesNoImpl.hh"

linboRegisterBoxImpl::linboRegisterBoxImpl(  QWidget* parent ) : linboDialog()
{
  Ui_linboRegisterBox::setupUi((QDialog*)this);

  process = new QProcess( this );
  progwindow = new linboProgressImpl(0);

  if( parent )
    myParent = parent;

  connect(registerButton,SIGNAL(clicked()),this,SLOT(postcmd()));
  connect(cancelButton,SIGNAL(clicked()),this,SLOT(close()));

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

  QRect qRect(QApplication::desktop()->screenGeometry());
  // open in the center of our screen
  int xpos=qRect.width()/2-this->width()/2;
  int ypos=qRect.height()/2-this->height()/2;
  this->move(xpos,ypos);
  this->setFixedSize( this->width(), this->height() );
}

linboRegisterBoxImpl::~linboRegisterBoxImpl()
{
} 

void linboRegisterBoxImpl::setTextBrowser( QTextEdit* newBrowser )
{
  Console = newBrowser;
}

void linboRegisterBoxImpl::setMainApp( QWidget* newMainApp ) {
  myMainApp = newMainApp;
}


void linboRegisterBoxImpl::precmd() {
  // nothing to do
}


void linboRegisterBoxImpl::postcmd() {
  this->hide();
  // here, some further checks are needed
  if( !roomName->text().isEmpty() &&
      !ipAddress->text().isEmpty() &&
      !clientGroup->text().isEmpty() &&
      !clientName->text().isEmpty() ) {

    // update our command
    // room name
    myCommand[5] = roomName->text();
    // client name
    myCommand[6] = clientName->text();
    // IP
    myCommand[7] = ipAddress->text();
    // client group
    myCommand[8] = clientGroup->text();

    app = static_cast<linboGUIImpl*>( myMainApp );

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

      QStringList processargs( myCommand );
      QString command = processargs.takeFirst();

      process->start( command, processargs );

      process->waitForStarted();

      while( process->state() == QProcess::Running ) {
        for( int i = 0; i <= 100; i++ ) {
          usleep(10000);
          progwindow->progressBar->setValue(i);
          progwindow->update();
          
          qApp->processEvents();
        } 
        
      }
    }
    app->restoreButtonsState();
  }
  this->close();
}

void linboRegisterBoxImpl::setCommand(const QStringList& arglist)
{
  myCommand = QStringList(arglist); // Create local copy
}

QStringList linboRegisterBoxImpl::getCommand()
{
  return QStringList(myCommand); 
}

void linboRegisterBoxImpl::readFromStdout()
{
  Console->insert( process->readAllStandardOutput() );
}

void linboRegisterBoxImpl::readFromStderr()
{
  Console->setColor( QColor( QString("red") ) );
  Console->insert( process->readAllStandardError() );
  Console->setColor( QColor( QString("white") ) );
}

void linboRegisterBoxImpl::processFinished( int retval,
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
