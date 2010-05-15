#include <stdlib.h>
#include <unistd.h>
#include <q3progressbar.h>
#include <iostream>
#include <qapplication.h>
#include "linboPushButton.hh"

linbopushbutton::linbopushbutton( QWidget* parent,
                                  const char* name ) : QPushButton( parent,
                                                                    name )                     
{
  connect(this, SIGNAL(clicked()), this, SLOT(lclicked()));

  // myprocess = new Q3Process( this );;
  process = new QProcess( this );;

  progwindow = new linboProgressImpl(0);

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

void linbopushbutton::setTextBrowser( QTextEdit* newBrowser )
{
  Console = newBrowser;
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
  app = static_cast<linboGUIImpl*>( myMainApp );

  

  // disable cancel button for non-root users
  if ( !app->isRoot() ) 
    progwindow->cancelButton->hide();


  if ( myLinboDialog != 0 && 
       myQDialog != 0 ) 
    {
      // run preparations
      myLinboDialog->precmd();

      // show dialog
      //myMainApp->setEnabled( false );
      myQDialog->show();
      myQDialog->raise();
      myQDialog->setActiveWindow();
      myQDialog->setEnabled( true ); 

  }
  
  // do we need the progress bar?
  if ( progress ) {
    
    // connect( process, SIGNAL(processExited()), progwindow, SLOT(close()));
    progwindow->setProcess( process );
    progwindow->show();
    progwindow->raise();
    progwindow->setTextBrowser( Console );
  
    progwindow->setActiveWindow();
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

      Console->setColor( QColor( QString("red") ) );
      Console->insert( QString("Executing ") + command  + processargs.join(" ") );
      Console->insert(QString(QChar::LineSeparator));
      Console->setColor( QColor( QString("white") ) );
      Console->moveCursor(QTextCursor::End);
      Console->ensureCursorVisible(); 


      progwindow->startTimer();
      process->start( command, processargs );

      // important: give process time to start up
      process->waitForStarted();

      while (process->state() == QProcess::Running ) {
	for( int i = 0; i <= 100; i++ ) {
	  usleep(10000);
	  progwindow->progressBar->setValue(i);
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
  Console->setColor( QColor( QString("white") ) );
  Console->insert( process->readAllStandardOutput() );
  Console->moveCursor(QTextCursor::End);
  Console->ensureCursorVisible(); 

}

void linbopushbutton::readFromStderr()
{
  Console->setColor( QColor( QString("red") ) );
  Console->insert( process->readAllStandardError() );
  Console->setColor( QColor( QString("white") ) );
  Console->moveCursor(QTextCursor::End);
  Console->ensureCursorVisible(); 

}

void linbopushbutton::processFinished( int retval,
				       QProcess::ExitStatus status) {

  Console->setColor( QColor( QString("red") ) );
  Console->insert( QString("Command executed with exit value ") + QString::number( retval ) );

  if( status == 0)
    Console->insert( QString("Exit status: ") + QString("The process exited normally.") );
  else
    Console->insert( QString("Exit status: ") + QString("The process crashed.") );

  if( status == 1 ) {
    int errorstatus = process->error();
    switch ( errorstatus ) {
      case 0: Console->insert( QString("The process failed to start. Either the invoked program is missing, or you may have insufficient permissions to invoke the program.") ); break;
      case 1: Console->insert( QString("The process crashed some time after starting successfully.") ); break;
      case 2: Console->insert( QString("The last waitFor...() function timed out.") ); break;
      case 3: Console->insert( QString("An error occurred when attempting to write to the process. For example, the process may not be running, or it may have closed its input channel.") ); break;
      case 4: Console->insert( QString("An error occurred when attempting to read from the process. For example, the process may not be running.") ); break;
      case 5: Console->insert( QString("An unknown error occurred.") ); break;
    }

  }
  Console->insert(QString(QChar::LineSeparator));  

  Console->setColor( QColor( QString("white") ) );
  Console->moveCursor(QTextCursor::End);
  Console->ensureCursorVisible(); 

  app->restoreButtonsState();

  if( progwindow ) {
    progwindow->close();
  }
}
