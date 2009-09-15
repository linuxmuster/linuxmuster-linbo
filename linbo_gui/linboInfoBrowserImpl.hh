#ifndef LINBOINFOBROWSERIMPL_HH
#define LINBOINFOBROWSERIMPL_HH

#include "linboInfoBrowser.hh"
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
#include <qfile.h>
#include "linboDialog.hh"
#include "linboGUIImpl.hh"


class linboInfoBrowserImpl : public linboInfoBrowser, public linboDialog
{
  Q_OBJECT

private:
  QString line;
  QWidget *myMainApp;
  linboGUIImpl *app;
  QProcess* myProcess;
  QStringList myUploadCommand, myLoadCommand, mySaveCommand;
  QString filepath;
  QFile *file;
  QTextBrowser *Console;
  

public slots:
  void readFromStdout();
  void readFromStderr();
  virtual void precmd();
  virtual void postcmd();



public:
  linboInfoBrowserImpl( QWidget* parent = 0,
                        const char* name = 0,
                        bool modal = FALSE,
                        WFlags fl = 0);

  ~linboInfoBrowserImpl();

  void setTextBrowser( QTextBrowser* newBrowser );
  void setMainApp( QWidget* newMainApp );

  void setCommand(const QStringList& );
  void setLoadCommand(const QStringList& );
  void setSaveCommand(const QStringList& );
  void setUploadCommand(const QStringList& );

  QStringList getCommand();

  void setFilePath( const QString& newFilepath );


};
#endif
