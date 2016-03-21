#include <stdlib.h>
#include <unistd.h>
#include <qprogressbar.h>
#include <iostream>
#include <qapplication.h>
#include "linboPushButton.h"

linbopushbutton::linbopushbutton( QWidget* parent,
                                  const char* name ) : QPushButton( name, parent )
{
  connect(this, SIGNAL(clicked()), this, SLOT(lclicked()));

  // myprocess = new Q3Process( this )
  process = new QProcess( this );

  progwindow = new linboProgress(0);

  logConsole = new linboLogConsole(0);

  myQDialog = 0;
  myLinboDialog = 0;
  neighbour = 0;

  // connect SLOT for finished process
  connect( process, SIGNAL(finished(int, QProcess::ExitStatus) ),
           this, SLOT(processFinished(int, QProcess::ExitStatus)) );

  // connect stdout and stderr to linbo console
  connect( process, SIGNAL(readyReadStandardOutput()),
	   this, SLOT(readFromStdout()) );
  connect( process, SIGNAL(readyReadStandardError()),
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
  arguments.clear();
  //process->clearArguments();
  //process->setArguments( arglist );
  arguments = arglist;
}

void linbopushbutton::setTextBrowser( const QString& new_consolefontcolorstdout,
				      const QString& new_consolefontcolorstderr,
				      QTextEdit* newBrowser )
{
  logConsole->setLinboLogConsole( new_consolefontcolorstdout,
				  new_consolefontcolorstderr,
				  newBrowser );
}



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
  app = static_cast<LinboGUI*>( myMainApp );

  

  // disable cancel button for non-root users
  if ( !app->isRoot() ) 
    progwindow->setShowCancelButton(false);


  if ( myLinboDialog != 0 && 
       myQDialog != 0 ) 
    {
      // run preparations
      myLinboDialog->precmd();

      // show dialog
      //myMainApp->setEnabled( false );
      myQDialog->show();
      myQDialog->raise();
      //FIXME: myQDialog->setActiveWindow();
      myQDialog->setEnabled( true ); 

  }
  
  // do we need the progress bar?
  if ( progress ) {
    
    // connect( process, SIGNAL(processExited()), progwindow, SLOT(close()));
    progwindow->setProcess( process );
    progwindow->show();
    progwindow->raise();
    // progwindow->setTextBrowser( Console );
  
    //FIXME: progwindow->setActiveWindow();
    progwindow->setUpdatesEnabled( true );
    progwindow->setEnabled( true );
  }

  // wait for progress bar 
  usleep( 10000 );

  // start the command
  
  if( arguments.size() > 0 )
    {
      // disable buttons - only if a process runs
      app->disableButtons();

      //     Console->setColor( QColor( QString("red") ) );
      // Console->insert( QString("Executing ") + arguments.join(" ") );
      // Console->setColor( QColor( QString("black") ) );

      QStringList processargs( arguments );
      QString command = processargs.takeFirst();
      
      logConsole->writeStdErr( QString("Executing ") + command  + processargs.join(" ") );

      progwindow->startTimer();
      process->start( command, processargs );

      // important: give process time to start up
      process->waitForStarted();

      while (process->state() == QProcess::Running ) {
	for( int i = 0; i <= 100; i++ ) {
	  usleep(10000);
      progwindow->setProgress(i);
	  progwindow->update();
          
	  qApp->processEvents();
	}
      } 
  }
}

void linbopushbutton::setMainApp( QWidget* newMainApp ) {
  myMainApp = newMainApp;
}

QStringList linbopushbutton::getCommand() {
  return arguments;
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
  logConsole->writeStdOut( process->readAllStandardOutput() );
}

void linbopushbutton::readFromStderr()
{
  logConsole->writeStdErr( process->readAllStandardError() );
}

void linbopushbutton::processFinished( int retval,
				       QProcess::ExitStatus status) {

  logConsole->writeResult( retval, status, process->error() );

  app->restoreButtonsState();

  if( progwindow ) {
    progwindow->close();
  }
}
