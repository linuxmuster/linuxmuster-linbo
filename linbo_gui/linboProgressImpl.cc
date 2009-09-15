#include "linboProgressImpl.hh"
#include <sys/types.h>
#include <signal.h>
#include <stdlib.h>
#include <QtGui>
#include <QRect>
#include <qapplication.h>
#include <qtimer.h>

linboProgressImpl::linboProgressImpl(  QWidget* parent ) 
{
  Ui_linboProgress::setupUi((QDialog*)this);
  connect( cancelButton,SIGNAL(clicked()),this,SLOT(killLinboCmd()) );

  Qt::WindowFlags flags;
  flags = Qt::FramelessWindowHint;
  //flags = Qt::CustomizeWindowHint;
  setWindowFlags( flags );

  QRect qRect(QApplication::desktop()->screenGeometry());
  int xpos=qRect.width()/2-this->width()/2;
  int ypos=qRect.height()/2-this->height()/2;
  this->move(xpos,ypos);
}

linboProgressImpl::~linboProgressImpl() {
  // nothing to do
}

void linboProgressImpl::setProcess( Q3Process* newProcess ) {
  if( newProcess != 0 ) {
    myProcess = newProcess;
  }
}

void linboProgressImpl::killLinboCmd() {

  myProcess->tryTerminate();
  QTimer::singleShot( 10000, myProcess, SLOT( close() ) );
}

void linboProgressImpl::setTextBrowser( Q3TextBrowser* newBrowser )
{
  Console = newBrowser;
}
