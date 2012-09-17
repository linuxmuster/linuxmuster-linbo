#ifndef LINBOINPUTBOXIMPL_HH
#define LINBOINPUTBOXIMPL_HH

#include "ui_linboInputBox.h"

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
#include "linboGUIImpl.hh"
#include "linboProgressImpl.hh"
#include "linboDialog.hh"
#include "linboLogConsole.hh"

class linboInputBoxImpl : public QWidget, public Ui::linboInputBox, public linboDialog
{
  Q_OBJECT

private:
  QString line;
  QStringList myCommand;
  QStringList arguments;
  linboProgressImpl *progwindow;
  QProcess *process;
  linboGUIImpl* app;
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
  linboInputBoxImpl( QWidget* parent = 0);
  ~linboInputBoxImpl();

  void setTextBrowser( const QString& new_consolefontcolorstdout,
		       const QString& new_consolefontcolorstderr,
		       QTextEdit* newBrowser );
  virtual void setCommand(const QStringList& arglist);
  virtual QStringList getCommand();
  void setMainApp( QWidget* newMainApp );
  

};
#endif
