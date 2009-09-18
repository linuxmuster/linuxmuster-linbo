#include "linboCounterImpl.hh"
#include <qapplication.h>
#include <unistd.h>
#include <QtGui>

linboCounterImpl::linboCounterImpl(  QWidget* parent ) : linboDialog()
{

  Ui_linboCounter::setupUi((QDialog*)this);

  Qt::WindowFlags flags;
  flags = Qt::Dialog | Qt::WindowStaysOnTopHint;
  setWindowFlags( flags );

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

void linboCounterImpl::readFromStderr()
{
  // nothing to do
}

QStringList linboCounterImpl::getCommand() {
  return QStringList(); 
}


void linboCounterImpl::setCommand(const QStringList& arglist)
{
  // nothing to do
}
