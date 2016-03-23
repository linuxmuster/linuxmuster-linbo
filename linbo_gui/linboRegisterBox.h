#ifndef LINBOREGISTERBOX_H
#define LINBOREGISTERBOX_H

#include <qobject.h>
#include <qlabel.h>
#include <qvariant.h>
#include <qwidget.h>
#include <qdialog.h>
#include <QProcess>
#include <qstring.h>
#include <QTextEdit>
#include <QTextBrowser>
#include "linbogui.h"
#include "linboProgress.h"
#include "linboDialog.h"
#include "linboLogConsole.h"

namespace Ui {
    class linboRegisterBox;
}

class LinboGUI;

class linboRegisterBox : public QWidget, public linboDialog
{
  Q_OBJECT

  
private:
  QProcess* process;
  QStringList myCommand;
  QStringList myPreCommand;
  linboProgress *progwindow;
  LinboGUI *app;
  QString line;
  QWidget *myMainApp,*myParent;
  QTextEdit *Console;
  linboLogConsole *logConsole;

public:
  linboRegisterBox( QWidget* parent = 0 );
   ~linboRegisterBox();

  void setTextBrowser( const QString& new_consolefontcolorstdout,
		       const QString& new_consolefontcolorstderr,
		       QTextEdit* newBrowser );
  virtual void setCommand(const QStringList& arglist);
  virtual QStringList getPreCommand();
  virtual void setPreCommand(const QStringList& arglist);
  virtual QStringList getCommand();
  // not needed here
  virtual void setMainApp( QWidget* newMainApp );
  void execute();

public slots:
  virtual void postcmd();
  virtual void precmd();
  void readFromStderr();
  void readFromStdout();
  void processFinished( int retval,
                        QProcess::ExitStatus status );

private:
    Ui::linboRegisterBox *ui;
};
#endif
