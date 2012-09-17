#ifndef LINBOPROGRESSIMPL_HH
#define LINBOPROGRESSIMPL_HH

#include "ui_linboProgress.h"

// #include "linboProgress.hh"
#include <qobject.h>
#include <qwidget.h>
#include <qdialog.h>
#include <QProcess>
#include <QTimer>
#include <qpushbutton.h>
#include <QTextEdit>
#include "linboLogConsole.hh"

class linboLogConsole;

class linboProgressImpl : public QWidget, public Ui::linboProgress
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
  linboProgressImpl( QWidget* parent = 0 );

  ~linboProgressImpl();

  void setProcess( QProcess* newProcess );
  void setTextBrowser( const QString& new_consolefontcolorstdout,
		       const QString& new_consolefontcolorstderr,
		       QTextEdit* newBrowser );

public slots:
  void killLinboCmd();
  void startTimer();
  void processTimer();
  void processFinished( int retval,
                        QProcess::ExitStatus status);

};
#endif
