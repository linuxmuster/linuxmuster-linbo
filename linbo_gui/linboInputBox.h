#ifndef LINBOINPUTBOX_H
#define LINBOINPUTBOX_H

#include <qobject.h>
#include <qlabel.h>
#include <qlineedit.h>
#include <qvariant.h>
#include <qwidget.h>
#include <qdialog.h>
#include <QTextEdit>
#include <qstringlist.h>
#include <qstring.h>
#include <QProcess>
#include "linbogui.h"
#include "linboProgress.h"
#include "linboDialog.h"
#include "linboLogConsole.h"

namespace Ui {
    class linboInputBox;
}

class LinboGUI;

class linboInputBox : public QWidget, public linboDialog
{
  Q_OBJECT

private:
  QString line;
  QStringList myCommand;
  QStringList arguments;
  linboProgress *progwindow;
  QProcess *process;
  LinboGUI* app;
  QWidget *myMainApp,*myParent;
  QTextEdit *Console;
  linboLogConsole *logConsole;

public slots:
  void readFromStdout();
  void readFromStderr();
  void processFinished( int retval,
                        QProcess::ExitStatus status);
  virtual void precmd();
  virtual void postcmd();



public:
  linboInputBox( QWidget* parent = 0);
  ~linboInputBox();

  void setTextBrowser( const QString& new_consolefontcolorstdout,
		       const QString& new_consolefontcolorstderr,
		       QTextEdit* newBrowser );
  virtual void setCommand(const QStringList& arglist);
  virtual QStringList getCommand();
  void setMainApp( QWidget* newMainApp );
  
private:
  Ui::linboInputBox *ui;

};
#endif
