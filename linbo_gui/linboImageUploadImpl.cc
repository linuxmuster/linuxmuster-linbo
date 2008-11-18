#include "linboImageUploadImpl.hh"
#include "linboProgressImpl.hh"
#include "linboGUIImpl.hh"
#include <qprogressbar.h>
#include <qapplication.h>
#include <qlistbox.h>
#include "linboPushButton.hh"
#include "linboYesNoImpl.hh"

linboImageUploadImpl::linboImageUploadImpl(  QWidget* parent,
                                       const char* name,
                                       bool modal,
                                       WFlags fl ) : linboImageUpload( parent,
                                                                    name ), 
                                                     linboDialog()
{
  process = new QProcess( this );

  connect( cancelButton, SIGNAL(pressed()), this, SLOT(close()) );
  connect( okButton, SIGNAL(pressed()), this, SLOT(postcmd()) );

  // connect stdout and stderr to linbo console
  connect( process, SIGNAL(readyReadStdout()),
           this, SLOT(readFromStdout()) );
  connect( process, SIGNAL(readyReadStderr()),
           this, SLOT(readFromStderr()) );

}

linboImageUploadImpl::~linboImageUploadImpl()
{
} 

void linboImageUploadImpl::setTextBrowser( QTextBrowser* newBrowser )
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
  

  linboGUIImpl* app = static_cast<linboGUIImpl*>( myMainApp );
  
  this->hide();
  myCommand[6] = listBox->currentText();

  
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
  this->close(); 
}

void linboImageUploadImpl::setCommand(const QStringList& arglist)
{
  myCommand = QStringList(arglist); 
}

QStringList linboImageUploadImpl::getCommand()
{
  return QStringList(myCommand); 
}


void linboImageUploadImpl::readFromStdout()
{
  while( process->canReadLineStdout() )
    {
      line = process->readLineStdout();
      Console->append( line );
    } 
}

void linboImageUploadImpl::readFromStderr()
{
  while( process->canReadLineStderr() )
    {
      line = process->readLineStderr();
      line.prepend( "<FONT COLOR=red>" );
      line.append( "</FONT>" );
      Console->append( line );
    } 
}
