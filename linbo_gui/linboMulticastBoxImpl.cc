#include "linboMulticastBoxImpl.hh"
#include <unistd.h>
#include "linboProgressImpl.hh"
#include <q3progressbar.h>
#include <qapplication.h>
#include <qradiobutton.h>
#include "linboPushButton.hh"

#include <QtGui>
#include <iostream>

linboMulticastBoxImpl::linboMulticastBoxImpl(  QWidget* parent ) : linboDialog()
{
  Ui_linboMulticastBox::setupUi((QDialog*)this);  
  
  process = new QProcess( this );

  if( parent )
    myParent = parent;

  // nothing to do
  connect(okButton,SIGNAL(pressed()),this,SLOT(postcmd()));
  connect(cancelButton,SIGNAL(clicked()),this,SLOT(close()));

  progwindow = new linboProgressImpl(0);

  logConsole = new linboLogConsole(0);

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
  // open in the center of our screen
  int xpos=qRect.width()/2-this->width()/2;
  int ypos=qRect.height()/2-this->height()/2;
  this->move(xpos,ypos);
  this->setFixedSize( this->width(), this->height() );
}

linboMulticastBoxImpl::~linboMulticastBoxImpl()
{
} 

void linboMulticastBoxImpl::setTextBrowser( const QString& new_consolefontcolorstdout,
					    const QString& new_consolefontcolorstderr,
					    QTextEdit* newBrowser )
{
  logConsole->setLinboLogConsole( new_consolefontcolorstdout,
				  new_consolefontcolorstderr,
				  newBrowser );
}

void linboMulticastBoxImpl::setMainApp( QWidget* newMainApp ) {
  if ( newMainApp ) {
    myMainApp = newMainApp;
  }
}


void linboMulticastBoxImpl::precmd() {
  // nothing to do
}


void linboMulticastBoxImpl::postcmd() {
  this->hide();
  
  app = static_cast<linboGUIImpl*>( myMainApp );
  arguments.clear();
  
  if ( this->rsyncButton->isChecked() )
    arguments =  myRsyncCommand;

  if ( this->multicastButton->isChecked() )
    arguments =  myMulticastCommand;

  if ( this->torrentButton->isChecked() )
    arguments = myBittorrentCommand;
  
  if ( this->checkFormat->isChecked() ) {
    arguments[1] = QString("initcache_format");
  }


  if( app ) {
    // do something
    // connect( process, SIGNAL(processExited()), progwindow, SLOT(close()));

    progwindow->setProcess( process );
    progwindow->show();
    progwindow->raise();

    progwindow->setActiveWindow();
    progwindow->setUpdatesEnabled( true );
    progwindow->setEnabled( true );
      
    app->disableButtons();

    QStringList processargs( arguments );
    QString command = processargs.takeFirst();

    logConsole->writeStdErr( QString("Executing ") + command  + QString(" ") +  processargs.join(" ") );

    progwindow->startTimer();
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
  this->close();
}

void linboMulticastBoxImpl::setRsyncCommand(const QStringList& arglist)
{
  myRsyncCommand = arglist; // Create local copy
}

void linboMulticastBoxImpl::setMulticastCommand(const QStringList& arglist)
{
  myMulticastCommand = arglist; // Create local copy
}

void linboMulticastBoxImpl::setBittorrentCommand(const QStringList& arglist)
{
  
  myBittorrentCommand = arglist; // Create local copy
}

void linboMulticastBoxImpl::setCommand(const QStringList& arglist)
{
  // no sense setting this here
  arguments = arglist;
}

QStringList linboMulticastBoxImpl::getCommand()
{
  return myCommand;
}


void linboMulticastBoxImpl::readFromStdout()
{
  logConsole->writeStdOut( process->readAllStandardOutput() );
}

void linboMulticastBoxImpl::readFromStderr()
{
  logConsole->writeStdErr( process->readAllStandardError() );
}

void linboMulticastBoxImpl::processFinished( int retval,
					     QProcess::ExitStatus status) {

  logConsole->writeResult( retval, status, process->error() );

  app->restoreButtonsState();

  if( progwindow ) {
    progwindow->close();
  }

}
