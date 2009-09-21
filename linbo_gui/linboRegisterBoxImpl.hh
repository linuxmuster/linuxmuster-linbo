#ifndef LINBOREGISTERBOXIMPL_HH
#define LINBOREGISTERBOXIMPL_HH

#include "ui_linboRegisterBox.h"
#include <qobject.h>
#include <qlabel.h>
#include <qvariant.h>
#include <qwidget.h>
#include <qdialog.h>
#include <q3process.h>
#include <qstring.h>
#include <q3textedit.h>
#include <Qt3Support/Q3TextBrowser>

#include "linboDialog.hh"

class linboRegisterBoxImpl : public QWidget, public Ui::linboRegisterBox, public linboDialog
{
  Q_OBJECT

  
private:
  Q3Process* process;
  QStringList myCommand;
  QString line;
  QWidget *myMainApp,*myParent;
  Q3TextBrowser *Console;

public:
  linboRegisterBoxImpl( QWidget* parent = 0 );
   ~linboRegisterBoxImpl();

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
