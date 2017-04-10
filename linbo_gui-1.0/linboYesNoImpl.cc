#include "linboYesNoImpl.hh"
#include <unistd.h>
#include <QtGui>
#include <q3progressbar.h>
#include <qapplication.h>

linboYesNoImpl::linboYesNoImpl(  QWidget* parent ) : linboDialog()
{
  Ui_linboYesNo::setupUi((QDialog*)this);

  process = new QProcess( this );

  progwindow = new linboProgressImpl(0);

  logConsole = new linboLogConsole(0);

  if( parent )
    myParent = parent;

  connect(YesButton,SIGNAL(clicked()),this,SLOT(postcmd()));
  connect(NoButton,SIGNAL(clicked()),this,SLOT(close())); 

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

linboYesNoImpl::~linboYesNoImpl()
{
} 

void linboYesNoImpl::precmd() {
  // nothing to do
}
 
void linboYesNoImpl::postcmd() {
  this->hide();    
  app = static_cast<linboGUIImpl*>( myMainApp );

  if( app ) {
    progwindow->setProcess( process );

    progwindow->show();
    progwindow->raise();

    
    progwindow->setActiveWindow();
    progwindow->setUpdatesEnabled( TRUE );
    progwindow->setEnabled( true );

    // myMainApp->setEnabled( false );
    app->disableButtons();

    QStringList processargs( arguments );
    QString command = processargs.takeFirst();

    logConsole->writeStdErr( QString("Executing ") + command + processargs.join(" ") );

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
  myMainApp->setEnabled( true );
  this->close();
}

void linboYesNoImpl::setTextBrowser( const QString& new_consolefontcolorstdout,
				     const QString& new_consolefontcolorstderr,
				     QTextEdit* newBrowser )
{
  logConsole->setLinboLogConsole( new_consolefontcolorstdout,
				  new_consolefontcolorstderr,
				  newBrowser );
}

void linboYesNoImpl::setMainApp( QWidget* newMainApp ) {
  myMainApp = newMainApp;
}

void linboYesNoImpl:: setCommand(const QStringList& arglist)
{
  arguments = arglist; // Create local copy
}

QStringList linboYesNoImpl::getCommand() {
  return arguments;
}

void linboYesNoImpl::readFromStdout()
{
  logConsole->writeStdOut( process->readAllStandardOutput() );
}

void linboYesNoImpl::readFromStderr()
{
  logConsole->writeStdErr( process->readAllStandardError() );
}

void linboYesNoImpl::processFinished( int retval,
				      QProcess::ExitStatus status) {

  logConsole->writeResult( retval, status, process->error() );

  app->restoreButtonsState();

  if( progwindow ) {
    progwindow->close();
  }

}
