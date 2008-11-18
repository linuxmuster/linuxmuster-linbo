#include <stdlib.h>
#include <unistd.h>
#include <qprogressbar.h>
#include <iostream>
#include <qapplication.h>
#include "linboPushButton.hh"

linbopushbutton::linbopushbutton( QWidget* parent,
                                  const char* name,
                                  bool modal,
                                  WFlags fl) : QPushButton( parent,
                                                                 name )
                                /*,
                                                                modal,
                                                                0 ) */
{
  connect(this, SIGNAL(clicked()), this, SLOT(lclicked()));

  myprocess = new QProcess( this );

  myQDialog = 0;
  myLinboDialog = 0;
  neighbour = 0;
  // connect stdout and stderr to linbo console
  connect( myprocess, SIGNAL(readyReadStdout()),
           this, SLOT(readFromStdout()) );
  connect( myprocess, SIGNAL(readyReadStderr()),
           this, SLOT(readFromStderr()) );

  timer = new QTimer( this );
  progress = true;
}

linbopushbutton::~linbopushbutton() 
{
  // nothing to do
}

void linbopushbutton::setProgress( const bool& newProgress )
{
  progress = newProgress;
}

void linbopushbutton::setCommand(const QStringList& arglist )
{
  myprocess->clearArguments();
  myprocess->setArguments( arglist );
}

void linbopushbutton::setTextBrowser( QTextBrowser* newBrowser )
{
  Console = newBrowser;
}

// void linbopushbutton::setDialog( QDialog* newDialog )
void linbopushbutton::setLinboDialog( linboDialog* newDialog )
{
  myLinboDialog = newDialog;
}

void linbopushbutton::setQDialog( QDialog* newDialog )
{
  myQDialog = newDialog;
}


void linbopushbutton::lclicked() 
{
  app = static_cast<linboGUIImpl*>( myMainApp );

  // disable main window
  linboProgressImpl *progwindow = new linboProgressImpl(0,"Arbeite...",0, Qt::WStyle_Tool );

  // disable cancel button for non-root users
  if ( !app->isRoot() ) 
    progwindow->cancelButton->hide();


  if ( myLinboDialog != 0 && 
       myQDialog != 0 ) 
    {
      // run preparations
      myLinboDialog->precmd();

      // show dialog
      // myMainApp->setEnabled( false );
      myQDialog->show();
      myQDialog->raise();
      myQDialog->setActiveWindow();
      myQDialog->setEnabled( true ); 

  }

  // do we need the progress bar?
  if ( progress ) {
    
    connect( myprocess, SIGNAL(processExited()), progwindow, SLOT(close()));
    progwindow->setProcess( myprocess );
    progwindow->show();
    progwindow->raise();
    progwindow->progressBar->setTotalSteps( 100 );
    progwindow->setTextBrowser( Console );
  
    progwindow->setActiveWindow();
    progwindow->setUpdatesEnabled( true );
    progwindow->setEnabled( true );
  }
  // disable buttons

  app->disableButtons();

  // wait for progress bar 
  usleep( 10000 );

  // start the command
  myprocess->start();

  if ( progress ) {
    while( myprocess->isRunning() ) {
      for( int i = 0; i <= 100; i++ ) {
        usleep(10000);
        progwindow->progressBar->setProgress(i,100);
        progwindow->update();
        
        qApp->processEvents();
      }
    }
    if( ! myprocess->isRunning() ) {
      progwindow->close();
    }
  }
  app->restoreButtonsState();

/*  if ( myLinboDialog != 0 ) {
    // run post commands
    while( myprocess->isRunning() ) {};
    
    int result = myprocess->exitStatus();
    myLinboDialog->postcmd( result );
    } 
*/

  // reenable main window
  // myMainApp->setEnabled( true );
  
}

void linbopushbutton::setMainApp( QWidget* newMainApp ) {
  myMainApp = newMainApp;
}

QStringList linbopushbutton::getCommand() {
  return myprocess->arguments();
}

QDialog* linbopushbutton::getQDialog()
{
  return myQDialog;
}

linboDialog* linbopushbutton::getLinboDialog() {
  return myLinboDialog;
}

void linbopushbutton::setNeighbour( linbopushbutton* newNeighbour ) {
  if( newNeighbour )
    neighbour = newNeighbour;
}

linbopushbutton* linbopushbutton::getNeighbour() {
  return neighbour;
}

void linbopushbutton::readFromStdout()
{
  while( myprocess->canReadLineStdout() )
    {
      line = myprocess->readLineStdout();
      if( app )
        app->log( line );
 
      Console->append( line );
    } 
}

void linbopushbutton::readFromStderr()
{
  while( myprocess->canReadLineStderr() )
    {
      line = myprocess->readLineStderr();
      if( app )
        app->log( line );

      line.prepend( "<FONT COLOR=red>" );
      line.append( "</FONT>" );
      Console->append( line );
    } 
}
