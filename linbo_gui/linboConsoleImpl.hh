#ifndef LINBOCONSOLEIMPL_HH
#define LINBOCONSOLEIMPL_HH

#include "ui_linboConsole.h"

#include <qobject.h>
#include <qlabel.h>
#include <qvariant.h>
#include <qwidget.h>
#include <qdialog.h>
#include <QProcess>
#include <qstring.h>
#include <QTextEdit>
#include <QTextBrowser>
#include <qlineedit.h>

#include "linboDialog.hh"
#include "linboLogConsole.hh"

using namespace Ui;

class linboConsoleImpl : public QWidget, public Ui::linboConsole, public linboDialog
{
  Q_OBJECT
  
private:
  QProcess* mysh;
  QStringList myCommand;
  QString line;
  QWidget *myMainApp, *myParent;
  QTextEdit *Console;
  linboLogConsole* logConsole;

public:
  linboConsoleImpl( QWidget* parent = 0 );

  ~linboConsoleImpl();

  void setTextBrowser( const QString& new_consolefontcolorstdout,
		       const QString& new_consolefontcolorstderr,
		       QTextEdit* newBrowser );
  virtual void setCommand(const QStringList& arglist);
  virtual QStringList getCommand();
  virtual void setMainApp( QWidget* newMainApp );


public slots:
  virtual void postcmd();
  virtual void precmd();
  void readFromStderr();
  void readFromStdout();
  void processFinished( int retval,
			QProcess::ExitStatus status);
  void showOutput();
  void execute();
};
#endif
