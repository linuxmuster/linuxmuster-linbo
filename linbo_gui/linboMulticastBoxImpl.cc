#include "linboMulticastBoxImpl.hh"
#include "linboProgressImpl.hh"
#include "linboGUIImpl.hh"
#include <qprogressbar.h>
#include <qapplication.h>
#include <qradiobutton.h>
#include "linboPushButton.hh"
#include "linboYesNoImpl.hh"

linboMulticastBoxImpl::linboMulticastBoxImpl(  QWidget* parent,
                                       const char* name,
                                       bool modal,
                                       WFlags fl ) : linboMulticastBox( parent,
                                                                    name ), 
                                                     linboDialog()
{
  process = new QProcess( this );

  // nothing to do
  connect(okButton,SIGNAL(pressed()),this,SLOT(postcmd()));
  connect(cancelButton,SIGNAL(clicked()),this,SLOT(close()));

  // connect stdout and stderr to linbo console
  connect( process, SIGNAL(readyReadStdout()),
           this, SLOT(readFromStdout()) );
  connect( process, SIGNAL(readyReadStderr()),
           this, SLOT(readFromStderr()) );

}

linboMulticastBoxImpl::~linboMulticastBoxImpl()
{
} 

void linboMulticastBoxImpl::setTextBrowser( QTextBrowser* newBrowser )
{
  Console = newBrowser;
}

void linboMulticastBoxImpl::setMainApp( QWidget* newMainApp ) {
  myMainApp = newMainApp;
}


void linboMulticastBoxImpl::precmd() {
  // nothing to do
}


void linboMulticastBoxImpl::postcmd() {
  this->hide();
  
  linboGUIImpl* app = static_cast<linboGUIImpl*>( myMainApp );
  process->clearArguments();
  if ( this->rsyncButton->isChecked() )
    process->setArguments( myRsyncCommand );
  else
    process->setArguments( myMulticastCommand );
    

  if( app ) {
    // do something
    linboProgressImpl *progwindow = new linboProgressImpl(0,"Arbeite...",0, Qt::WStyle_Tool );
    connect( process, SIGNAL(processExited()), progwindow, SLOT(close()));

    progwindow->setTextBrowser( Console );
    progwindow->setProcess( process );
    progwindow->show();
    progwindow->raise();
    progwindow->progressBar->setTotalSteps( 100 );

    progwindow->setActiveWindow();
    progwindow->setUpdatesEnabled( true );
    progwindow->setEnabled( true );
      
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
  
  this->close();
}

void linboMulticastBoxImpl::setRsyncCommand(const QStringList& arglist)
{
  myRsyncCommand = QStringList(arglist); // Create local copy
}

void linboMulticastBoxImpl::setMulticastCommand(const QStringList& arglist)
{
  myMulticastCommand = QStringList(arglist); // Create local copy
}

void linboMulticastBoxImpl::setCommand(const QStringList& arglist)
{
  // no sense setting this here
}

QStringList linboMulticastBoxImpl::getCommand()
{
  // no sense setting this here
  return myCommand;
}


void linboMulticastBoxImpl::readFromStdout()
{
  while( process->canReadLineStdout() )
    {
      line = process->readLineStdout();
      Console->append( line );
    } 
}

void linboMulticastBoxImpl::readFromStderr()
{
  while( process->canReadLineStderr() )
    {
      line = process->readLineStderr();
      line.prepend( "<FONT COLOR=red>" );
      line.append( "</FONT>" );
      Console->append( line );
    } 
}
