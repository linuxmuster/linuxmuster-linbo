#ifndef LINBOIMAGEUPLOADIMPL_HH
#define LINBOIMAGEUPLOADIMPL_HH

#include "linboImageUpload.hh"
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


class linboImageUploadImpl : public linboImageUpload, public linboDialog
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
  linboImageUploadImpl( QWidget* parent = 0,
                     const char* name = 0,
                     bool modal = FALSE,
                     WFlags fl = 0);

  ~linboImageUploadImpl();

  void setTextBrowser( QTextBrowser* newBrowser );
  virtual void setCommand(const QStringList& arglist);
  virtual QStringList getCommand();
  void setMainApp( QWidget* newMainApp );


};
#endif
