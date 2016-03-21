#include <unistd.h>
#include <qprogressbar.h>
#include <qapplication.h>
#include <QtGui>
#include "linboPushButton.h"
#include "linboYesNo.h"

#include "linboInputBox.h"
#include "ui_linboInputBox.h"

linboInputBox::linboInputBox(  QWidget* parent ) : linboDialog(), ui(new Ui::linboInputBox)
{
  ui->setupUi((QDialog*)this);
  process = new QProcess( this );

  if( parent )
    myParent = parent;

  // nothing to do
  connect(ui->input,SIGNAL(returnPressed()),this,SLOT(postcmd()));

  // connect SLOT for finished process
  connect( process, SIGNAL(finished(int, QProcess::ExitStatus) ),
           this, SLOT(processFinished(int, QProcess::ExitStatus)) );

  // connect stdout and stderr to linbo console
  connect( process, SIGNAL(readyReadStandardOutput()),
	   this, SLOT(readFromStdout()) );
  connect( process, SIGNAL(readyReadStandardError()),
	   this, SLOT(readFromStderr()) );

  progwindow = new linboProgress(0);

  logConsole = new linboLogConsole(0);

  Qt::WindowFlags flags;
  flags = Qt::Dialog | Qt::WindowStaysOnTopHint | Qt::WindowTitleHint ;
  setWindowFlags( flags );

  QRect qRect(QApplication::desktop()->screenGeometry());
  // open in the center of our screen
  int xpos=qRect.width()/2-this->width()/2;
  int ypos=qRect.height()/2-this->height()/2;
  this->move(xpos,ypos);
  this->setFixedSize( this->width(), this->height() );
}

linboInputBox::~linboInputBox()
{
} 

void linboInputBox::setTextBrowser( const QString& new_consolefontcolorstdout,
					const QString& new_consolefontcolorstderr,
					QTextEdit* newBrowser )
{
  logConsole->setLinboLogConsole( new_consolefontcolorstdout,
				  new_consolefontcolorstderr,
				  newBrowser );
}

void linboInputBox::setMainApp( QWidget* newMainApp ) {
  myMainApp = newMainApp;
}


void linboInputBox::precmd() {
  // nothing to do
}


void linboInputBox::postcmd() {
  this->hide();
  
  if( !ui->input->text().isEmpty() ) {

    // change image name
    QStringList tmp;
    linbopushbutton* neighbour = (static_cast<linbopushbutton*>(this->parentWidget()))->getNeighbour();

    if( linboDialog* neighbourDialog = neighbour->getLinboDialog()  ) {
      // in this case, we have a sub-dialogue
      tmp = neighbourDialog->getCommand();
      
      if( tmp[1] == QString("upload") ) {
        // change file name
        tmp[6] = ui->input->text();
        neighbourDialog->setCommand( tmp );
        
        if( dynamic_cast<linboYesNo*>( neighbour->getQDialog() ) ) {
          // we know now, the neighbour is an button with a yesno-box
          static_cast<linboYesNo*>((QWidget*)neighbour->getQDialog())->setQuestionText("Image " + ui->input->text() + " hochladen?");
        }
      }
    }
  
    // change the command of the main button
    tmp = neighbour->getCommand();  

    if( tmp[1] == QString("upload") ) {
      // change upload password
      tmp[6] = ui->input->text();
      neighbour->setCommand( tmp );
    }
  }  
        
  if( !ui->input->text().isEmpty() && myMainApp ) {
    app = static_cast<LinboGUI*>( myMainApp );
    myCommand[3]=ui->input->text();
   
    

    if( app ) {
      // do something
      progwindow->setProcess( process );
      // connect( process, SIGNAL(processExited()), progwindow, SLOT(close()));
      progwindow->show();
      progwindow->raise();

      //FIXME: progwindow->setActiveWindow();
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
          progwindow->setProgress(i);
          progwindow->update();
          
          qApp->processEvents();
        } 
      }
    }
  }
  this->close();
}

void linboInputBox::setCommand(const QStringList& arglist)
{
  myCommand = QStringList(arglist); // Create local copy
}

QStringList linboInputBox::getCommand()
{
  return QStringList(myCommand); 
}


void linboInputBox::readFromStdout()
{
  logConsole->writeStdOut( process->readAllStandardOutput() );
}

void linboInputBox::readFromStderr()
{
  logConsole->writeStdErr( process->readAllStandardError() );
}

void linboInputBox::processFinished( int retval,
                                             QProcess::ExitStatus status) {

  logConsole->writeResult( retval, status, process->error() );
  
  app->restoreButtonsState();

  if( progwindow ) {
    progwindow->close();
  }

}
