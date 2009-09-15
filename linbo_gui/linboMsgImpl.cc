#include "linboMsgImpl.hh"
#include <qapplication.h>
#include <unistd.h>

linboMsgImpl::linboMsgImpl(  QWidget* parent,
                                             const char* name,
                                             bool modal,
                                             WFlags fl ) : linboMsg( parent,
                                                                     name,
                                                                     modal,
                                                                     fl ), 
                                                           linboDialog()
{
  myProcess = new QProcess();
  // connect stdout and stderr to linbo console
  connect( myProcess, SIGNAL(readyReadStdout()),
           this, SLOT(readFromStdout()) );
  connect( myProcess, SIGNAL(readyReadStderr()),
           this, SLOT(readFromStderr()) );
  //  connect( myProcess, SIGNAL(processExited()), this, SLOT(close()));
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
  myProcess->start();
  
  while( myProcess->isRunning() ) {
    usleep(10000);
    this->update();
    qApp->processEvents();
    };
}

void linboMsgImpl::readFromStdout()
{
  while( myProcess->canReadLineStdout() )
    {
      line = myProcess->readLineStdout();
      message->setText( line );
      qApp->processEvents();
      usleep(50000);
    } 
  this->close();
}

void linboMsgImpl::readFromStderr()
{
  while( myProcess->canReadLineStderr() )
    {
      line = myProcess->readLineStderr();
      line.prepend( "<FONT COLOR=red>" );
      line.append( "</FONT>" );
      message->setText( line );
      qApp->processEvents();
      usleep(50000);
    } 
}

QStringList linboMsgImpl::getCommand() {
  return myProcess->arguments();
}


void linboMsgImpl::setCommand(const QStringList& arglist)
{
  myProcess->setArguments(arglist);
}
