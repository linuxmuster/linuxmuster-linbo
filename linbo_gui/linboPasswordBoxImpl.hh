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
#include <qstringlist.h>
#include <q3textbrowser.h>
#include <qtimer.h>
#include "linboCounterImpl.hh"

using namespace Ui;
class linboGUIImpl;

class linboPasswordBoxImpl : public QWidget, public Ui::linboPasswordBox, public linboDialog
{
  Q_OBJECT

private:
  QWidget* myMainApp,*myParent;
  linboGUIImpl* app;
  QStringList myCommand;
  Q3Process* process;
  QString line;
  Q3TextBrowser *Console;
  linboCounterImpl* myCounter;
  QTimer* myTimer;
  int currentTimeout;

public:
  linboPasswordBoxImpl( QDialog* parent = 0 );

   ~linboPasswordBoxImpl();

  virtual void precmd();
  virtual void setMainApp( QWidget* newMainApp );
  virtual void setCommand(const QStringList& arglist);
  virtual QStringList getCommand();

  void setTextBrowser( Q3TextBrowser* newBrowser );


public slots:
  virtual void postcmd();
  void readFromStdout();
  void readFromStderr();
  void processTimeout();


};
#endif
