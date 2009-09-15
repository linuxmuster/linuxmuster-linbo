#include "linboCounterImpl.hh"
#include <qapplication.h>
#include <unistd.h>

linboCounterImpl::linboCounterImpl(  QWidget* parent ) : linboDialog()
{

  Ui_linboCounter::setupUi((QDialog*)this);

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
