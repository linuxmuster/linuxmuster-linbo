#ifndef LINBOIMAGESELECTORIMPL_HH
#define LINBOIMAGESELECTORIMPL_HH

#include "linboImageSelector.hh"
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


class linboImageSelectorImpl : public linboImageSelector, public linboDialog
{
  Q_OBJECT

private:
  QString line, myCache, mySavePath, info, baseImage;
  QStringList myCommand, mySaveCommand, myLoadCommand;
  QProcess *process;
  QFile *file;
  QWidget *myMainApp;
  QTextBrowser *Console;
  bool upload;
  linboDialog* neighbourDialog;

public slots:
  void readFromStdout();
  void readFromStderr();
  virtual void precmd();
  virtual void postcmd();
  void postcmd2();
  void selectionWatcher();

public:
  linboImageSelectorImpl( QWidget* parent = 0,
                     const char* name = 0,
                     bool modal = FALSE,
                     WFlags fl = 0);

  ~linboImageSelectorImpl();

  void setTextBrowser( QTextBrowser* newBrowser );
  virtual void setCommand(const QStringList& arglist);
  void setLoadCommand(const QStringList& arglist);
  void setSaveCommand(const QStringList& arglist);
  void setCache( const QString& newCache );
  void setBaseImage( const QString& newBase );
  void writeInfo();
  virtual QStringList getCommand();
  void setMainApp( QWidget* newMainApp );


};
#endif
