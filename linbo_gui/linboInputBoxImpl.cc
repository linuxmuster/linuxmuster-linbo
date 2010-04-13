#include "linboInputBoxImpl.hh"
#include "linboProgressImpl.hh"
#include "linboGUIImpl.hh"
#include <q3progressbar.h>
#include <qapplication.h>
#include <QtGui>
#include "linboPushButton.hh"
#include "linboYesNoImpl.hh"

linboInputBoxImpl::linboInputBoxImpl(  QWidget* parent ) : linboDialog()
{
  Ui_linboInputBox::setupUi((QDialog*)this);
  process = new Q3Process( this );

  // nothing to do
  connect(input,SIGNAL(returnPressed()),this,SLOT(postcmd()));

  // connect stdout and stderr to linbo console
  connect( process, SIGNAL(readyReadStdout()),
           this, SLOT(readFromStdout()) );
  connect( process, SIGNAL(readyReadStderr()),
           this, SLOT(readFromStderr()) );

}

linboInputBoxImpl::~linboInputBoxImpl()
{
} 

void linboInputBoxImpl::setTextBrowser( Q3TextBrowser* newBrowser )
{
  Console = newBrowser;
}

void linboInputBoxImpl::setMainApp( QWidget* newMainApp ) {
  myMainApp = newMainApp;
}


void linboInputBoxImpl::precmd() {
  // nothing to do
}


void linboInputBoxImpl::postcmd() {
  this->hide();
  
  if( !input->text().isEmpty() ) {

    // change image name
    QStringList tmp;
    linbopushbutton* neighbour = (static_cast<linbopushbutton*>(this->parentWidget()))->getNeighbour();

    if( linboDialog* neighbourDialog = neighbour->getLinboDialog()  ) {
      // in this case, we have a sub-dialogue
      tmp = neighbourDialog->getCommand();
      
      if( tmp[1] == QString("upload") ) {
        // change file name
        tmp[6] = input->text();
        neighbourDialog->setCommand( tmp );
        
        if( dynamic_cast<linboYesNoImpl*>( neighbour->getQDialog() ) ) {
          // we know now, the neighbour is an button with a yesno-box
          static_cast<linboYesNoImpl*>((QWidget*)neighbour->getQDialog())->question->setText("Image " + input->text() + " hochladen?");
        }
      }
    }
  
    // change the command of the main button
    tmp = neighbour->getCommand();  

    if( tmp[1] == QString("upload") ) {
      // change upload password
      tmp[6] = input->text();
      neighbour->setCommand( tmp );
    }
  }  
        
  if( !input->text().isEmpty() && myMainApp ) {
    linboGUIImpl* app = static_cast<linboGUIImpl*>( myMainApp );
    myCommand[3]=input->text();
   
    

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
  }
  this->close();
}

void linboInputBoxImpl::setCommand(const QStringList& arglist)
{
  myCommand = QStringList(arglist); // Create local copy
}

QStringList linboInputBoxImpl::getCommand()
{
  return QStringList(myCommand); 
}


void linboInputBoxImpl::readFromStdout()
{
  while( process->canReadLineStdout() )
    {
      line = process->readLineStdout();
      Console->append( line );
    } 
}

void linboInputBoxImpl::readFromStderr()
{
  while( process->canReadLineStderr() )
    {
      line = process->readLineStderr();
      line.prepend( "<FONT COLOR=red>" );
      line.append( "</FONT>" );
      Console->append( line );
    } 
}
