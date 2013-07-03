#include "linboCounterImpl.hh"
#include <qapplication.h>
#include <unistd.h>
#include <QtGui>

linboCounterImpl::linboCounterImpl(  QWidget* parent ) : linboDialog()
{

  Ui_linboCounter::setupUi((QDialog*)this);

  Qt::WindowFlags flags;
  flags = Qt::Dialog | Qt::WindowStaysOnTopHint | Qt::WindowTitleHint;
  setWindowFlags( flags );

  if( parent )
    myParent = parent;

  QRect qRect(QApplication::desktop()->screenGeometry());
  // open in the upper left of our screen
  int xpos= 10; 
  int ypos= 10; 
  this->move(xpos,ypos);
  this->setFixedSize( this->width(), this->height() );

  connect( logoutButton, SIGNAL(released()), this, SLOT(hide()) );
}


linboCounterImpl::~linboCounterImpl()
{
  // nothing to do
} 


void linboCounterImpl::precmd() {
  // nothing to do
}

void linboCounterImpl::postcmd() {
  // nothing to do
}


void linboCounterImpl::readFromStdout()
{
  // nothing to do
}

void linboCounterImpl::setMainApp( QWidget* newMainApp ) {
  if ( newMainApp ) {
    myMainApp = newMainApp;
  }
}

void linboCounterImpl::readFromStderr()
{
  // nothing to do
}

QStringList linboCounterImpl::getCommand() {
  return myCommand; 
}


void linboCounterImpl::setCommand(const QStringList& arglist)
{
  // nothing to do
  myCommand = arglist;
}

void linboCounterImpl::processFinished( int retval,
                                             QProcess::ExitStatus status) {
  // nothing to do
}

void linboCounterImpl::closeEvent(QCloseEvent *event) {
	event->accept();
	logoutButton->click();
}
