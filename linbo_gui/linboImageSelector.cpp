#include <unistd.h>
#include <qprogressbar.h>
#include <qapplication.h>
#include <qbuttongroup.h>
#include <qlistwidget.h>
#include <QtGui>
#include <qradiobutton.h>
#include <QTextStream>
#include <QDesktopWidget>

#include "linboImageSelector.h"
#include "ui_linboImageSelector.h"
#include "linboImageUpload.h"
#include "linboPushButton.h"

linboImageSelector::linboImageSelector(  QWidget* parent ) : linboDialog(), ui(new Ui::linboImageSelector)
{
  ui->setupUi(this);
  process = new QProcess( this );

  progwindow = new linboProgress(0);

  logConsole = new linboLogConsole(0);

  if( parent )
    myParent = parent;

  connect( ui->cancelButton, SIGNAL(pressed()), this, SLOT(close()) );
  connect( ui->createButton, SIGNAL(pressed()), this, SLOT(postcmd()) );
  connect( ui->createUploadButton, SIGNAL(pressed()), this, SLOT(postcmd2()) );
  connect( ui->listBox, SIGNAL(selectionChanged()), this, SLOT(selectionWatcher()) );
  
  // connect SLOT for finished process
  connect( process, SIGNAL(finished(int, QProcess::ExitStatus) ),
           this, SLOT(processFinished(int, QProcess::ExitStatus)) );

  // connect stdout and stderr to linbo console
  connect( process, SIGNAL(readyReadStandardOutput()),
	   this, SLOT(readFromStdout()) );

  connect( process, SIGNAL(readyReadStandardError()),
	   this, SLOT(readFromStderr()) );

  ui->specialName->setEnabled( false );
  ui->baseRadioButton->setEnabled( false );
    ui->incrRadioButton->setEnabled( false );
  upload=false;
  neighbourDialog = 0;

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

linboImageSelector::~linboImageSelector()
{
} 

void linboImageSelector::setTextBrowser( const QString& new_consolefontcolorstdout,
					     const QString& new_consolefontcolorstderr,
					     QTextEdit* newBrowser )
{
  logConsole->setLinboLogConsole( new_consolefontcolorstdout,
				  new_consolefontcolorstderr,
				  newBrowser );
}

void linboImageSelector::setMainApp( QWidget* newMainApp ) {
  myMainApp = newMainApp;
  app = static_cast<LinboGUI*>( myMainApp );
}


void linboImageSelector::precmd() {
  // nothing to do
}

void linboImageSelector::selectionWatcher() {
  // without this, this element segfaults linboGUI during constructor
  if( this->isHidden() == false ) {
    if( ui->listBox->currentItem()->text() == "[Neuer Dateiname]" ) {
      ui->specialName->setEnabled( true );
      ui->baseRadioButton->setEnabled( true );
      ui->incrRadioButton->setEnabled( true );
      ui->infoEditor->clear();
    } else {
      ui->specialName->setEnabled( false );
      ui->baseRadioButton->setEnabled( false );
      ui->incrRadioButton->setEnabled( false );

      myLoadCommand[3] = ui->listBox->currentItem()->text() + QString(".desc");
      myLoadCommand[4] = QString("/tmp/") + ui->listBox->currentItem()->text() + QString(".desc");
      
      mySaveCommand[3] = ui->listBox->currentItem()->text() + QString(".desc");
      mySaveCommand[4] = QString("/tmp/") + ui->listBox->currentItem()->text() + QString(".desc");
      
      arguments.clear();
      arguments = myLoadCommand;
      
#ifdef DEBUG
      logConsole->writeStdErr(QString("linboInfoBrowser: myLoadCommand"));
      QStringList list = arguments();
      QStringList::Iterator it = list.begin();
      while( it != list.end() ) {
	Console->insert( *it );
	++it;
      }
      logConsole->writeStdErr(QString("*****"));
#endif
      
      QStringList processargs( arguments );
      QString command = processargs.takeFirst();
      
      progwindow->startTimer();
      process->start( command, processargs );
      

      logConsole->writeStdErr( QString("Executing ") + command + processargs.join(" ") );
      
      // important: give process time to start up
      process->waitForStarted();
      
      while (process->state() == QProcess::Running ) {
	for( int i = 0; i <= 100; i++ ) {
	  usleep(10000);
      progwindow->setProgress(i);
	  progwindow->update();
	  qApp->processEvents();
	}
      }
      
      
      file = new QFile( myLoadCommand[4] );
      // read content
      if( !file->open( QIODevice::ReadOnly ) ) {
	logConsole->writeStdErr( QString("Keine passende Beschreibung im Cache.") );
      } 
      else {
    QTextStream ts( file );
    ui->infoEditor->setText( ts.readAll() );
	file->close();
      }
    } 
  }
}

void linboImageSelector::setLoadCommand( const QStringList& newLoadCommand ) {
  myLoadCommand = newLoadCommand;
}

void linboImageSelector::setSaveCommand( const QStringList& newSaveCommand ) {
  mySaveCommand = newSaveCommand;
}

void linboImageSelector::setBaseImage( const QString& newBase ) {
  baseImage = newBase;
}

void linboImageSelector::postcmd2() {
  upload=true;
  this->postcmd();
}

void linboImageSelector::postcmd() {
  this->hide();

  QString selection, imageName;

  selection = ui->listBox->currentItem()->text();

  linbopushbutton* neighbour = (static_cast<linbopushbutton*>(myParent))->getNeighbour();

  neighbourDialog = 0;
  neighbourDialog = neighbour->getLinboDialog();

  if( selection != "[Neuer Dateiname]"  ) {
    // user choosed to rebuild an existing image

    myCommand[3] = selection;
    myCommand[4] = baseImage;

    if( ! (ui->infoEditor->toPlainText()).isEmpty() )
      info = ui->infoEditor->toPlainText();
    else
      info = QString("Beschreibung");

    // set image name to selected item
    imageName = selection;

  } else {
    // user choosed to build a new image
    if( ! (ui->infoEditor->toPlainText()).isEmpty() )
      info = ui->infoEditor->toPlainText();
    else
      info = QString("Informationen zu" + ui->specialName->text() +":" );

    imageName = ui->specialName->text();

    if( !imageName.isEmpty() ) {
      if( ui->incrRadioButton->isChecked() ) {
        if( ! imageName.contains(".rsync") ) {
          imageName += QString(".rsync");
        }
        myCommand[3] = imageName;
        myCommand[4] = baseImage;
        ui->listBox->insertItem(ui->listBox->count() - 1, imageName );
      } else {
        if( ! imageName.contains(".cloop") ) {
          imageName += QString(".cloop");
        }
        myCommand[3] = imageName;
        myCommand[4] = imageName; // will be ignored
        ui->listBox->insertItem( ui->listBox->count() - 1, imageName );
      }
    }
    else { 
      return;
    }
    // expand save command 
    mySaveCommand[3] = imageName + QString(".desc");
    mySaveCommand[4] = QString("/tmp/") + imageName + QString(".desc");

    // this expands our neighbour
    if( neighbourDialog  ) {
      if( ! (static_cast<linboImageUpload*>(neighbourDialog))->findImageItem( imageName ) ) {
        (static_cast<linboImageUpload*>(neighbourDialog))->insertImageItem( imageName );
      }
    }
  }

  writeInfo();

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

    arguments.clear();
    arguments = myCommand;


    QStringList processargs( arguments );
    QString command = processargs.takeFirst();

    logConsole->writeStdErr( QString("Executing ") + command + processargs.join(" ") );
    
    progwindow->startTimer();
    process->start( command, processargs );

    // important: give process time to start up
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

  if( upload ) {
    if( neighbourDialog != 0 ) {
      (static_cast<linboImageUpload*>(neighbourDialog))->setCurrentImageItem( (static_cast<linboImageUpload*>(neighbourDialog))->findImageItem( imageName ) );
      neighbourDialog->postcmd();
    }
    else {
      logConsole->writeStdErr( QString("Eintrag nicht gefunden") );
    }
  } else {
    logConsole->writeStdErr( QString("Upload nicht ausgewählt") );
  }
  upload = false;

  if ( ui->checkShutdown->isChecked() ) {
    system("busybox poweroff");
  } else if ( ui->checkReboot->isChecked() ) {
    system("busybox reboot");
  }
  this->close(); 
}

void linboImageSelector::setCommand(const QStringList& arglist)
{
  myCommand = arglist; 
}

void linboImageSelector::setCache(const QString& newCache)
{
  myCache = newCache; 
}

QStringList linboImageSelector::getCommand()
{
  return arguments; 
}

void linboImageSelector::writeInfo() {
  file = new QFile( mySaveCommand[4] );
  if ( !file->open( QIODevice::WriteOnly ) ) {
    logConsole->writeStdErr( QString("Fehler beim Speichern der Beschreibung.") );
  } else {
    QTextStream ts( file );
    ts << info;
    file->flush();
    file->close();
  } 

  arguments.clear();
  arguments = mySaveCommand;

  QStringList processargs( arguments );
  QString command = processargs.takeFirst();

  progwindow->startTimer();
  process->start( command, processargs );

  // important: give process time to start up
  process->waitForStarted();

  while (process->state() == QProcess::Running ) {
    for( int i = 0; i <= 100; i++ ) {
      usleep(10000);
      progwindow->setProgress(i);
      progwindow->update();
      
      qApp->processEvents();
    }
  }  
}



void linboImageSelector::readFromStdout()
{
  logConsole->writeStdOut( process->readAllStandardOutput() );
}

void linboImageSelector::readFromStderr()
{
  logConsole->writeStdErr( process->readAllStandardError() );
}

void linboImageSelector::processFinished( int retval,
					      QProcess::ExitStatus status) {

  logConsole->writeResult( retval, status, process->error() );

  app->restoreButtonsState();

  if( progwindow ) {
    progwindow->close();
  }
}
