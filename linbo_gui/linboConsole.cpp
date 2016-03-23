#include <qprogressbar.h>
#include <qapplication.h>
#include <QtGui>
#include <QDesktopWidget>
#include <QByteArray>
#include "linboPushButton.h"
#include "linboProgress.h"
#include "linbogui.h"

#include "linboConsole.h"
#include "ui_linboConsole.h"

linboConsole::linboConsole(  QWidget* parent ) : linboDialog(), ui(new Ui::linboConsole)
{
  ui->setupUi(this);

  mysh = new QProcess( this );
  mysh->setReadChannelMode(QProcess::MergedChannels);
  connect (mysh, SIGNAL(readyReadStandardOutput()),
           this, SLOT(showOutput()));

  // new shell handling - use sh in interactive mode 
  mysh->start("sh", QStringList() << "-i");

  if( parent )
    myParent = parent;

  //  connect(input,SIGNAL(returnPressed()),this,SLOT(postcmd()));
  connect(ui->input,SIGNAL(returnPressed()),this,SLOT(execute()));

  Qt::WindowFlags flags;
  flags = Qt::Dialog | Qt::WindowStaysOnTopHint | Qt::WindowTitleHint;
  setWindowFlags( flags );

  logConsole = new linboLogConsole(0);

  QRect qRect(QApplication::desktop()->screenGeometry());
  // open in the upper left of our screen
  int xpos=qRect.width()/2-this->width()/2;
  int ypos=qRect.height()/2-this->height()/2;
  this->move(xpos,ypos);
  this->setFixedSize( this->width(), this->height() );
}

linboConsole::~linboConsole()
{
} 

void linboConsole::showOutput() {
    QByteArray bytes = mysh->readAllStandardOutput();
    QStringList lines = QString::fromUtf8(bytes).split("\n");
    foreach (QString line, lines) {
        ui->output->append(line);
    }
}

void linboConsole::execute() {
    QString cmdStr = ui->input->text() + "\n";
    ui->input->setText("");
    ui->output->append(cmdStr);
    QByteArray bytes = cmdStr.toUtf8(); /* 8-bit Unicode Transformation Format
    */
    mysh->write(bytes); /* Send the data into the stdin stream
    of the bash child process */
}

void linboConsole::setTextBrowser( const QString& new_consolefontcolorstdout,
				       const QString& new_consolefontcolorstderr,
				       QTextEdit* newBrowser )
{
  logConsole->setLinboLogConsole( new_consolefontcolorstdout,
				  new_consolefontcolorstderr,
				  newBrowser );
}

void linboConsole::precmd() {
  // nothing to do
}


void linboConsole::postcmd() {
   // nothing to do
}

void linboConsole::setMainApp( QWidget* newMainApp ) {
  if ( newMainApp ) {
    myMainApp = newMainApp;
  }
}

void linboConsole::setCommand(const QStringList& arglist)
{
  myCommand = QStringList(arglist); // Create local copy
}

QStringList linboConsole::getCommand()
{
  return QStringList(myCommand); 
}


void linboConsole::readFromStdout()
{
  // nothing to do
}

void linboConsole::readFromStderr()
{
  // nothing to do
}

void linboConsole::processFinished( int retval,
					QProcess::ExitStatus status) {
  // nothing to do
  static_cast<LinboGUI*>(myMainApp)->restoreButtonsState();
}
