#ifndef LINBOREGISTERBOXIMPL_HH
#define LINBOREGISTERBOXIMPL_HH

#include "linboRegisterBox.hh"
#include <qobject.h>
#include <qlabel.h>
#include <qvariant.h>
#include <qwidget.h>
#include <qdialog.h>
#include <qprocess.h>
#include <qstring.h>
#include <qtextedit.h>

#include "linboDialog.hh"

class linboRegisterBoxImpl : public linboRegisterBox, public linboDialog
{
  Q_OBJECT

  
private:
  QProcess* process;
  QStringList myCommand;
  QString line;
  QWidget *myMainApp;
  QTextBrowser *Console;

public:
  linboRegisterBoxImpl( QWidget* parent = 0,
                const char* name = 0,
                bool modal = FALSE,
                WFlags fl = 0);

   ~linboRegisterBoxImpl();

  void setTextBrowser( QTextBrowser* newBrowser );
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
