#include "linboProgressImpl.hh"
#include <sys/types.h>
#include <signal.h>
#include <stdlib.h>
#include <QtGui>
#include <QRect>
#include <qapplication.h>
// #include <qtimer.h>

linboProgressImpl::linboProgressImpl(  QWidget* parent ) 
{
  Ui_linboProgress::setupUi((QDialog*)this);
  myTimer = new QTimer(this);
  
  connect( cancelButton,SIGNAL(clicked()),this,SLOT(killLinboCmd()) );
  connect( myTimer, SIGNAL(timeout()), this, SLOT(processTimer()) );

  logConsole = new linboLogConsole(0);

  if( parent )
    myParent = parent;

  Qt::WindowFlags flags;
  flags = Qt::Dialog | Qt::WindowStaysOnTopHint | Qt::WindowTitleHint;
  setWindowFlags( flags );

  QRect qRect(QApplication::desktop()->screenGeometry());
  int xpos=qRect.width()/2-this->width()/2;
  int ypos=qRect.height()/2-this->height()/2;
  this->move(xpos,ypos);
  this->setFixedSize( this->width(), this->height() );
  progressBar->setMinimum( 0 ); 
  progressBar->setMaximum( 100 );
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

  myProcess->terminate();
  myTimer->stop();
  QTimer::singleShot( 10000, myProcess, SLOT( close() ) );
}

void linboProgressImpl::setTextBrowser( const QString& new_consolefontcolorstdout,
					const QString& new_consolefontcolorstderr,
					QTextEdit* newBrowser )
{
  logConsole->setLinboLogConsole( new_consolefontcolorstdout,
				  new_consolefontcolorstderr,
				  newBrowser );
}

void linboProgressImpl::startTimer() {
  time = 0;
  myTimer->stop();
  myTimer->start( 1000, FALSE ); 
}


void linboProgressImpl::processTimer() {
  time++;
  
  minutes = (int)(time / 60);
  seconds = (int)(time % 60);

  if( minutes < 10 )
    minutestr = QString("0") + QString::number( minutes );
  else
    minutestr = QString::number( minutes );

  if( seconds < 10 )
    secondstr = QString("0") + QString::number( seconds );
  else
    secondstr = QString::number( seconds );
 
  
  processTime->setText( minutestr + QString(":") + secondstr );
}

void linboProgressImpl::processFinished( int retval,
					 QProcess::ExitStatus status) {
  myTimer->stop();
  this->close();
}
