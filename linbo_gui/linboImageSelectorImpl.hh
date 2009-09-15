#ifndef LINBOIMAGESELECTORIMPL_HH
#define LINBOIMAGESELECTORIMPL_HH

#include "ui_linboImageSelector.h"

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


class linboImageSelectorImpl : public QWidget, public Ui::linboImageSelector, public linboDialog
{
  Q_OBJECT

private:
  QString line, myCache, mySavePath, info, baseImage;
  QStringList myCommand, mySaveCommand, myLoadCommand;
  Q3Process *process;
  QFile *file;
  QWidget *myMainApp,*myParent;
  Q3TextBrowser *Console;
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
  linboImageSelectorImpl( QWidget* parent = 0);

  ~linboImageSelectorImpl();

  void setTextBrowser( Q3TextBrowser* newBrowser );
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
