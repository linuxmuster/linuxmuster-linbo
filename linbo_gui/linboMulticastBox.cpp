#include <unistd.h>
#include <qprogressbar.h>
#include <qapplication.h>
#include <qradiobutton.h>

#include <QtGui>
#include <iostream>

#include "linboMulticastBox.h"
#include "linboProgress.h"
#include "linboPushButton.h"
#include "ui_linboMulticastBox.h"

linboMulticastBox::linboMulticastBox(  QWidget* parent ) : linboDialog(), ui(new Ui::linboMulticastBox)
{
  ui->setupUi(this);
  
  process = new QProcess( this );

  if( parent )
    myParent = parent;

  // nothing to do
  connect(ui->okButton,SIGNAL(pressed()),this,SLOT(postcmd()));
  connect(ui->cancelButton,SIGNAL(clicked()),this,SLOT(close()));

  progwindow = new linboProgress(0);

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

linboMulticastBox::~linboMulticastBox()
{
} 

void linboMulticastBox::setTextBrowser( const QString& new_consolefontcolorstdout,
					    const QString& new_consolefontcolorstderr,
					    QTextEdit* newBrowser )
{
  logConsole->setLinboLogConsole( new_consolefontcolorstdout,
				  new_consolefontcolorstderr,
				  newBrowser );
}

void linboMulticastBox::setMainApp( QWidget* newMainApp ) {
  if ( newMainApp ) {
    myMainApp = newMainApp;
  }
}


void linboMulticastBox::precmd() {
  // nothing to do
}


void linboMulticastBox::postcmd() {
  this->hide();
  
  app = static_cast<LinboGUI*>( myMainApp );
  arguments.clear();
  
  if ( ui->rsyncButton->isChecked() )
    arguments =  myRsyncCommand;

  if ( ui->multicastButton->isChecked() )
    arguments =  myMulticastCommand;

  if ( ui->torrentButton->isChecked() )
    arguments = myBittorrentCommand;
  
  if ( ui->checkFormat->isChecked() ) {
    arguments[1] = QString("initcache_format");
  }


  if( app ) {
    // do something
    // connect( process, SIGNAL(processExited()), progwindow, SLOT(close()));

    progwindow->setProcess( process );
    progwindow->show();
    progwindow->raise();

    progwindow->activateWindow();
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
        progwindow->setProgress(i);
        progwindow->update();
          
        qApp->processEvents();
      } 
    }
  }
  this->close();
}

void linboMulticastBox::setRsyncCommand(const QStringList& arglist)
{
  myRsyncCommand = arglist; // Create local copy
}

void linboMulticastBox::setMulticastCommand(const QStringList& arglist)
{
  myMulticastCommand = arglist; // Create local copy
}

void linboMulticastBox::setBittorrentCommand(const QStringList& arglist)
{
  
  myBittorrentCommand = arglist; // Create local copy
}

void linboMulticastBox::setCommand(const QStringList& arglist)
{
  // no sense setting this here
  arguments = arglist;
}

QStringList linboMulticastBox::getCommand()
{
  return myCommand;
}


void linboMulticastBox::readFromStdout()
{
  logConsole->writeStdOut( process->readAllStandardOutput() );
}

void linboMulticastBox::readFromStderr()
{
  logConsole->writeStdErr( process->readAllStandardError() );
}

void linboMulticastBox::processFinished( int retval,
					     QProcess::ExitStatus status) {

  logConsole->writeResult( retval, status, process->error() );

  app->restoreButtonsState();

  if( progwindow ) {
    progwindow->close();
  }

}
