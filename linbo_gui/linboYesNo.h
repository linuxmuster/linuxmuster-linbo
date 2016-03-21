#ifndef LINBOYESNO_H
#define LINBOYESNO_H

#include <qobject.h>
#include <qlabel.h>
#include <qlineedit.h>
#include <qvariant.h>
#include <qwidget.h>
#include <qdialog.h>
#include <qpushbutton.h>
#include <QTextEdit>
#include <qstringlist.h>
#include <QProcess>
#include <iostream>

#include "linbogui.h"
#include "linboProgress.h"
#include "linboDialog.h"
#include "linboLogConsole.h"

namespace Ui {
    class linboYesNo;
}

class LinboGUI;
class linboLogConsole;
class linboProgress;

class linboYesNo : public QWidget, public linboDialog
{
  Q_OBJECT

private:
  QString line;
  QStringList myCommand, arguments;
  QProcess *process;
  QWidget *myMainApp,*myParent;
  QTextEdit *Console;
  LinboGUI* app;
  linboProgress *progwindow;
  linboLogConsole *logConsole;

public slots:
  virtual void precmd();
  virtual void postcmd();
  void readFromStdout();
  void readFromStderr();
  void processFinished( int retval,
                        QProcess::ExitStatus status );

  
protected slots:
virtual void languageChange() {};
  
public:
  linboYesNo( QWidget* parent = 0 );
   ~linboYesNo();

    void setQuestionText(QString question);
  void setTextBrowser( const QString& new_consolefontcolorstdout,
		       const QString& new_consolefontcolorstderr,
		       QTextEdit* newBrowser );
  QStringList getCommand();
  void setCommand(const QStringList& arglist);
  void setMainApp( QWidget* newMainApp );

private:
 Ui::linboYesNo *ui;

};
#endif
