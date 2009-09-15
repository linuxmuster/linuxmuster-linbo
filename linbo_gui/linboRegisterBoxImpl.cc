#include "linboRegisterBoxImpl.hh"
#include "linboProgressImpl.hh"
#include "linboGUIImpl.hh"
#include <qprogressbar.h>
#include <qapplication.h>
#include "linboPushButton.hh"
#include "linboYesNoImpl.hh"

linboRegisterBoxImpl::linboRegisterBoxImpl(  QWidget* parent,
                                       const char* name,
                                       bool modal,
                                       WFlags fl ) : linboRegisterBox( parent,
                                                                    name ), 
                                                     linboDialog()
{
  process = new QProcess( this );

  connect(registerButton,SIGNAL(clicked()),this,SLOT(postcmd()));
  connect(cancelButton,SIGNAL(clicked()),this,SLOT(close()));

  // connect stdout and stderr to linbo console
  connect( process, SIGNAL(readyReadStdout()),
           this, SLOT(readFromStdout()) );
  connect( process, SIGNAL(readyReadStderr()),
           this, SLOT(readFromStderr()) );

}

linboRegisterBoxImpl::~linboRegisterBoxImpl()
{
} 

void linboRegisterBoxImpl::setTextBrowser( QTextBrowser* newBrowser )
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

    linboGUIImpl* app = static_cast<linboGUIImpl*>( myMainApp );

    if( app ) {
      // do something
      linboProgressImpl *progwindow = new linboProgressImpl(0,"Arbeite...",0, Qt::WStyle_Tool );
      progwindow->setProcess( process );
      connect( process, SIGNAL(processExited()), progwindow, SLOT(close()));
      progwindow->show();
      progwindow->raise();
      progwindow->progressBar->setTotalSteps( 100 );

      progwindow->setActiveWindow();
      progwindow->setUpdatesEnabled( true );
      progwindow->setEnabled( true );
      
      process->clearArguments();
      process->setArguments( myCommand );

      app->disableButtons();

      process->start();

      while( process->isRunning() ) {
        for( int i = 0; i <= 100; i++ ) {
          usleep(10000);
          progwindow->progressBar->setProgress(i,100);
          progwindow->update();
          
          qApp->processEvents();
        } 
        
        if( ! process->isRunning() ) {
          progwindow->close();
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
  while( process->canReadLineStdout() )
    {
      line = process->readLineStdout();
      Console->append( line );
    } 
}

void linboRegisterBoxImpl::readFromStderr()
{
  while( process->canReadLineStderr() )
    {
      line = process->readLineStderr();
      line.prepend( "<FONT COLOR=red>" );
      line.append( "</FONT>" );
      Console->append( line );
    } 
}
