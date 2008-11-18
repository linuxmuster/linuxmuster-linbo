#include "linboImageSelectorImpl.hh"
#include "linboProgressImpl.hh"
#include "linboGUIImpl.hh"
#include <qprogressbar.h>
#include <qapplication.h>
#include <qbuttongroup.h>
#include <qlistbox.h>
#include <qradiobutton.h>
#include "linboImageUploadImpl.hh"
#include "linboPushButton.hh"

linboImageSelectorImpl::linboImageSelectorImpl(  QWidget* parent,
                                       const char* name,
                                       bool modal,
                                       WFlags fl ) : linboImageSelector( parent,
                                                                    name ), 
                                                     linboDialog()
{
  process = new QProcess( this );

  connect( cancelButton, SIGNAL(pressed()), this, SLOT(close()) );
  connect( createButton, SIGNAL(pressed()), this, SLOT(postcmd()) );
  connect( createUploadButton, SIGNAL(pressed()), this, SLOT(postcmd2()) );
  connect( listBox, SIGNAL(selectionChanged()), this, SLOT(selectionWatcher()) );
  

  // connect stdout and stderr to linbo console
  connect( process, SIGNAL(readyReadStdout()),
           this, SLOT(readFromStdout()) );

  connect( process, SIGNAL(readyReadStderr()),
           this, SLOT(readFromStderr()) );

  specialName->setEnabled( false );
  imageButtons->setEnabled( false );

  upload=false;
  neighbourDialog = 0;
}

linboImageSelectorImpl::~linboImageSelectorImpl()
{
} 

void linboImageSelectorImpl::setTextBrowser( QTextBrowser* newBrowser )
{
  Console = newBrowser;
}

void linboImageSelectorImpl::setMainApp( QWidget* newMainApp ) {
  myMainApp = newMainApp;
}


void linboImageSelectorImpl::precmd() {
  // nothing to do
}

void linboImageSelectorImpl::selectionWatcher() {
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

    process->clearArguments();
    process->setArguments( myLoadCommand );
    
#ifdef DEBUG
    Console->append(QString("linboInfoBrowserImpl: myLoadCommand"));
    QStringList list = myProcess->arguments();
    QStringList::Iterator it = list.begin();
    while( it != list.end() ) {
      Console->append( *it );
    ++it;
    }
    Console->append(QString("*****"));
#endif
    
    if( process->start() ) {
      while( process->isRunning() ) {
        usleep( 1000 );
      }
    } else {
      Console->append("myLoadCommand didn't start");
    }

    file = new QFile( myLoadCommand[4] );
    // read content
    if( !file->open( IO_ReadOnly ) ) {
      Console->append("Keine passende Beschreibung im Cache.");
    } 
    else {
      QTextStream ts( file );
      infoEditor->setText( ts.read() );
      file->close();
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
  linboGUIImpl* app = static_cast<linboGUIImpl*>( myMainApp );

  QString selection, imageName;
  
  selection = listBox->currentText();

  linbopushbutton* neighbour = (static_cast<linbopushbutton*>(this->parentWidget()))->getNeighbour();

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
    linboProgressImpl *progwindow = new linboProgressImpl(0,"Arbeite...",0, Qt::WStyle_Tool );
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
  if( upload ) {
    if( neighbourDialog != 0 ) {
      (static_cast<linboImageUploadImpl*>(neighbourDialog))->listBox->setSelected( (static_cast<linboImageUploadImpl*>(neighbourDialog))->listBox->findItem( imageName ), true );
      neighbourDialog->postcmd();
    }
    else {
      Console->append( QString("Eintrag nicht gefunden") );
    }
  } else {
    Console->append( QString("Upload nicht ausgewählt") );
  }
  upload = false;
  this->close(); 
}

void linboImageSelectorImpl::setCommand(const QStringList& arglist)
{
  myCommand = QStringList(arglist); 
}

void linboImageSelectorImpl::setCache(const QString& newCache)
{
  myCache = newCache; 
}

QStringList linboImageSelectorImpl::getCommand()
{
  return QStringList(myCommand); 
}

void linboImageSelectorImpl::writeInfo() {
  file = new QFile( mySaveCommand[4] );
  if ( !file->open( IO_WriteOnly ) ) {
    Console->append("Fehler beim Speichern der Beschreibung.");
  } else {
    QTextStream ts( file );
    ts << info;
    file->flush();
    file->close();
  } 

  process->clearArguments();
  process->setArguments( mySaveCommand );

#ifdef DEBUG
  Console->append(QString("Save Command="));
  QStringList list = process->arguments();
  QStringList::Iterator it = list.begin();
  while( it != list.end() ) {
    Console->append( *it );
    ++it;
  }
#endif

  if( process->start() ) {
  while( process->isRunning() ) {
      usleep( 1000 );
    }
  } else {
    Console->append("mySaveCommand didn't start");
  }


}



void linboImageSelectorImpl::readFromStdout()
{
  while( process->canReadLineStdout() )
    {
      line = process->readLineStdout();
      Console->append( line );
    } 
}

void linboImageSelectorImpl::readFromStderr()
{
  while( process->canReadLineStderr() )
    {
      line = process->readLineStderr();
      line.prepend( "<FONT COLOR=red>" );
      line.append( "</FONT>" );
      Console->append( line );
    } 
}
