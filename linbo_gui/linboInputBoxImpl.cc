#include "linboInputBoxImpl.hh"
#include <q3progressbar.h>
#include <qapplication.h>
#include <QtGui>
#include "linboPushButton.hh"
#include "linboYesNoImpl.hh"

linboInputBoxImpl::linboInputBoxImpl(  QWidget* parent ) : linboDialog()
{
  Ui_linboInputBox::setupUi((QDialog*)this);
  process = new QProcess( this );

  if( parent )
    myParent = parent;

  // nothing to do
  connect(input,SIGNAL(returnPressed()),this,SLOT(postcmd()));

  // connect SLOT for finished process
  connect( process, SIGNAL(finished(int, QProcess::ExitStatus) ),
           this, SLOT(processFinished(int, QProcess::ExitStatus)) );

  // connect stdout and stderr to linbo console
  connect( process, SIGNAL(readyReadStandardOutput()),
	   this, SLOT(readFromStdout()) );
  connect( process, SIGNAL(readyReadStandardError()),
	   this, SLOT(readFromStderr()) );

  progwindow = new linboProgressImpl(0);

  Qt::WindowFlags flags;
  flags = Qt::Dialog | Qt::WindowStaysOnTopHint ;
  setWindowFlags( flags );

  QRect qRect(QApplication::desktop()->screenGeometry());
  // open in the center of our screen
  int xpos=qRect.width()/2-this->width()/2;
  int ypos=qRect.height()/2-this->height()/2;
  this->move(xpos,ypos);
  this->setFixedSize( this->width(), this->height() );
}

linboInputBoxImpl::~linboInputBoxImpl()
{
} 

void linboInputBoxImpl::setTextBrowser( QTextEdit* newBrowser )
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
    app = static_cast<linboGUIImpl*>( myMainApp );
    myCommand[3]=input->text();
   
    

    if( app ) {
      // do something
      progwindow->setProcess( process );
      // connect( process, SIGNAL(processExited()), progwindow, SLOT(close()));
      progwindow->show();
      progwindow->raise();

      progwindow->setActiveWindow();
      progwindow->setUpdatesEnabled( true );
      progwindow->setEnabled( true );
      
      app->disableButtons();

      arguments = myCommand;

      QStringList processargs( arguments );
      QString command = processargs.takeFirst();

      process->start( command, processargs );

      while( process->state() == QProcess::Running ) {
        for( int i = 0; i <= 100; i++ ) {
          usleep(10000);
          progwindow->progressBar->setValue(i);
          progwindow->update();
          
          qApp->processEvents();
        } 
      }
    }
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
  Console->insert( process->readAllStandardOutput() );
}

void linboInputBoxImpl::readFromStderr()
{
  Console->setColor( QColor( QString("red") ) );
  Console->insert( process->readAllStandardError() );
  Console->setColor( QColor( QString("white") ) );
}

void linboInputBoxImpl::processFinished( int retval,
                                             QProcess::ExitStatus status) {

  Console->setColor( QColor( QString("red") ) );
  Console->append( QString("Command executed with exit value ") + QString::number( retval ) );

  if( status == 0)
    Console->append( QString("Exit status: ") + QString("The process exited normally.") );
  else
    Console->append( QString("Exit status: ") + QString("The process crashed.") );

  if( status == 1 ) {
    int errorstatus = process->error();
    switch ( errorstatus ) {
      case 0: Console->append( QString("The process failed to start. Either the invoked program is missing, or you may have insufficient permissions to invoke the program.") ); break;
      case 1: Console->append( QString("The process crashed some time after starting successfully.") ); break;
      case 2: Console->append( QString("The last waitFor...() function timed out.") ); break;
      case 3: Console->append( QString("An error occurred when attempting to write to the process. For example, the process may not be running, or it may have closed its input channel.") ); break;
      case 4: Console->append( QString("An error occurred when attempting to read from the process. For example, the process may not be running.") ); break;
      case 5: Console->append( QString("An unknown error occurred.") ); break;
    }

  }
  Console->setColor( QColor( QString("white") ) );
			   

  app->restoreButtonsState();

  if( progwindow ) {
    progwindow->close();
  }

}
