#ifndef LINBOYESNOIMPL_HH
#define LINBOYESNOIMPL_HH

#include "ui_linboYesNo.h"

#include <qobject.h>
#include <qlabel.h>
#include <qlineedit.h>
#include <qvariant.h>
#include <qwidget.h>
#include <qdialog.h>
#include <qpushbutton.h>
#include <Q3TextEdit>
#include <qstringlist.h>
#include <QProcess>
#include <iostream>
#include "linboGUIImpl.hh"
#include "linboProgressImpl.hh"

#include "linboDialog.hh"
#include "linboLogConsole.hh"

class linboGUIImpl;
class linboLogConsole;
class linboProgressImpl;

class linboYesNoImpl : public QWidget, public Ui::linboYesNo, public linboDialog
{
  Q_OBJECT

private:
  QString line;
  QStringList myCommand, arguments;
  QProcess *process;
  QWidget *myMainApp,*myParent;
  QTextEdit *Console;
  linboGUIImpl* app;
  linboProgressImpl *progwindow;
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
  linboYesNoImpl( QWidget* parent = 0 );
   ~linboYesNoImpl();


  void setTextBrowser( const QString& new_consolefontcolorstdout,
		       const QString& new_consolefontcolorstderr,
		       QTextEdit* newBrowser );
  QStringList getCommand();
  void setCommand(const QStringList& arglist);
  void setMainApp( QWidget* newMainApp );
  

};
#endif
