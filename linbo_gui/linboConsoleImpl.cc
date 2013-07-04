#include "linboConsoleImpl.hh"
#include "linboProgressImpl.hh"
#include "linboGUIImpl.hh"
#include <q3progressbar.h>
#include <qapplication.h>
#include <QtGui>
#include <QByteArray>
#include "linboPushButton.hh"


linboConsoleImpl::linboConsoleImpl(  QWidget* parent ) : linboDialog()
{
  Ui_linboConsole::setupUi((QDialog*)this);

  mysh = new QProcess( this );
  mysh->setReadChannelMode(QProcess::MergedChannels);
  connect (mysh, SIGNAL(readyReadStandardOutput()),
           this, SLOT(showOutput()));

  // new shell handling - use sh in interactive mode 
  mysh->start("sh", QStringList() << "-i");

  if( parent )
    myParent = parent;

  //  connect(input,SIGNAL(returnPressed()),this,SLOT(postcmd()));
  connect(input,SIGNAL(returnPressed()),this,SLOT(execute()));

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

linboConsoleImpl::~linboConsoleImpl()
{
} 

void linboConsoleImpl::showOutput() { 
    QByteArray bytes = mysh->readAllStandardOutput();
    QStringList lines = QString::fromUtf8(bytes).split("\n");
    foreach (QString line, lines) {
        output->append(line);
    }
}

void linboConsoleImpl::execute() {
    QString cmdStr = input->text() + "\n";
    input->setText("");
    output->append(cmdStr);
    QByteArray bytes = cmdStr.toUtf8(); /* 8-bit Unicode Transformation Format
    */
    mysh->write(bytes); /* Send the data into the stdin stream
    of the bash child process */
}

void linboConsoleImpl::setTextBrowser( const QString& new_consolefontcolorstdout,
				       const QString& new_consolefontcolorstderr,
				       QTextEdit* newBrowser )
{
  logConsole->setLinboLogConsole( new_consolefontcolorstdout,
				  new_consolefontcolorstderr,
				  newBrowser );
}

void linboConsoleImpl::precmd() {
  // nothing to do
}


void linboConsoleImpl::postcmd() {
   // nothing to do
}

void linboConsoleImpl::setMainApp( QWidget* newMainApp ) {
  if ( newMainApp ) {
    myMainApp = newMainApp;
  }
}

void linboConsoleImpl::setCommand(const QStringList& arglist)
{
  myCommand = QStringList(arglist); // Create local copy
}

QStringList linboConsoleImpl::getCommand()
{
  return QStringList(myCommand); 
}


void linboConsoleImpl::readFromStdout()
{
  // nothing to do
}

void linboConsoleImpl::readFromStderr()
{
  // nothing to do
}

void linboConsoleImpl::processFinished( int retval,
					QProcess::ExitStatus status) {
  // nothing to do
  static_cast<linboGUIImpl*>(myMainApp)->restoreButtonsState();
}
