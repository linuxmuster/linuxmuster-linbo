#include <qapplication.h>
#include <unistd.h>

#include "linboMsg.h"
#include "ui_linboMsg.h"

linboMsg::linboMsg(  QWidget* parent ) : linboDialog(), ui(new Ui::linboMsg)
{

  ui->setupUi((QDialog*)this);

  process = new QProcess();
  if( parent )
    myParent = parent;

  // connect SLOT for finished process
  connect( process, SIGNAL(finished(int, QProcess::ExitStatus) ),
           this, SLOT(processFinished(int, QProcess::ExitStatus)) );

  // connect stdout and stderr to linbo console
  connect( process, SIGNAL(readyReadStandardOutput()),
           this, SLOT(readFromStdout()) );
  connect( process, SIGNAL(readyReadStandardError()),
           this, SLOT(readFromStderr()) );
}

linboMsg::~linboMsg()
{

} 


void linboMsg::precmd() {
  // nothing to do
}

void linboMsg::postcmd() {
  // nothing to do
}

void linboMsg::execute() {

  QStringList processargs( arguments );
  QString command = processargs.takeFirst();

  process->start( command, processargs );
  
  process->waitForStarted();

  // wait until the process is finished
  while(process->state() == QProcess::Running ) {
    this->update();
    qApp->processEvents();
  }
}




void linboMsg::setMainApp( QWidget* newMainApp ) {
  if ( newMainApp ) {
    myMainApp = newMainApp;
  }
}

QStringList linboMsg::getCommand() {
  return arguments;
}


void linboMsg::setCommand(const QStringList& arglist)
{
  arguments = arglist;
}

void linboMsg::readFromStdout()
{
  ui->message->setText( process->readAllStandardOutput() );
  this->update();
}

void linboMsg::readFromStderr()
{
  // ignore this
  // message->setText( process->readAllStandardError() );
}

void linboMsg::processFinished( int retval,
				    QProcess::ExitStatus status) {
  // let user read the process results
  this->close();
}
