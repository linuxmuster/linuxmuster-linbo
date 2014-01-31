#include "linboRegisterBoxImpl.hh"
#include <q3progressbar.h>
#include <qapplication.h>
#include <QtGui>
#include "linboPushButton.hh"
#include "linboYesNoImpl.hh"

linboRegisterBoxImpl::linboRegisterBoxImpl(  QWidget* parent ) : linboDialog()
{
  Ui_linboRegisterBox::setupUi((QDialog*)this);

  process = new QProcess( this );
  progwindow = new linboProgressImpl(0);

  logConsole = new linboLogConsole(0);

  if( parent )
    myParent = parent;

  connect(registerButton,SIGNAL(clicked()),this,SLOT(postcmd()));
  connect(cancelButton,SIGNAL(clicked()),this,SLOT(close()));

  // connect SLOT for finished process
  connect( process, SIGNAL(finished(int, QProcess::ExitStatus) ),
           this, SLOT(processFinished(int, QProcess::ExitStatus)) );

  // connect stdout and stderr to linbo console
  connect( process, SIGNAL(readyReadStandardOutput()),
	   this, SLOT(readFromStdout()) );
  connect( process, SIGNAL(readyReadStandardError()),
	   this, SLOT(readFromStderr()) );

  Qt::WindowFlags flags;
  flags = Qt::Dialog | Qt::WindowStaysOnTopHint | Qt::WindowTitleHint;
  setWindowFlags( flags );

  QRect qRect(QApplication::desktop()->screenGeometry());
  // open in the center of our screen
  int xpos=qRect.width()/2-this->width()/2;
  int ypos=qRect.height()/2-this->height()/2;
  this->move(xpos,ypos);
  this->setFixedSize( this->width(), this->height() );
}

linboRegisterBoxImpl::~linboRegisterBoxImpl()
{
} 

void linboRegisterBoxImpl::setTextBrowser( const QString& new_consolefontcolorstdout,
					   const QString& new_consolefontcolorstderr,
					   QTextEdit* newBrowser )
{
  logConsole->setLinboLogConsole( new_consolefontcolorstdout,
				  new_consolefontcolorstderr,
				  newBrowser );
}

void linboRegisterBoxImpl::setMainApp( QWidget* newMainApp ) {
  myMainApp = newMainApp;
}


void linboRegisterBoxImpl::precmd() {
    // Die vorgeschlagenen Daten fuer die Rechneraufnahme lesen und anzeigen
    QProcess* preprocess = new QProcess( this );
    ifstream newdata;
    QString registerData;
    QStringList registerDataList;
    char line[1024];
    QStringList cmdargs( myPreCommand );

    QString precommand = cmdargs.takeFirst();
    preprocess->start(precommand, cmdargs);
    preprocess->waitForFinished();

    newdata.open("/tmp/newregister", ios::in);
    if (newdata.is_open()) {
        newdata.getline(line,1024,'\n');
        registerData = QString::fromAscii( line, -1 ).stripWhiteSpace();
        newdata.close();
        registerDataList = registerData.split(',');

        roomName->setText(registerDataList[0]);
        clientGroup->setText(registerDataList[1]);
        clientName->setText(registerDataList[2]);
        ipAddress->setText(registerDataList[3]);
    }
}


void linboRegisterBoxImpl::postcmd() {
  this->hide();
  // here, some further checks are needed
  if( !roomName->text().isEmpty() &&
      !ipAddress->text().isEmpty() &&
      !clientGroup->text().isEmpty() &&
      !clientName->text().isEmpty() ) {

    // update our command
    // room name
    myCommand[5] = roomName->text();
    // client name
    myCommand[6] = clientName->text();
    // IP
    myCommand[7] = ipAddress->text();
    // client group
    myCommand[8] = clientGroup->text();

    app = static_cast<linboGUIImpl*>( myMainApp );

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

      QStringList processargs( myCommand );
      QString command = processargs.takeFirst();

      process->start( command, processargs );

      process->waitForStarted();

      while( process->state() == QProcess::Running ) {
        for( int i = 0; i <= 100; i++ ) {
          usleep(10000);
          progwindow->progressBar->setValue(i);
          progwindow->update();
          
          qApp->processEvents();
        } 
        
      }
    }
    app->restoreButtonsState();
  }
  this->close();
}

void linboRegisterBoxImpl::setCommand(const QStringList& arglist)
{
  myCommand = QStringList(arglist); // Create local copy
}

QStringList linboRegisterBoxImpl::getCommand()
{
  return QStringList(myCommand); 
}

void linboRegisterBoxImpl::setPreCommand(const QStringList& arglist)
{
  myPreCommand = QStringList(arglist); // Create local copy
}

QStringList linboRegisterBoxImpl::getPreCommand()
{
  return QStringList(myPreCommand); 
}

void linboRegisterBoxImpl::readFromStdout()
{
  logConsole->writeStdOut( process->readAllStandardOutput() );
}

void linboRegisterBoxImpl::readFromStderr()
{
  logConsole->writeStdErr( process->readAllStandardError() );
}

void linboRegisterBoxImpl::processFinished( int retval,
                                             QProcess::ExitStatus status) {

  logConsole->writeResult( retval, status, process->error() );

  app->restoreButtonsState();

  if( progwindow ) {
    progwindow->close();
  }
}
