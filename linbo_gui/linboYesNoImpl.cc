#include "linboYesNoImpl.hh"
#include "linboProgressImpl.hh"
#include <QtGui>
#include <q3progressbar.h>
#include <qapplication.h>

linboYesNoImpl::linboYesNoImpl(  QWidget* parent ) : linboDialog()
{
  Ui_linboYesNo::setupUi((QDialog*)this);

  process = new Q3Process( this );
  connect(YesButton,SIGNAL(clicked()),this,SLOT(postcmd()));
  connect(NoButton,SIGNAL(clicked()),this,SLOT(close())); 

  // connect stdout and stderr to linbo console
  connect( process, SIGNAL(readyReadStdout()),
           this, SLOT(readFromStdout()) );
  connect( process, SIGNAL(readyReadStderr()),
           this, SLOT(readFromStderr()) );

  Qt::WindowFlags flags;
  flags = Qt::Dialog | Qt::WindowStaysOnTopHint;
  setWindowFlags( flags );

  QRect qRect(QApplication::desktop()->screenGeometry());
  // open in the center of our screen
  int xpos=qRect.width()/2-this->width()/2;
  int ypos=qRect.height()/2-this->height()/2;
  this->move(xpos,ypos);
  this->setFixedSize( this->width(), this->height() );
}

linboYesNoImpl::~linboYesNoImpl()
{
} 

void linboYesNoImpl::precmd() {
  // nothing to do
}
 
void linboYesNoImpl::postcmd() {
  this->hide();    
  linboGUIImpl* app = static_cast<linboGUIImpl*>( myMainApp );

  if( app ) {
    linboProgressImpl *progwindow = new linboProgressImpl(0); //,"Arbeite...",0, Qt::WStyle_Tool );
    connect( process, SIGNAL(processExited()), progwindow, SLOT(close()));
    progwindow->setProcess( process );

    progwindow->show();
    progwindow->raise();
    progwindow->progressBar->setTotalSteps( 100 );
    
    progwindow->setActiveWindow();
    progwindow->setUpdatesEnabled( TRUE );
    progwindow->setEnabled( true );

    process->clearArguments();
    process->setArguments( myCommand );

    // myMainApp->setEnabled( false );
    app->disableButtons();
    process->start();

     
    while( process->isRunning() ) {
      for( int i = 0; i <= 100; i++ ) {
        usleep(10000);
        progwindow->progressBar->setProgress(i,100);
        progwindow->update();
        
        qApp->processEvents();
      } 
      
      if( ! process->isRunning() ) {
        progwindow->close();
      }
    }
    app->restoreButtonsState();
  }
  // myMainApp->setEnabled( true );

  this->close();
}

void linboYesNoImpl::setTextBrowser( Q3TextBrowser* newBrowser )
{
  Console = newBrowser;
}

void linboYesNoImpl::setMainApp( QWidget* newMainApp ) {
  myMainApp = newMainApp;
}

void linboYesNoImpl:: setCommand(const QStringList& arglist)
{
  myCommand = QStringList(arglist); // Create local copy
}

void linboYesNoImpl::readFromStdout()
{
  while( process->canReadLineStdout() )
    {
      line = process->readLineStdout();
      Console->append( line );
    } 
}

QStringList linboYesNoImpl::getCommand() {
  return myCommand;
}


void linboYesNoImpl::readFromStderr()
{
  while( process->canReadLineStderr() )
    {
      line = process->readLineStderr();
      line.prepend( "<FONT COLOR=red>" );
      line.append( "</FONT>" );
      Console->append( line );
    } 
}
