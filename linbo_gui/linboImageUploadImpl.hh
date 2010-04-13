#ifndef LINBOIMAGEUPLOADIMPL_HH
#define LINBOIMAGEUPLOADIMPL_HH

#include "ui_linboImageUpload.h"
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


class linboImageUploadImpl : public QWidget, public Ui::linboImageUpload, public linboDialog
{
  Q_OBJECT

private:
  QString line;
  QStringList myCommand;
  Q3Process *process;
  QWidget *myMainApp,*myParent;
  Q3TextBrowser *Console;
  

public slots:
  void readFromStdout();
  void readFromStderr();
  virtual void precmd();
  virtual void postcmd();



public:
  linboImageUploadImpl( QWidget* parent = 0);

  ~linboImageUploadImpl();

  void setTextBrowser( Q3TextBrowser* newBrowser );
  virtual void setCommand(const QStringList& arglist);
  virtual QStringList getCommand();
  virtual void setMainApp( QWidget* newMainApp );


};
#endif
