#include "linboInfoBrowserImpl.hh"
#include <unistd.h>
#include <qapplication.h>
#include <QtGui>
#include <q3textstream.h>

linboInfoBrowserImpl::linboInfoBrowserImpl(QWidget* parent ) : linboDialog()
{
   Ui_linboInfoBrowser::setupUi((QDialog*)this);

   process = new QProcess( this );

   logConsole = new linboLogConsole(0);

   if( parent)
     myParent = parent;

   connect( this->saveButton, SIGNAL(clicked()), this, SLOT(postcmd()));

   // connect SLOT for finished process
   connect( process, SIGNAL(finished(int, QProcess::ExitStatus) ),
	    this, SLOT(processFinished(int, QProcess::ExitStatus)) );

   // connect stdout and stderr to linbo console
   connect( process, SIGNAL(readyReadStandardOutput()),
	    this, SLOT(readFromStdout()) );
   
   connect( process, SIGNAL(readyReadStandardError()),
	    this, SLOT(readFromStderr()) );
   
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

linboInfoBrowserImpl::~linboInfoBrowserImpl()
{
  delete process;
} 

void linboInfoBrowserImpl::setTextBrowser( const QString& new_consolefontcolorstdout,
					   const QString& new_consolefontcolorstderr,
					   QTextEdit* newBrowser )
{
  logConsole->setLinboLogConsole( new_consolefontcolorstdout,
				  new_consolefontcolorstderr,
				  newBrowser );
}

void linboInfoBrowserImpl::setMainApp( QWidget* newMainApp ) {
  if ( newMainApp ) {
    myMainApp = newMainApp;
  }
}


void linboInfoBrowserImpl::precmd() {
  app = static_cast<linboGUIImpl*>( myMainApp );
  
  if( app ) {
    if ( app->isRoot() ) {
      saveButton->setText("Speichern");
      saveButton->setEnabled( true );
      editor->setReadOnly( false );
      // connect( this->saveButton, SIGNAL(clicked()), this, SLOT(postcmd()));
    } else {
      saveButton->setText("Schliessen");
      saveButton->setEnabled( true );
      editor->setReadOnly( true );
      // connect( this->saveButton, SIGNAL(clicked()), this, SLOT(close()));
    }

    arguments.clear();
    arguments = myLoadCommand;

    QStringList processargs( arguments );
    QString command = processargs.takeFirst();

    process->start( command, processargs );

    while( process->state() == QProcess::Running ) {
      usleep( 1000 );
    }

    file = new QFile( filepath );
    // read content
    if( !file->open( QIODevice::ReadOnly ) ) {
      logConsole->writeStdErr( QString("Keine passende Beschreibung im Cache.") );
    } 
    else {
      Q3TextStream ts( file );
      editor->setText( ts.read() );
      file->close();
    }
  }
  
}


void linboInfoBrowserImpl::postcmd() {
  
  if( app ) {
    if ( app->isRoot() ) {

      if ( !file->open( QIODevice::WriteOnly ) ) {
	logConsole->writeStdErr( QString("Fehler beim Speichern der Beschreibung.") );
      } 
      else {
        Q3TextStream ts( file );
        ts << editor->text();
        file->flush();
        file->close();

	arguments.clear();
        arguments = mySaveCommand; 

	QStringList processargs( arguments );
	QString command = processargs.takeFirst();

	process->start( command, processargs );

	while( process->state() == QProcess::Running ) {
	  usleep( 1000 );
	}
      
	arguments.clear();
        arguments = myUploadCommand;

	processargs.clear();
	processargs = arguments;
	command = processargs.takeFirst();

	process->start( command, processargs );

	while( process->state() == QProcess::Running ) {
	  usleep( 1000 );
	}


      }
    }
    this->close();
  }
  
}

void linboInfoBrowserImpl::setCommand( const QStringList& newArguments ) {
  myUploadCommand = newArguments;
}

void linboInfoBrowserImpl::setUploadCommand( const QStringList& newUploadCommand ) {
  myUploadCommand = newUploadCommand;
}

void linboInfoBrowserImpl::setLoadCommand( const QStringList& newLoadCommand ) {
  myLoadCommand = newLoadCommand;
}

void linboInfoBrowserImpl::setSaveCommand( const QStringList& newSaveCommand ) {
  mySaveCommand = newSaveCommand;
}

QStringList linboInfoBrowserImpl::getCommand() {
  // not needed here
  return arguments;
}

void linboInfoBrowserImpl::setFilePath( const QString& newFilepath ) {
  filepath = newFilepath;
}

void linboInfoBrowserImpl::readFromStdout()
{
  logConsole->writeStdOut( process->readAllStandardOutput() );
}

void linboInfoBrowserImpl::readFromStderr()
{
  logConsole->writeStdErr( process->readAllStandardError() );
}

void linboInfoBrowserImpl::processFinished( int retval,
					     QProcess::ExitStatus status) {

  logConsole->writeResult( retval, status, process->error() );

  app->restoreButtonsState();
}
