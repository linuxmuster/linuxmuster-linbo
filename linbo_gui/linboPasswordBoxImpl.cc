#include "linboPasswordBoxImpl.hh"
#include <qprocess.h>
#include <iostream>
#include "linboCounter.hh"
#include <qmovie.h>
#include <qpoint.h>
#include <qlcdnumber.h>
#include <qapplication.h>
#include <qcheckbox.h>

linboPasswordBoxImpl::linboPasswordBoxImpl(  QWidget* parent,
                                             const char* name,
                                             bool modal,
                                             WFlags fl ) : linboPasswordBox( parent,
                                                                             name ), 
                                                           linboDialog()
{
  connect(passwordInput,SIGNAL(returnPressed()),this,SLOT(postcmd()));

  process=new QProcess( this );

  myTimer = new QTimer(this);
  connect( myTimer, SIGNAL(timeout()), this, SLOT(processTimeout()) );
  // connect stdout and stderr to linbo console
  connect( process, SIGNAL(readyReadStdout()),
           this, SLOT(readFromStdout()) );
  connect( process, SIGNAL(readyReadStderr()),
           this, SLOT(readFromStderr()) );
}

linboPasswordBoxImpl::~linboPasswordBoxImpl()
{
  delete myTimer;
} 

void linboPasswordBoxImpl::precmd() {
  // nothing to do
}

void linboPasswordBoxImpl::postcmd() {
  this->hide();
  app = static_cast<linboGUIImpl*>( myMainApp );

  if( app ) {
    // check password here
    QStringList command = "linbo_cmd";
    command.append( "authenticate" );
    command.append( app->config.get_server() );
    command.append( "linbo" );
    command.append( passwordInput->text() );
    command.append( "linbo" );
    
    process->clearArguments();
    process->setArguments( command );
    
    if( process->start() ) {
      while( process->isRunning() ) {
      };
      
      if ( !process->exitStatus() ) {
        if( app ) {
          // set password in all buttons
          QStringList tmp;
          for( unsigned int i = 0; i < app->p_buttons.size(); i++ )
            {
              if( linboDialog* tmpDialog = app->p_buttons[i]->getLinboDialog()  ) {
                // in this case, we have a sub-dialogue
                tmp = tmpDialog->getCommand();

                if( tmp[1] == QString("upload") ||
                    tmp[1] == QString("register") ) {
                  // change upload password
                  tmp[4] = passwordInput->text();
                  tmpDialog->setCommand( tmp );
                }         

              }
              // change the command of the main button
              for( unsigned int i = 0; i < app->p_buttons.size(); i++ )
                {
                  tmp = app->p_buttons[i]->getCommand();

                  if( tmp[1] == QString("upload") ||
                      tmp[1] == QString("register") ) {
                    // change upload password
                    tmp[4] = passwordInput->text();
                    app->p_buttons[i]->setCommand( tmp );
                  }
                }   
            }

          app->enableButtons();
          app->showImagingTab();
              
          myTimer->stop();
          myTimer->start( 1000, FALSE ); 
          currentTimeout = app->config.get_roottimeout();
          

          myCounter = new linboCounter(this,"Root",0, Qt::WStyle_Tool );
          myCounter->counter->display( currentTimeout );

          connect( myCounter->logoutButton, SIGNAL(pressed()), app, SLOT(resetButtons()) );
          connect( myCounter->logoutButton, SIGNAL(clicked()), myTimer, SLOT(stop()) );
          connect( myCounter->logoutButton, SIGNAL(released()), myCounter, SLOT(close()) );
          


          myCounter->show();
          myCounter->raise();
          myCounter->move( QPoint( 5, 5 ) );
    
        }
      }
    }
  }
  passwordInput->clear();
  this->close();
}

void linboPasswordBoxImpl::setCommand(const QStringList& arglist)
{
  myCommand = arglist;
}

QStringList linboPasswordBoxImpl::getCommand()
{
  return QStringList(myCommand); 
}

void linboPasswordBoxImpl::setMainApp( QWidget* newMainApp ) {
  if ( newMainApp ) {
    myMainApp = newMainApp;
  }
}

void linboPasswordBoxImpl::readFromStdout()
{
  while( process->canReadLineStdout() )
    {
      line = process->readLineStdout();
      Console->append( line );
    } 
}

void linboPasswordBoxImpl::readFromStderr()
{
  while( process->canReadLineStderr() )
    {
      line = process->readLineStderr();
      line.prepend( "<FONT COLOR=red>" );
      line.append( "</FONT>" );
      Console->append( line );
    } 
}

void linboPasswordBoxImpl::setTextBrowser( QTextBrowser* newBrowser )
{
  Console = newBrowser;
}

void linboPasswordBoxImpl::processTimeout() {
  if( !myCounter->timeoutCheck->isChecked() ) {
    // do nothing but dont stop timer
  } 
  else {
    if( currentTimeout > 0 ) {
      currentTimeout--;
      myCounter->counter->display( currentTimeout );
    }
    else {
      app->resetButtons();
      myCounter->close();
    }
  }
}
