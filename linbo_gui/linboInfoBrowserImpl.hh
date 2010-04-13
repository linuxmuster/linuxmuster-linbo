#ifndef LINBOINFOBROWSERIMPL_HH
#define LINBOINFOBROWSERIMPL_HH

#include "ui_linboInfoBrowser.h"

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
#include <qfile.h>
#include "linboDialog.hh"
#include "linboGUIImpl.hh"


class linboInfoBrowserImpl : public QWidget, public Ui::linboInfoBrowser, public linboDialog
{
  Q_OBJECT

private:
  QString line;
  QWidget *myMainApp,*myParent;
  linboGUIImpl *app;
  Q3Process* myProcess;
  QStringList myUploadCommand, myLoadCommand, mySaveCommand;
  QString filepath;
  QFile *file;
  Q3TextBrowser *Console;
  

public slots:
  void readFromStdout();
  void readFromStderr();
  virtual void precmd();
  virtual void postcmd();



public:
  linboInfoBrowserImpl( QWidget* parent );

  ~linboInfoBrowserImpl();

  void setTextBrowser( Q3TextBrowser* newBrowser );
  void setMainApp( QWidget* newMainApp );

  void setCommand(const QStringList& );
  void setLoadCommand(const QStringList& );
  void setSaveCommand(const QStringList& );
  void setUploadCommand(const QStringList& );

  QStringList getCommand();

  void setFilePath( const QString& newFilepath );


};
#endif
