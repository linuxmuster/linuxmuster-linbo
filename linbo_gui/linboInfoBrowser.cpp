#include <unistd.h>
#include <qapplication.h>
#include <QtGui>
#include <qtextstream.h>

#include "linboInfoBrowser.h"
#include "ui_linboInfoBrowser.h"

linboInfoBrowser::linboInfoBrowser(QWidget* parent ) : linboDialog(), ui(new Ui::linboInfoBrowser)
{
   ui->setupUi(this);

   process = new QProcess( this );

   logConsole = new linboLogConsole(0);

   if( parent)
     myParent = parent;

   connect( ui->saveButton, SIGNAL(clicked()), this, SLOT(postcmd()));

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

linboInfoBrowser::~linboInfoBrowser()
{
  delete process;
} 

void linboInfoBrowser::setTextBrowser( const QString& new_consolefontcolorstdout,
					   const QString& new_consolefontcolorstderr,
					   QTextEdit* newBrowser )
{
  logConsole->setLinboLogConsole( new_consolefontcolorstdout,
				  new_consolefontcolorstderr,
				  newBrowser );
}

void linboInfoBrowser::setMainApp( QWidget* newMainApp ) {
  if ( newMainApp ) {
    myMainApp = newMainApp;
  }
}


void linboInfoBrowser::precmd() {
  app = static_cast<LinboGUI*>( myMainApp );
  
  if( app ) {
    if ( app->isRoot() ) {
      ui->saveButton->setText("Speichern");
      ui->saveButton->setEnabled( true );
      ui->editor->setReadOnly( false );
      // connect( this->saveButton, SIGNAL(clicked()), this, SLOT(postcmd()));
    } else {
      ui->saveButton->setText("Schliessen");
      ui->saveButton->setEnabled( true );
      ui->editor->setReadOnly( true );
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
      QTextStream ts( file );
      ui->editor->setText( ts.readAll() );
      file->close();
    }
  }
  
}


void linboInfoBrowser::postcmd() {
  
  if( app ) {
    if ( app->isRoot() ) {

      if ( !file->open( QIODevice::WriteOnly ) ) {
	logConsole->writeStdErr( QString("Fehler beim Speichern der Beschreibung.") );
      } 
      else {
        QTextStream ts( file );
        ts << ui->editor->toPlainText();
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

void linboInfoBrowser::setCommand( const QStringList& newArguments ) {
  myUploadCommand = newArguments;
}

void linboInfoBrowser::setUploadCommand( const QStringList& newUploadCommand ) {
  myUploadCommand = newUploadCommand;
}

void linboInfoBrowser::setLoadCommand( const QStringList& newLoadCommand ) {
  myLoadCommand = newLoadCommand;
}

void linboInfoBrowser::setSaveCommand( const QStringList& newSaveCommand ) {
  mySaveCommand = newSaveCommand;
}

QStringList linboInfoBrowser::getCommand() {
  // not needed here
  return arguments;
}

void linboInfoBrowser::setFilePath( const QString& newFilepath ) {
  filepath = newFilepath;
}

void linboInfoBrowser::readFromStdout()
{
  logConsole->writeStdOut( process->readAllStandardOutput() );
}

void linboInfoBrowser::readFromStderr()
{
  logConsole->writeStdErr( process->readAllStandardError() );
}

void linboInfoBrowser::processFinished( int retval,
					     QProcess::ExitStatus status) {

  logConsole->writeResult( retval, status, process->error() );

  app->restoreButtonsState();
}
