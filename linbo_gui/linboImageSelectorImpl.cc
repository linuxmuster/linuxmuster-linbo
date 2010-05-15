#include "linboImageSelectorImpl.hh"
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
  flags = Qt::Dialog | Qt::WindowStaysOnTopHint;
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

void linboImageSelectorImpl::setTextBrowser( QTextEdit* newBrowser )
{
  Console = newBrowser;
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
      Console->insert(QString("linboInfoBrowserImpl: myLoadCommand"));
      QStringList list = arguments();
      QStringList::Iterator it = list.begin();
      while( it != list.end() ) {
	Console->insert( *it );
	++it;
      }
      Console->insert(QString("*****"));
#endif
      
      QStringList processargs( arguments );
      QString command = processargs.takeFirst();
      
      progwindow->startTimer();
      process->start( command, processargs );
      
      Console->setColor( QColor( QString("red") ) );
      Console->insert( QString("Executing ") + command + processargs.join(" ") );
      Console->insert(QString(QChar::LineSeparator));  
      Console->moveCursor(QTextCursor::End);
      Console->ensureCursorVisible(); 
      Console->setColor( QColor( QString("white") ) );

      
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
	Console->setColor( QColor( QString("red") ) );
	Console->insert("Keine passende Beschreibung im Cache.");
	Console->insert(QString(QChar::LineSeparator));
	Console->moveCursor(QTextCursor::End);
	Console->ensureCursorVisible(); 
	Console->setColor( QColor( QString("white") ) );
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

    Console->setColor( QColor( QString("red") ) );
    Console->insert( QString("Executing ") + command + processargs.join(" ") );
    Console->insert(QString(QChar::LineSeparator));
    Console->moveCursor(QTextCursor::End);
    Console->ensureCursorVisible(); 
    Console->setColor( QColor( QString("white") ) );


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
      Console->setColor( QColor( QString("red") ) );
      Console->insert( QString("Eintrag nicht gefunden") );
      Console->insert(QString(QChar::LineSeparator));
      Console->moveCursor(QTextCursor::End);
      Console->ensureCursorVisible(); 
      Console->setColor( QColor( QString("white") ) );
    }
  } else {
    Console->setColor( QColor( QString("red") ) );
    Console->insert( QString("Upload nicht ausgewählt") );
    Console->insert(QString(QChar::LineSeparator));
    Console->moveCursor(QTextCursor::End);
    Console->ensureCursorVisible(); 
    Console->setColor( QColor( QString("white") ) );
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
    Console->setColor( QColor( QString("red") ) );
    Console->insert("Fehler beim Speichern der Beschreibung.");
    Console->insert(QString(QChar::LineSeparator));  
    Console->moveCursor(QTextCursor::End);
    Console->ensureCursorVisible(); 
    Console->setColor( QColor( QString("white") ) );

  } else {
    Q3TextStream ts( file );
    ts << info;
    file->flush();
    file->close();
  } 

  arguments.clear();
  arguments = mySaveCommand;

#ifdef DEBUG
  Console->insert(QString("Save Command="));
  QStringList list = process->arguments();
  QStringList::Iterator it = list.begin();
  while( it != list.end() ) {
    Console->insert( *it );
    ++it;
  }
#endif

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
  Console->setColor( QColor( QString("white") ) );
  Console->insert( process->readAllStandardOutput() );
  Console->moveCursor(QTextCursor::End);
  Console->ensureCursorVisible(); 
}

void linboImageSelectorImpl::readFromStderr()
{
  Console->setColor( QColor( QString("red") ) );
  Console->insert( process->readAllStandardError() );
  Console->setColor( QColor( QString("white") ) );
  Console->moveCursor(QTextCursor::End);
  Console->ensureCursorVisible(); 

}

void linboImageSelectorImpl::processFinished( int retval,
					      QProcess::ExitStatus status) {

  Console->setColor( QColor( QString("red") ) );
  Console->insert( QString("Command executed with exit value ") + QString::number( retval ) );

  if( status == 0)
    Console->insert( QString("Exit status: ") + QString("The process exited normally.") );
  else
    Console->insert( QString("Exit status: ") + QString("The process crashed.") );

  if( status == 1 ) {
    int errorstatus = process->error();
    switch ( errorstatus ) {
      case 0: Console->insert( QString("The process failed to start. Either the invoked program is missing, or you may have insufficient permissions to invoke the program.") ); break;
      case 1: Console->insert( QString("The process crashed some time after starting successfully.") ); break;
      case 2: Console->insert( QString("The last waitFor...() function timed out.") ); break;
      case 3: Console->insert( QString("An error occurred when attempting to write to the process. For example, the process may not be running, or it may have closed its input channel.") ); break;
      case 4: Console->insert( QString("An error occurred when attempting to read from the process. For example, the process may not be running.") ); break;
      case 5: Console->insert( QString("An unknown error occurred.") ); break;
    }

  }

  Console->insert(QString(QChar::LineSeparator));  

  Console->setColor( QColor( QString("white") ) );
  Console->moveCursor(QTextCursor::End);
  Console->ensureCursorVisible(); 
			   

  app->restoreButtonsState();

  if( progwindow ) {
    progwindow->close();
  }
}
