#include <unistd.h>
#include <QtGui>
#include <QDesktopWidget>
#include <qprogressbar.h>
#include <qapplication.h>

#include "linboYesNo.h"
#include "ui_linboYesNo.h"

linboYesNo::linboYesNo(  QWidget* parent ) : linboDialog(), ui(new Ui::linboYesNo)
{
  ui->setupUi(this);

  process = new QProcess( this );

  progwindow = new linboProgress(0);

  logConsole = new linboLogConsole();

  if( parent )
    myParent = parent;

  connect(ui->YesButton,SIGNAL(clicked()),this,SLOT(postcmd()));
  connect(ui->NoButton,SIGNAL(clicked()),this,SLOT(close()));

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

linboYesNo::~linboYesNo()
{
} 

void linboYesNo::precmd() {
  // nothing to do
}
 
void linboYesNo::postcmd() {
  this->hide();    
  app = static_cast<LinboGUI*>( myMainApp );

  if( app ) {
    //FIXME: remove - progwindow->setProcess( process );

    progwindow->show();
    progwindow->raise();

    
    progwindow->activateWindow();
    progwindow->setUpdatesEnabled( true );
    progwindow->setEnabled( true );

    app->disableButtons();

    QStringList processargs( arguments );
    QString command = processargs.takeFirst();

    logConsole->writeStdErr( QString("Executing ") + command + processargs.join(" ") );

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
  myMainApp->setEnabled( true );
  this->close();
}

void linboYesNo::setTextBrowser( const QString& new_consolefontcolorstdout,
				     const QString& new_consolefontcolorstderr,
				     QTextEdit* newBrowser )
{
  logConsole->setLinboLogConsole( new_consolefontcolorstdout,
				  new_consolefontcolorstderr,
				  newBrowser );
}

void linboYesNo::setMainApp( QWidget* newMainApp ) {
  myMainApp = newMainApp;
}

void linboYesNo:: setCommand(const QStringList& arglist)
{
  arguments = arglist; // Create local copy
}

QStringList linboYesNo::getCommand() {
  return arguments;
}

void linboYesNo::readFromStdout()
{
  logConsole->writeStdOut( process->readAllStandardOutput() );
}

void linboYesNo::readFromStderr()
{
  logConsole->writeStdErr( process->readAllStandardError() );
}

void linboYesNo::processFinished( int retval,
				      QProcess::ExitStatus status) {

  logConsole->writeResult( retval, status, process->error() );

  app->restoreButtonsState();

  if( progwindow ) {
    progwindow->close();
  }

}

void linboYesNo::setQuestionText(QString question)
{
    ui->question->setText(question);
}
