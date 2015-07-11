#include "linboImageSelectorImpl.hh"
#include <unistd.h>
#include <q3progressbar.h>
#include <qapplication.h>
#include <q3buttongroup.h>
#include <q3listbox.h>
#include <QtGui>
#include <qradiobutton.h>
//Added by qt3to4:
#include <Q3TextStream>
#include "linboImageUploadImpl.hh"
#include "linboPushButton.hh"

linboImageSelectorImpl::linboImageSelectorImpl(  QWidget* parent ) : linboDialog()
{
  Ui_linboImageSelector::setupUi((QDialog*)this);
  process = new QProcess( this );

  progwindow = new linboProgressImpl(0);

  logConsole = new linboLogConsole(0);

  if( parent )
    myParent = parent;

  connect( cancelButton, SIGNAL(pressed()), this, SLOT(close()) );
  connect( createButton, SIGNAL(pressed()), this, SLOT(postcmd()) );
  connect( createUploadButton, SIGNAL(pressed()), this, SLOT(postcmd2()) );
  connect( listBox, SIGNAL(selectionChanged()), this, SLOT(selectionWatcher()) );
  
  // connect SLOT for finished process
  connect( process, SIGNAL(finished(int, QProcess::ExitStatus) ),
           this, SLOT(processFinished(int, QProcess::ExitStatus)) );

  // connect stdout and stderr to linbo console
  connect( process, SIGNAL(readyReadStandardOutput()),
	   this, SLOT(readFromStdout()) );

  connect( process, SIGNAL(readyReadStandardError()),
	   this, SLOT(readFromStderr()) );

  specialName->setEnabled( false );
  imageButtons->setEnabled( false );

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

linboImageSelectorImpl::~linboImageSelectorImpl()
{
} 

void linboImageSelectorImpl::setTextBrowser( const QString& new_consolefontcolorstdout,
					     const QString& new_consolefontcolorstderr,
					     QTextEdit* newBrowser )
{
  logConsole->setLinboLogConsole( new_consolefontcolorstdout,
				  new_consolefontcolorstderr,
				  newBrowser );
}

void linboImageSelectorImpl::setMainApp( QWidget* newMainApp ) {
  myMainApp = newMainApp;
  app = static_cast<linboGUIImpl*>( myMainApp );
}


void linboImageSelectorImpl::precmd() {
  // nothing to do
}

void linboImageSelectorImpl::selectionWatcher() {
  // without this, this element segfaults linboGUI during constructor
  if( this->isHidden() == false ) {
    if( listBox->currentText() == "[Neuer Dateiname]" ) {
      specialName->setEnabled( true );
      imageButtons->setEnabled( true );
      infoEditor->clear();
    } else {
      specialName->setEnabled( false );
      imageButtons->setEnabled( false );
      
      myLoadCommand[3] = listBox->currentText() + QString(".desc");
      myLoadCommand[4] = QString("/tmp/") + listBox->currentText() + QString(".desc");
      
      mySaveCommand[3] = listBox->currentText() + QString(".desc");
      mySaveCommand[4] = QString("/tmp/") + listBox->currentText() + QString(".desc");
      
      arguments.clear();
      arguments = myLoadCommand;
      
#ifdef DEBUG
      logConsole->writeStdErr(QString("linboInfoBrowserImpl: myLoadCommand"));
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
	  progwindow->progressBar->setValue(i);
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
	Q3TextStream ts( file );
	infoEditor->setText( ts.read() );
	file->close();
      }
    } 
  }
}

void linboImageSelectorImpl::setLoadCommand( const QStringList& newLoadCommand ) {
  myLoadCommand = newLoadCommand;
}

void linboImageSelectorImpl::setSaveCommand( const QStringList& newSaveCommand ) {
  mySaveCommand = newSaveCommand;
}

void linboImageSelectorImpl::setBaseImage( const QString& newBase ) {
  baseImage = newBase;
}

void linboImageSelectorImpl::postcmd2() {
  upload=true;
  this->postcmd();
}

