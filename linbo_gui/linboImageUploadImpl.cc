#include "linboImageUploadImpl.hh"
#include "linboProgressImpl.hh"
#include "linboGUIImpl.hh"
#include <q3progressbar.h>
#include <qapplication.h>
#include <q3listbox.h>
#include <QtGui>
#include "linboPushButton.hh"
#include "linboYesNoImpl.hh"

linboImageUploadImpl::linboImageUploadImpl(  QWidget* parent ) : linboDialog()
{
  Ui_linboImageUpload::setupUi((QDialog*)this);
  process = new Q3Process( this );

  connect( cancelButton, SIGNAL(pressed()), this, SLOT(close()) );
  connect( okButton, SIGNAL(pressed()), this, SLOT(postcmd()) );

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

linboImageUploadImpl::~linboImageUploadImpl()
{
} 

void linboImageUploadImpl::setTextBrowser( Q3TextBrowser* newBrowser )
{
  Console = newBrowser;
}

void linboImageUploadImpl::setMainApp( QWidget* newMainApp ) {
  myMainApp = newMainApp;
}


void linboImageUploadImpl::precmd() {
  // nothing to do
}


void linboImageUploadImpl::postcmd() {
  

  linboGUIImpl* app = static_cast<linboGUIImpl*>( myMainApp );
  
  this->hide();
  myCommand[6] = listBox->currentText();

  
  if( app ) {
    // do something
    linboProgressImpl *progwindow = new linboProgressImpl(0);//,"Arbeite...",0, Qt::WStyle_Tool );
    progwindow->setProcess( process );
    connect( process, SIGNAL(processExited()), progwindow, SLOT(close()));
    progwindow->show();
    progwindow->raise();
    progwindow->progressBar->setTotalSteps( 100 );
    
    progwindow->setActiveWindow();
    progwindow->setUpdatesEnabled( true );
    progwindow->setEnabled( true );
    
    process->clearArguments();
    process->setArguments( myCommand );
    
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

void linboImageUploadImpl::setCommand(const QStringList& arglist)
{
  myCommand = QStringList(arglist); 
}

QStringList linboImageUploadImpl::getCommand()
{
  return QStringList(myCommand); 
}


void linboImageUploadImpl::readFromStdout()
{
  while( process->canReadLineStdout() )
    {
      line = process->readLineStdout();
      Console->append( line );
    } 
}

void linboImageUploadImpl::readFromStderr()
{
  while( process->canReadLineStderr() )
    {
      line = process->readLineStderr();
      line.prepend( "<FONT COLOR=red>" );
      line.append( "</FONT>" );
      Console->append( line );
    } 
}
