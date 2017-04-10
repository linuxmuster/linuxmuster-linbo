#include "linboMsgImpl.hh"
#include <qapplication.h>
#include <unistd.h>

linboMsgImpl::linboMsgImpl(  QWidget* parent ) : linboDialog()
{

  Ui_linboMsg::setupUi((QDialog*)this);

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

linboMsgImpl::~linboMsgImpl()
{

} 


void linboMsgImpl::precmd() {
  // nothing to do
}

void linboMsgImpl::postcmd() {
  // nothing to do
}

void linboMsgImpl::execute() {

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




void linboMsgImpl::setMainApp( QWidget* newMainApp ) {
  if ( newMainApp ) {
    myMainApp = newMainApp;
  }
}

QStringList linboMsgImpl::getCommand() {
  return arguments;
}


void linboMsgImpl::setCommand(const QStringList& arglist)
{
  arguments = arglist;
}

void linboMsgImpl::readFromStdout()
{
  message->setText( process->readAllStandardOutput() );
  this->update();
}

void linboMsgImpl::readFromStderr()
{
  // ignore this
  // message->setText( process->readAllStandardError() );
}

void linboMsgImpl::processFinished( int retval,
				    QProcess::ExitStatus status) {
  // let user read the process results
  this->close();
}
