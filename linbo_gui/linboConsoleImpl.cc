#include "linboConsoleImpl.hh"
#include "linboProgressImpl.hh"
#include "linboGUIImpl.hh"
#include <q3progressbar.h>
#include <qapplication.h>
#include <QtGui>
#include "linboPushButton.hh"


linboConsoleImpl::linboConsoleImpl(  QWidget* parent ) : linboDialog()
{
  Ui_linboConsole::setupUi((QDialog*)this);
  process = new Q3Process( this );
  output->setMaxLogLines( 1000 );

  connect(input,SIGNAL(returnPressed()),this,SLOT(postcmd()));
  // connect stdout and stderr to linbo console
  connect( process, SIGNAL(readyReadStdout()),
           this, SLOT(readFromStdout()) );
  connect( process, SIGNAL(readyReadStderr()),
           this, SLOT(readFromStderr()) );

}

linboConsoleImpl::~linboConsoleImpl()
{
} 

void linboConsoleImpl::setTextBrowser( Q3TextBrowser* newBrowser )
{
  Console = newBrowser;
}

void linboConsoleImpl::setMainApp( QWidget* newMainApp ) {
  myMainApp = newMainApp;
}


void linboConsoleImpl::precmd() {
  // nothing to do
}


void linboConsoleImpl::postcmd() {
  // here, some further checks are needed
  if( !input->text().isEmpty() ) {
    myCommand.clear();
    myCommand = QStringList::split(" ", input->text());
    input->clear();
    myCommand.push_front(QString("busybox"));
 
    process->clearArguments();
    process->setArguments( myCommand );
    process->start();
    output->append("***");

  }
  
}

void linboConsoleImpl::setCommand(const QStringList& arglist)
{
  myCommand = QStringList(arglist); // Create local copy
}

QStringList linboConsoleImpl::getCommand()
{
  return QStringList(myCommand); 
}


void linboConsoleImpl::readFromStdout()
{
  while( process->canReadLineStdout() )
    {
      line = process->readLineStdout();
      output->append( line );
    } 
}

void linboConsoleImpl::readFromStderr()
{
  while( process->canReadLineStderr() )
    {
      line = process->readLineStderr();
      line.prepend( "<FONT COLOR=red>" );
      line.append( "</FONT>" );
      output->append( line );
    } 
}