void linboImageSelectorImpl::postcmd() {
  this->hide();

  QString selection, imageName;

  selection = listBox->currentText();

  linbopushbutton* neighbour = (static_cast<linbopushbutton*>(myParent))->getNeighbour();

  neighbourDialog = 0;
  neighbourDialog = neighbour->getLinboDialog();

  if( selection != "[Neuer Dateiname]"  ) {
    // user choosed to rebuild an existing image

    myCommand[3] = selection;
    myCommand[4] = baseImage;

    if( ! (infoEditor->text()).isEmpty() )
      info = infoEditor->text();
    else
      info = QString("Beschreibung");

    // set image name to selected item
    imageName = selection;

  } else {
    // user choosed to build a new image
    if( ! (infoEditor->text()).isEmpty() )
      info = infoEditor->text();
    else
      info = QString("Informationen zu" + specialName->text() +":" ); 

    imageName = specialName->text();

    if( !imageName.isEmpty() ) {
      if( incrRadioButton->isChecked() ) {
        if( ! imageName.contains(".rsync") ) {
          imageName += QString(".rsync");
        }
        myCommand[3] = imageName;
        myCommand[4] = baseImage;
        listBox->insertItem( imageName, (listBox->count() - 1) );
      } else {
        if( ! imageName.contains(".cloop") ) {
          imageName += QString(".cloop");
        }
        myCommand[3] = imageName;
        myCommand[4] = imageName; // will be ignored
        listBox->insertItem( imageName, (listBox->count() - 1) );
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
      if( ! (static_cast<linboImageUploadImpl*>(neighbourDialog))->listBox->findItem( imageName ) ) {
        (static_cast<linboImageUploadImpl*>(neighbourDialog))->listBox->insertItem( imageName );
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
   
    progwindow->setActiveWindow();
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
        progwindow->progressBar->setValue(i);
        progwindow->update();
        
        qApp->processEvents();
      } 
    }
  }
  app->restoreButtonsState();

  if( upload ) {
    if( neighbourDialog != 0 ) {
      (static_cast<linboImageUploadImpl*>(neighbourDialog))->listBox->setSelected( (static_cast<linboImageUploadImpl*>(neighbourDialog))->listBox->findItem( imageName ), true );
      neighbourDialog->postcmd();
    }
    else {
      logConsole->writeStdErr( QString("Eintrag nicht gefunden") );
    }
  } else {
    logConsole->writeStdErr( QString("Upload nicht ausgewählt") );
  }
  upload = false;

  if ( this->checkShutdown->isChecked() ) {
    system("busybox poweroff");
  } else if ( this->checkReboot->isChecked() ) {
    system("busybox reboot");
  }
  this->close(); 
}

void linboImageSelectorImpl::setCommand(const QStringList& arglist)
{
  myCommand = arglist; 
}

void linboImageSelectorImpl::setCache(const QString& newCache)
{
  myCache = newCache; 
}

QStringList linboImageSelectorImpl::getCommand()
{
  return arguments; 
}

void linboImageSelectorImpl::writeInfo() {
  file = new QFile( mySaveCommand[4] );
  if ( !file->open( QIODevice::WriteOnly ) ) {
    logConsole->writeStdErr( QString("Fehler beim Speichern der Beschreibung.") );
  } else {
    Q3TextStream ts( file );
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
      progwindow->progressBar->setValue(i);
      progwindow->update();
      
      qApp->processEvents();
    }
  }  
}



void linboImageSelectorImpl::readFromStdout()
{
  logConsole->writeStdOut( process->readAllStandardOutput() );
}

void linboImageSelectorImpl::readFromStderr()
{
  logConsole->writeStdErr( process->readAllStandardError() );
}

void linboImageSelectorImpl::processFinished( int retval,
					      QProcess::ExitStatus status) {

  logConsole->writeResult( retval, status, process->error() );

  app->restoreButtonsState();

  if( progwindow ) {
    progwindow->close();
  }
}
