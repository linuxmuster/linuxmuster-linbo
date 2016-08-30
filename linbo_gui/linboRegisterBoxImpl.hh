#ifndef LINBOREGISTERBOXIMPL_HH
#define LINBOREGISTERBOXIMPL_HH

#include "ui_linboRegisterBox.h"
#include "linboGUIImpl.hh"
#include <qobject.h>
#include <qlabel.h>
#include <qvariant.h>
#include <qwidget.h>
#include <qdialog.h>
#include <QProcess>
#include <qstring.h>
#include <QTextEdit>
#include <Qt3Support/Q3TextBrowser>
#include "linboProgressImpl.hh"
#include "linboDialog.hh"
#include "linboLogConsole.hh"

class linboGUIImpl;

class linboRegisterBoxImpl : public QWidget, public Ui::linboRegisterBox, public linboDialog
{
  Q_OBJECT

  
private:
  QProcess* process;
  QStringList myCommand;
  QStringList myPreCommand;
  linboProgressImpl *progwindow;
  linboGUIImpl *app;
  QString line;
  QWidget *myMainApp,*myParent;
  QTextEdit *Console;
  linboLogConsole *logConsole;

public:
  linboRegisterBoxImpl( QWidget* parent = 0 );
   ~linboRegisterBoxImpl();

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



};
#endif
