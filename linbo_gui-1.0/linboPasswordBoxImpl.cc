#include "linboPasswordBoxImpl.hh"
#include <q3process.h>
#include <iostream>
#include <qmovie.h>
#include <qpoint.h>
#include <qlcdnumber.h>
#include <qapplication.h>
#include <QtGui>
#include <qcheckbox.h>

linboPasswordBoxImpl::linboPasswordBoxImpl(  QDialog* parent ) : linboDialog()
{
  Ui_linboPasswordBox::setupUi((QDialog*)this);

  connect(passwordInput,SIGNAL(returnPressed()),this,SLOT(postcmd()));

  process=new QProcess( this );
  if(parent)
    myParent = parent;

  myTimer = new QTimer(this);
  myCounter = new linboCounterImpl(this);

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

linboPasswordBoxImpl::~linboPasswordBoxImpl()
{
  delete myTimer;
  delete process;
  delete myCounter;
} 

void linboPasswordBoxImpl::precmd() {
  // nothing to do
}

void linboPasswordBoxImpl::postcmd() {

  this->hide();
  app = static_cast<linboGUIImpl*>( myMainApp );

  if( app ) {
    // build authentication command
    arguments.clear();
    arguments.append("linbo_cmd");
    arguments.append( "authenticate" );
    arguments.append( app->config.get_server() );
    arguments.append( "linbo" );
    arguments.append( passwordInput->text() );
    arguments.append( "linbo" );

    QStringList processargs( arguments );
    QString command = processargs.takeFirst();

    process->start( command, processargs );

    while( !process->waitForFinished(10000) ) {
    };
      
    // Console->insert( QString("Test linboPasswordBoxImpl exitCode() == ") + QString::number( process->exitCode() ) );

    if ( process->exitCode() == 0 ) {
      if( app ) {

	// set password in all buttons
	QStringList tmp;

	for( unsigned int i = 0; i < app->p_buttons.size(); i++ )
	  {
	    
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
		  tmp[4] = passwordInput->text();
		  tmpDialog->setCommand( tmp );
		}         
	      }
	    }         
	    
	    // this is for the case we have no associated linbo dialog
	    if( app->p_buttons[i] ) {
	      tmp.clear();
	      tmp = app->p_buttons[i]->getCommand();
	      
	      // fifth argument is password
	      if( tmp.size() > 4 ) {
		
		if( tmp[1] == QString("upload") ||
		    tmp[1] == QString("register") ) {
		  // change upload password
		  tmp[4] = passwordInput->text();
		  app->p_buttons[i]->setCommand( tmp );
		}
	      }
	    }  
	  }
	
	app->enableButtons();
	app->showImagingTab();
        
	myTimer->stop();
	myTimer->start( 1000, FALSE ); 
	currentTimeout = app->config.get_roottimeout();
	
	myCounter->counter->display( currentTimeout );
	
	connect( myCounter->logoutButton, SIGNAL(pressed()), app, SLOT(resetButtons()) );
	connect( myCounter->logoutButton, SIGNAL(clicked()), myTimer, SLOT(stop()) );
        
	myCounter->show();
	myCounter->raise();
	myCounter->move( QPoint( 5, 5 ) ); 
      }
    }
  }
  
  passwordInput->clear();
  this->close();
}

void linboPasswordBoxImpl::setCommand(const QStringList& arglist)
{
  arguments = arglist;
}

QStringList linboPasswordBoxImpl::getCommand()
{
  return arguments; 
}

void linboPasswordBoxImpl::setMainApp( QWidget* newMainApp ) {
  if ( newMainApp ) {
    myMainApp = newMainApp;
  }
}

void linboPasswordBoxImpl::readFromStdout()
{
  logConsole->writeStdOut( process->readAllStandardOutput() );
}

void linboPasswordBoxImpl::readFromStderr()
{
  logConsole->writeStdErr( process->readAllStandardError() );
}

void linboPasswordBoxImpl::setTextBrowser( const QString& new_consolefontcolorstdout,
					   const QString& new_consolefontcolorstderr,
					   QTextEdit* newBrowser )
{
  logConsole->setLinboLogConsole( new_consolefontcolorstdout,
				  new_consolefontcolorstderr,
				  newBrowser );
}

void linboPasswordBoxImpl::processTimeout() {
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

void linboPasswordBoxImpl::processFinished( int retval,
					     QProcess::ExitStatus status) {

  logConsole->writeResult( retval, status, process->error() );

  // app->restoreButtonsState();
}
