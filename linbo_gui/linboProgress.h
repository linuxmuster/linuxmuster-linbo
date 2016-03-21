#ifndef LINBOPROGRESS_H
#define LINBOPROGRESS_H

#include <qobject.h>
#include <qwidget.h>
#include <qdialog.h>
#include <QProcess>
#include <QTimer>
#include <qpushbutton.h>
#include <QTextEdit>

#include "linboLogConsole.h"

namespace Ui {
    class linboProgress;
}

class linboLogConsole;

class linboProgress : public QWidget
{
  Q_OBJECT

private:
  QProcess *myProcess;
  QTextEdit* Console;
  QWidget *myParent;
  QTimer* myTimer;
  int time, minutes,seconds;
  QString minutestr,secondstr;
  linboLogConsole *logConsole;

public:
  linboProgress( QWidget* parent = 0 );

  ~linboProgress();

  void setProcess( QProcess* newProcess );
  void setTextBrowser( const QString& new_consolefontcolorstdout,
		       const QString& new_consolefontcolorstderr,
		       QTextEdit* newBrowser );
    void setProgress(int i);
    void setShowCancelButton(bool show);

public slots:
  void killLinboCmd();
  void startTimer();
  void processTimer();
  void processFinished( int retval,
                        QProcess::ExitStatus status);
private:
  Ui::linboProgress *ui;

};
#endif
