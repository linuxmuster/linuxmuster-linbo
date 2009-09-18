#ifndef LINBOMULTICASTBOXIMPL_HH
#define LINBOMULTICASTBOXIMPL_HH

#include "ui_linboMulticastBox.h"

#include <qobject.h>
#include <qlabel.h>
#include <qlineedit.h>
#include <qvariant.h>
#include <qwidget.h>
#include <qdialog.h>
#include <q3textbrowser.h>
#include <qstringlist.h>
#include <qstring.h>
#include <q3process.h>

#include "linboDialog.hh"

using namespace Ui;
class linboGUIImpl;

class linboMulticastBoxImpl : public QWidget, public Ui::linboMulticastBox, public linboDialog
{
  Q_OBJECT

private:
  QString line;
  QStringList myCommand, myRsyncCommand, myMulticastCommand, myBittorrentCommand;
  Q3Process *process;
  QWidget *myMainApp;
  Q3TextBrowser *Console;
  

public slots:
  void readFromStdout();
  void readFromStderr();
  virtual void precmd();
  virtual void postcmd();



public:
  linboMulticastBoxImpl( QWidget* parent = 0 );

  ~linboMulticastBoxImpl();

  void setTextBrowser( Q3TextBrowser* newBrowser );
  virtual void setCommand(const QStringList& arglist);
  virtual QStringList getCommand();
  virtual void setRsyncCommand(const QStringList& arglist);
  virtual void setMulticastCommand(const QStringList& arglist);
  virtual void setBittorrentCommand(const QStringList& arglist);

  void setMainApp( QWidget* newMainApp );


};
#endif
