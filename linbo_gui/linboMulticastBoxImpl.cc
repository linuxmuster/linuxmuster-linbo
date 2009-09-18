#include "linboMulticastBoxImpl.hh"
#include "linboProgressImpl.hh"
#include "linboGUIImpl.hh"
#include <q3progressbar.h>
#include <qapplication.h>
#include <qradiobutton.h>
#include "linboPushButton.hh"
#include "linboYesNoImpl.hh"
#include <QtGui>

linboMulticastBoxImpl::linboMulticastBoxImpl(  QWidget* parent ) : linboDialog()
{

  Ui_linboMulticastBox::setupUi((QDialog*)this);

  process = new Q3Process( this );

  // nothing to do
  connect(okButton,SIGNAL(pressed()),this,SLOT(postcmd()));
  connect(cancelButton,SIGNAL(clicked()),this,SLOT(close()));

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

linboMulticastBoxImpl::~linboMulticastBoxImpl()
{
} 

void linboMulticastBoxImpl::setTextBrowser( Q3TextBrowser* newBrowser )
{
  Console = newBrowser;
}

void linboMulticastBoxImpl::setMainApp( QWidget* newMainApp ) {
  myMainApp = newMainApp;
}


void linboMulticastBoxImpl::precmd() {
  // nothing to do
}


void linboMulticastBoxImpl::postcmd() {
  this->hide();
  
  linboGUIImpl* app = static_cast<linboGUIImpl*>( myMainApp );
  process->clearArguments();
  if ( this->rsyncButton->isChecked() )
    process->setArguments( myRsyncCommand );
  if ( this->multicastButton->isChecked() )
    process->setArguments( myMulticastCommand );
  if ( this->torrentButton->isChecked() )
    process->setArguments( myBittorrentCommand );
    

  if( app ) {
    // do something
    linboProgressImpl *progwindow = new linboProgressImpl(0); //,"Arbeite...",0, Qt::WStyle_Tool );
    connect( process, SIGNAL(processExited()), progwindow, SLOT(close()));

    progwindow->setTextBrowser( Console );
    progwindow->setProcess( process );
    progwindow->show();
    progwindow->raise();
    progwindow->progressBar->setTotalSteps( 100 );

    progwindow->setActiveWindow();
    progwindow->setUpdatesEnabled( true );
    progwindow->setEnabled( true );
      
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
  }
  app->restoreButtonsState();
  
  this->close();
}

void linboMulticastBoxImpl::setRsyncCommand(const QStringList& arglist)
{
  myRsyncCommand = QStringList(arglist); // Create local copy
}

void linboMulticastBoxImpl::setMulticastCommand(const QStringList& arglist)
{
  myMulticastCommand = QStringList(arglist); // Create local copy
}

void linboMulticastBoxImpl::setBittorrentCommand(const QStringList& arglist)
{
  myBittorrentCommand = QStringList(arglist); // Create local copy
}

void linboMulticastBoxImpl::setCommand(const QStringList& arglist)
{
  // no sense setting this here
}

QStringList linboMulticastBoxImpl::getCommand()
{
  // no sense setting this here
  return myCommand;
}


void linboMulticastBoxImpl::readFromStdout()
{
  while( process->canReadLineStdout() )
    {
      line = process->readLineStdout();
      Console->append( line );
    } 
}

void linboMulticastBoxImpl::readFromStderr()
{
  while( process->canReadLineStderr() )
    {
      line = process->readLineStderr();
      line.prepend( "<FONT COLOR=red>" );
      line.append( "</FONT>" );
      Console->append( line );
    } 
}
