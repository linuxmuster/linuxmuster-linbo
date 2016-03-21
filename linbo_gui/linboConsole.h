#ifndef LINBOCONSOLE_H
#define LINBOCONSOLE_H

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

#include "linboDialog.h"
#include "linboLogConsole.h"

namespace Ui {
    class linboConsole;
}

class linboConsole : public QWidget, public linboDialog
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
  linboConsole( QWidget* parent = 0 );

  ~linboConsole();

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

private:
  Ui::linboConsole *ui;
};
#endif
