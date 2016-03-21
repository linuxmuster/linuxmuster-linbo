#ifndef LINBOCOUNTER_H
#define LINBOCOUNTER_H

#include <qobject.h>
#include <qlabel.h>
#include <qvariant.h>
#include <qwidget.h>
#include <qdialog.h>
#include <qprocess.h>
#include <qstring.h>
#include <QTextEdit>
#include <qlcdnumber.h>
#include <qcheckbox.h>
#include "linboDialog.h"

namespace Ui {
    class linboCounter;
}

class linboCounter : public QWidget, public linboDialog
{
  Q_OBJECT

public:
    QLCDNumber *counter;
    QPushButton *logoutButton;
    QCheckBox *timeoutCheck;

private:
  QTextEdit *Console;
  QProcess* myProcess;
  QString line;
  QWidget *myMainApp,*myParent;
  QStringList myCommand;
  void closeEvent(QCloseEvent *event);

public:
  linboCounter( QWidget* parent = 0 );

   ~linboCounter();

  virtual void precmd();
  virtual void postcmd();
  virtual void setCommand(const QStringList& arglist);
  virtual QStringList getCommand();
  // not needed here
  virtual void setMainApp( QWidget* newMainApp );
  void setTextBrowser( QTextEdit* newBrowser );

public slots:
  void readFromStderr();
  void readFromStdout();
  void processFinished( int retval,
                        QProcess::ExitStatus status);

private:
  Ui::linboCounter *ui;

};
#endif
