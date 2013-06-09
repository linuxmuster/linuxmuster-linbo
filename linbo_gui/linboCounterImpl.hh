#ifndef LINBOCOUNTERIMPL_HH
#define LINBOCOUNTERIMPL_HH

#include "ui_linboCounter.h"
#include <qobject.h>
#include <qlabel.h>
#include <qvariant.h>
#include <qwidget.h>
#include <qdialog.h>
#include <q3process.h>
#include <qstring.h>
#include <QTextEdit>
#include "linboDialog.hh"


class linboCounterImpl : public QWidget, public Ui::linboCounter, public linboDialog
{
  Q_OBJECT

  
private:
  QTextEdit *Console;
  Q3Process* myProcess;
  QString line;
  QWidget *myMainApp,*myParent;
  QStringList myCommand;
  void closeEvent(QCloseEvent *event);

public:
  linboCounterImpl( QWidget* parent = 0 );

   ~linboCounterImpl();

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


};
#endif
