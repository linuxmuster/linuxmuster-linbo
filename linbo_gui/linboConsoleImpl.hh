#ifndef LINBOCONSOLEIMPL_HH
#define LINBOCONSOLEIMPL_HH

#include "ui_linboConsole.h"

#include <qobject.h>
#include <qlabel.h>
#include <qvariant.h>
#include <qwidget.h>
#include <qdialog.h>
#include <q3process.h>
#include <qstring.h>
#include <q3textbrowser.h>
#include <q3textedit.h>

#include "linboDialog.hh"

class linboConsoleImpl : public QWidget, public Ui::linboConsole, public linboDialog
{
  Q_OBJECT
  
private:
  Q3Process* process;
  QStringList myCommand;
  QString line;
  QWidget *myMainApp;
  Q3TextBrowser *Console;

public:
  linboConsoleImpl( QWidget* parent = 0 );

  ~linboConsoleImpl();

  void setTextBrowser( Q3TextBrowser* newBrowser );
  virtual void setCommand(const QStringList& arglist);
  virtual QStringList getCommand();
  // not needed here
  virtual void setMainApp( QWidget* newMainApp );
  void execute();

public slots:
  virtual void postcmd();
  virtual void precmd();
  void readFromStderr();
  void readFromStdout();
 
};
#endif
