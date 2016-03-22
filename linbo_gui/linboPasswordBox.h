#ifndef LINBOPASSWORDBOX_H
#define LINBOPASSWORDBOX_H

#include <qobject.h>
#include <qlabel.h>
#include <qlineedit.h>
#include <qvariant.h>
#include <qwidget.h>
#include <qdialog.h>
#include <QProcess>
#include <qstringlist.h>
#include <QTextEdit>
#include <qtimer.h>

#include "linboDialog.h"
#include "linbogui.h"
#include "linboCounter.h"
#include "linboLogConsole.h"

namespace Ui {
    class linboPasswordBox;
}

class LinboGUI;
class linboLogConsole;

class linboPasswordBox : public QWidget, public linboDialog
{
  Q_OBJECT

private:
  QWidget* myMainApp,*myParent;
  LinboGUI* app;
  QStringList myCommand, arguments;
  QProcess* process;
  QString line;
  QTextEdit *Console;
  linboCounter* myCounter;
  QTimer* myTimer;
  int currentTimeout;
  linboLogConsole *logConsole;

public:
  linboPasswordBox( QWidget* parent = 0 );

   ~linboPasswordBox();

  virtual void precmd();
  virtual void setMainApp( QWidget* newMainApp );
  virtual void setCommand(const QStringList& arglist);
  virtual QStringList getCommand();

  void setTextBrowser( const QString& new_consolefontcolorstdout,
		       const QString& new_consolefontcolorstderr,
		       QTextEdit* newBrowser );


public slots:
  virtual void postcmd();
  void readFromStdout();
  void readFromStderr();
  void processTimeout();
  void processFinished( int retval,
                        QProcess::ExitStatus status);

private:
    Ui::linboPasswordBox *ui;

};
#endif
