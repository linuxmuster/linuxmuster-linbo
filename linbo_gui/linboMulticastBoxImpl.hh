#ifndef LINBOMULTICASTBOXIMPL_HH
#define LINBOMULTICASTBOXIMPL_HH

#include "linboMulticastBox.hh"
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


class linboMulticastBoxImpl : public linboMulticastBox, public linboDialog
{
  Q_OBJECT

private:
  QString line;
  QStringList myCommand, myRsyncCommand, myMulticastCommand;
  QProcess *process;
  QWidget *myMainApp;
  QTextBrowser *Console;
  

public slots:
  void readFromStdout();
  void readFromStderr();
  virtual void precmd();
  virtual void postcmd();



public:
  linboMulticastBoxImpl( QWidget* parent = 0,
                     const char* name = 0,
                     bool modal = FALSE,
                     WFlags fl = 0);

  ~linboMulticastBoxImpl();

  void setTextBrowser( QTextBrowser* newBrowser );
  virtual void setCommand(const QStringList& arglist);
  virtual QStringList getCommand();
  virtual void setRsyncCommand(const QStringList& arglist);
  virtual void setMulticastCommand(const QStringList& arglist);

  void setMainApp( QWidget* newMainApp );


};
#endif
