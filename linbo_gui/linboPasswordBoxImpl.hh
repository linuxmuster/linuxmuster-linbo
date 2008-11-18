#ifndef LINBOPASSWORDBOXIMPL_HH
#define LINBOPASSWORDBOXIMPL_HH

#include "linboPasswordBox.hh"
#include <qobject.h>
#include <qlabel.h>
#include <qlineedit.h>
#include <qvariant.h>
#include <qwidget.h>
#include <qdialog.h>
#include "linboDialog.hh"
#include "linboGUIImpl.hh"
#include "linboGUI.hh"
#include <qstringlist.h>
#include <qtextbrowser.h>
#include <qtimer.h>
#include "linboCounter.hh"
#include "linboGUIImpl.hh"

class linboGUIImpl;

class linboPasswordBoxImpl : public linboPasswordBox, public linboDialog
{
  Q_OBJECT

private:
  QWidget* myMainApp;
  linboGUIImpl* app;
  QStringList myCommand;
  QProcess* process;
  QString line;
  QTextBrowser *Console;
  linboCounter* myCounter;
  QTimer* myTimer;
  int currentTimeout;

public:
  linboPasswordBoxImpl( QWidget* parent = 0,
                        const char* name = 0,
                        bool modal = FALSE,
                        WFlags fl = 0);

   ~linboPasswordBoxImpl();

  virtual void precmd();
  void setMainApp( QWidget* newMainApp );
  virtual void setCommand(const QStringList& arglist);
  virtual QStringList getCommand();

  void setTextBrowser( QTextBrowser* newBrowser );


public slots:
  virtual void postcmd();
  void readFromStdout();
  void readFromStderr();
  void processTimeout();


};
#endif
