#include "linboYesNoImpl.hh"
#include <QtGui>
#include <q3progressbar.h>
#include <qapplication.h>

linboYesNoImpl::linboYesNoImpl(  QWidget* parent ) : linboDialog()
{
  Ui_linboYesNo::setupUi((QDialog*)this);

  process = new QProcess( this );

  progwindow = new linboProgressImpl(0);

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
  flags = Qt::Dialog | Qt::WindowStaysOnTopHint;
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

    Console->setColor( QColor( QString("red") ) );
    Console->append( QString("Executing ") + command + processargs.join(" ") );
    Console->setColor( QColor( QString("black") ) );


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

void linboYesNoImpl::setTextBrowser( Q3TextBrowser* newBrowser )
{
  Console = newBrowser;
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
  Console->append( process->readAllStandardOutput() );
}

void linboYesNoImpl::readFromStderr()
{
  Console->setColor( QColor( QString("red") ) );
  Console->append( process->readAllStandardError() );
  Console->setColor( QColor( QString("black") ) );
}

void linboYesNoImpl::processFinished( int retval,
				      QProcess::ExitStatus status) {
  Console->setColor( QColor( QString("red") ) );
  Console->append( QString("Command executed with exit value ") + QString::number( retval ) );

  if( status == 0)
    Console->append( QString("Exit status: ") + QString("The process exited normally.") );
  else
    Console->append( QString("Exit status: ") + QString("The process crashed.") );

  if( status == 1 ) {
    int errorstatus = process->error();
    switch ( errorstatus ) {
      case 0: Console->append( QString("The process failed to start. Either the invoked program is missing, or you may have insufficient permissions to invoke the program.") ); break;
      case 1: Console->append( QString("The process crashed some time after starting successfully.") ); break;
      case 2: Console->append( QString("The last waitFor...() function timed out.") ); break;
      case 3: Console->append( QString("An error occurred when attempting to write to the process. For example, the process may not be running, or it may have closed its input channel.") ); break;
      case 4: Console->append( QString("An error occurred when attempting to read from the process. For example, the process may not be running.") ); break;
      case 5: Console->append( QString("An unknown error occurred.") ); break;
    }

  }
  Console->setColor( QColor( QString("black") ) );
			   

  app->restoreButtonsState();

  if( progwindow ) {
    progwindow->close();
  }

}
