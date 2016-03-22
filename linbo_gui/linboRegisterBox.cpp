#include <unistd.h>
#include <qprogressbar.h>
#include <qapplication.h>
#include <QtGui>
#include "linboPushButton.h"
#include "linboYesNo.h"

#include "linboRegisterBox.h"
#include "ui_linboRegisterBox.h"

linboRegisterBox::linboRegisterBox(  QWidget* parent ) : linboDialog(), ui(new Ui::linboRegisterBox)
{
  ui->setupUi(this);

  process = new QProcess( this );
  progwindow = new linboProgress(0);

  logConsole = new linboLogConsole(0);

  if( parent )
    myParent = parent;

  connect(ui->registerButton,SIGNAL(clicked()),this,SLOT(postcmd()));
  connect(ui->cancelButton,SIGNAL(clicked()),this,SLOT(close()));

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

linboRegisterBox::~linboRegisterBox()
{
} 

void linboRegisterBox::setTextBrowser( const QString& new_consolefontcolorstdout,
					   const QString& new_consolefontcolorstderr,
					   QTextEdit* newBrowser )
{
  logConsole->setLinboLogConsole( new_consolefontcolorstdout,
				  new_consolefontcolorstderr,
				  newBrowser );
}

void linboRegisterBox::setMainApp( QWidget* newMainApp ) {
  myMainApp = newMainApp;
}


void linboRegisterBox::precmd() {
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
        registerData = QString::fromUtf8( line, -1 ).trimmed();
        newdata.close();
        registerDataList = registerData.split(',');

        ui->roomName->setText(registerDataList[0]);
        ui->clientGroup->setText(registerDataList[1]);
        ui->clientName->setText(registerDataList[2]);
        ui->ipAddress->setText(registerDataList[3]);
    }
}


void linboRegisterBox::postcmd() {
  this->hide();
  // here, some further checks are needed
  if( !ui->roomName->text().isEmpty() &&
      !ui->ipAddress->text().isEmpty() &&
      !ui->clientGroup->text().isEmpty() &&
      !ui->clientName->text().isEmpty() ) {

    // update our command
    // room name
    myCommand[5] = ui->roomName->text();
    // client name
    myCommand[6] = ui->clientName->text();
    // IP
    myCommand[7] = ui->ipAddress->text();
    // client group
    myCommand[8] = ui->clientGroup->text();

    app = static_cast<LinboGUI*>( myMainApp );

    if( app ) {
      // do something
      progwindow->setProcess( process );
      // connect( process, SIGNAL(processExited()), progwindow, SLOT(close()));
      progwindow->show();
      progwindow->raise();

      progwindow->activateWindow();
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
          progwindow->setProgress(i);
          progwindow->update();
          
          qApp->processEvents();
        } 
        
      }
    }
    app->restoreButtonsState();
  }
  this->close();
}

void linboRegisterBox::setCommand(const QStringList& arglist)
{
  myCommand = QStringList(arglist); // Create local copy
}

QStringList linboRegisterBox::getCommand()
{
  return QStringList(myCommand); 
}

void linboRegisterBox::setPreCommand(const QStringList& arglist)
{
  myPreCommand = QStringList(arglist); // Create local copy
}

QStringList linboRegisterBox::getPreCommand()
{
  return QStringList(myPreCommand); 
}

void linboRegisterBox::readFromStdout()
{
  logConsole->writeStdOut( process->readAllStandardOutput() );
}

void linboRegisterBox::readFromStderr()
{
  logConsole->writeStdErr( process->readAllStandardError() );
}

void linboRegisterBox::processFinished( int retval,
                                             QProcess::ExitStatus status) {

  logConsole->writeResult( retval, status, process->error() );

  app->restoreButtonsState();

  if( progwindow ) {
    progwindow->close();
  }
}
