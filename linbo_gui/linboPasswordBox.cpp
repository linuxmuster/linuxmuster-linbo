#include <qprocess.h>
#include <iostream>
#include <qmovie.h>
#include <qpoint.h>
#include <qlcdnumber.h>
#include <qapplication.h>
#include <QtGui>
#include <qcheckbox.h>

#include "linboPasswordBox.h"
#include "ui_linboPasswordBox.h"

linboPasswordBox::linboPasswordBox(  QDialog* parent ) : QWidget(parent), linboDialog(), ui(new Ui::linboPasswordBox)
{
  ui->setupUi((QDialog*)this);

  connect(ui->passwordInput,SIGNAL(returnPressed()),this,SLOT(postcmd()));

  process=new QProcess( this );
  if(parent)
    myParent = parent;

  myTimer = new QTimer(this);
  myCounter = new linboCounter(this);

  logConsole = new linboLogConsole(0);

  connect( myTimer, SIGNAL(timeout()), this, SLOT(processTimeout()) );

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

  QRect qRect(QApplication::desktop()->screenGeometry());
  // open in the upper left of our screen
  int xpos=10;
  int ypos=10;
  this->move(xpos,ypos);
  this->setFixedSize( this->width(), this->height() );
}

linboPasswordBox::~linboPasswordBox()
{
  delete myTimer;
  delete process;
  delete myCounter;
} 

void linboPasswordBox::precmd() {
  // nothing to do
}

void linboPasswordBox::postcmd() {

  this->hide();
  app = static_cast<LinboGUI*>( myMainApp );

  if( app ) {
    // build authentication command
    arguments.clear();
    arguments.append("linbo_cmd");
    arguments.append( "authenticate" );
    arguments.append( app->config().get_server() );
    arguments.append( "linbo" );
    arguments.append( ui->passwordInput->text() );
    arguments.append( "linbo" );

    QStringList processargs( arguments );
    QString command = processargs.takeFirst();

    process->start( command, processargs );

    while( !process->waitForFinished(10000) ) {
    };
      
    // Console->insert( QString("Test linboPasswordBox exitCode() == ") + QString::number( process->exitCode() ) );

    if ( process->exitCode() == 0 ) {
      if( app ) {

	// set password in all buttons
	QStringList tmp;

	for( unsigned int i = 0; i < app->p_buttons.size(); i++ )
	  {
        /* FIXME
        linboDialog* tmpDialog = app->p_buttons[i]->getLinboDialog();
	    if( tmpDialog  ) {
	      // in this case, we have a sub-dialogue
	      tmp = tmpDialog->getCommand();
	      
	      // fear the segmentation fault!
	      // fifth argument is password
	      if( tmp.size() > 4 ) {

		if( tmp[1] == QString("upload") ||
		    tmp[1] == QString("register") ) {
		  
		  // change upload password
          tmp[4] = ui->passwordInput->text();
		  tmpDialog->setCommand( tmp );
		}         
	      }
	    }         
	    
	    // this is for the case we have no associated linbo dialog
	    if( app->p_buttons[i] ) {
	      tmp.clear();
          //FIXME: tmp = app->p_buttons[i]->getCommand();
	      
	      // fifth argument is password
	      if( tmp.size() > 4 ) {
		
		if( tmp[1] == QString("upload") ||
		    tmp[1] == QString("register") ) {
		  // change upload password
          tmp[4] = ui->passwordInput->text();
          //FIXME: app->p_buttons[i]->setCommand( tmp );
		}
	      }
        }  */
	  }
	
	app->enableButtons();
	app->showImagingTab();
        
	myTimer->stop();
    myTimer->start( 1000 );
    currentTimeout = app->config().get_roottimeout();
	
	myCounter->counter->display( currentTimeout );
	
	connect( myCounter->logoutButton, SIGNAL(pressed()), app, SLOT(resetButtons()) );
	connect( myCounter->logoutButton, SIGNAL(clicked()), myTimer, SLOT(stop()) );
        
	myCounter->show();
	myCounter->raise();
	myCounter->move( QPoint( 5, 5 ) ); 
      }
    }
  }
  
  ui->passwordInput->clear();
  this->close();
}

void linboPasswordBox::setCommand(const QStringList& arglist)
{
  arguments = arglist;
}

QStringList linboPasswordBox::getCommand()
{
  return arguments; 
}

void linboPasswordBox::setMainApp( QWidget* newMainApp ) {
  if ( newMainApp ) {
    myMainApp = newMainApp;
  }
}

void linboPasswordBox::readFromStdout()
{
  logConsole->writeStdOut( process->readAllStandardOutput() );
}

void linboPasswordBox::readFromStderr()
{
  logConsole->writeStdErr( process->readAllStandardError() );
}

void linboPasswordBox::setTextBrowser( const QString& new_consolefontcolorstdout,
					   const QString& new_consolefontcolorstderr,
					   QTextEdit* newBrowser )
{
  logConsole->setLinboLogConsole( new_consolefontcolorstdout,
				  new_consolefontcolorstderr,
				  newBrowser );
}

void linboPasswordBox::processTimeout() {
  if( !myCounter->timeoutCheck->isChecked() ) {
    // do nothing but dont stop timer
  } 
  else {
    if( currentTimeout > 0 ) {
      currentTimeout--;
      myCounter->counter->display( currentTimeout );
    }
    else {
      app->resetButtons();
      myCounter->close();
    }
  }
}

void linboPasswordBox::processFinished( int retval,
					     QProcess::ExitStatus status) {

  logConsole->writeResult( retval, status, process->error() );

  // app->restoreButtonsState();
}
