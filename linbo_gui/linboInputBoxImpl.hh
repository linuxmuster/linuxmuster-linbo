#ifndef LINBOINPUTBOXIMPL_HH
#define LINBOINPUTBOXIMPL_HH

#include "linboInputBox.hh"
#include <qobject.h>
#include <qlabel.h>
#include <qlineedit.h>
#include <qvariant.h>
#include <qwidget.h>
#include <qdialog.h>
#include <qtextbrowser.h>
#include <qstringlist.h>
#include <qstring.h>
#include <qprocess.h>

#include "linboDialog.hh"


class linboInputBoxImpl : public linboInputBox, public linboDialog
{
  Q_OBJECT

private:
  QString line;
  QStringList myCommand;
  QProcess *process;
  QWidget *myMainApp;
  QTextBrowser *Console;
  

public slots:
  void readFromStdout();
  void readFromStderr();
  virtual void precmd();
  virtual void postcmd();



public:
  linboInputBoxImpl( QWidget* parent = 0,
                     const char* name = 0,
                     bool modal = FALSE,
                     WFlags fl = 0);

  ~linboInputBoxImpl();

  void setTextBrowser( QTextBrowser* newBrowser );
  virtual void setCommand(const QStringList& arglist);
  virtual QStringList getCommand();
  void setMainApp( QWidget* newMainApp );


};
#endif
