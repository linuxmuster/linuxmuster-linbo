#ifndef LINBOYESNOIMPL_HH
#define LINBOYESNOIMPL_HH

#include "linboYesNo.hh"
#include <qobject.h>
#include <qlabel.h>
#include <qlineedit.h>
#include <qvariant.h>
#include <qwidget.h>
#include <qdialog.h>
#include <qpushbutton.h>
#include <qprocess.h>
#include <qtextbrowser.h>
#include <qstringlist.h>
#include <qprocess.h>
#include <iostream>
#include "linboGUIImpl.hh"

#include "linboDialog.hh"


class linboYesNoImpl : public linboYesNo, public linboDialog
{
  Q_OBJECT

private:
  QString line;
  QStringList myCommand;
  QProcess *process;
  QWidget *myMainApp;
  QTextBrowser *Console;

public slots:
  virtual void precmd();
  virtual void postcmd();
  void readFromStdout();
  void readFromStderr();

public:
  linboYesNoImpl( QWidget* parent = 0,
                        const char* name = 0,
                        bool modal = FALSE,
                        WFlags fl = 0);

   ~linboYesNoImpl();


  void setTextBrowser( QTextBrowser* newBrowser );
  QStringList getCommand();
  void setCommand(const QStringList& arglist);
  void setMainApp( QWidget* newMainApp );


};
#endif
