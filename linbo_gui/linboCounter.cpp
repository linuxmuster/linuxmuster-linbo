#include <qapplication.h>
#include <unistd.h>
#include <QtGui>
#include <QDesktopWidget>

#include "linboCounter.h"
#include "ui_linboCounter.h"

linboCounter::linboCounter(  QWidget* parent ) : linboDialog(), ui(new Ui::linboCounter)
{

  ui->setupUi(this);
    counter = ui->counter;
    logoutButton = ui->logoutButton;
    timeoutCheck = ui->timeoutCheck;

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

  connect( ui->logoutButton, SIGNAL(released()), this, SLOT(hide()) );
}


linboCounter::~linboCounter()
{
  // nothing to do
} 


void linboCounter::precmd() {
  // nothing to do
}

void linboCounter::postcmd() {
  // nothing to do
}


void linboCounter::readFromStdout()
{
  // nothing to do
}

void linboCounter::setMainApp( QWidget* newMainApp ) {
  if ( newMainApp ) {
    myMainApp = newMainApp;
  }
}

void linboCounter::readFromStderr()
{
  // nothing to do
}

QStringList linboCounter::getCommand() {
  return myCommand; 
}


void linboCounter::setCommand(const QStringList& arglist)
{
  // nothing to do
  myCommand = arglist;
}

void linboCounter::processFinished( int retval,
                                             QProcess::ExitStatus status) {
  // nothing to do
}

void linboCounter::closeEvent(QCloseEvent *event) {
	event->accept();
    ui->logoutButton->click();
}
