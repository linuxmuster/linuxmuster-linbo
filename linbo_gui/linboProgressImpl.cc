#include "linboProgressImpl.hh"
#include <sys/types.h>
#include <signal.h>
#include <stdlib.h>
#include <qapplication.h>
#include <qtimer.h>

linboProgressImpl::linboProgressImpl(  QWidget* parent,
                                       const char* name,
                                       bool modal,
                                       WFlags fl ) : linboProgress( parent,
                                                                    name ) 
{
  connect( cancelButton,SIGNAL(clicked()),this,SLOT(killLinboCmd()) );
}

linboProgressImpl::~linboProgressImpl() {
  // nothing to do
}

void linboProgressImpl::setProcess( QProcess* newProcess ) {
  if( newProcess != 0 ) {
    myProcess = newProcess;
  }
}

void linboProgressImpl::killLinboCmd() {

  myProcess->tryTerminate();
  QTimer::singleShot( 10000, myProcess, SLOT( close() ) );
}

void linboProgressImpl::setTextBrowser( QTextBrowser* newBrowser )
{
  Console = newBrowser;
}
