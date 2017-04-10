#ifndef LINBOPASSWORDBOXIMPL_HH
#define LINBOPASSWORDBOXIMPL_HH

#include "ui_linboPasswordBox.h"

#include <qobject.h>
#include <qlabel.h>
#include <qlineedit.h>
#include <qvariant.h>
#include <qwidget.h>
#include <qdialog.h>
#include "linboDialog.hh"
#include "linboGUIImpl.hh"
#include "ui_linboGUI.h"
#include <QProcess>
#include <qstringlist.h>
#include <QTextEdit>
#include <qtimer.h>
#include "linboCounterImpl.hh"
#include "linboLogConsole.hh"

using namespace Ui;
class linboGUIImpl;
class linboLogConsole;

class linboPasswordBoxImpl : public QWidget, public Ui::linboPasswordBox, public linboDialog
{
  Q_OBJECT

private:
  QWidget* myMainApp,*myParent;
  linboGUIImpl* app;
  QStringList myCommand, arguments;
  QProcess* process;
  QString line;
  QTextEdit *Console;
  linboCounterImpl* myCounter;
  QTimer* myTimer;
  int currentTimeout;
  linboLogConsole *logConsole;

public:
  linboPasswordBoxImpl( QDialog* parent = 0 );

   ~linboPasswordBoxImpl();

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



};
#endif
