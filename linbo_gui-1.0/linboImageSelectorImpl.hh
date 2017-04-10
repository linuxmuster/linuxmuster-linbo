#ifndef LINBOIMAGESELECTORIMPL_HH
#define LINBOIMAGESELECTORIMPL_HH

#include "ui_linboImageSelector.h"
#include "linboProgressImpl.hh"
#include <qobject.h>
#include "linboGUIImpl.hh"
#include <qlabel.h>
#include <qlineedit.h>
#include <qvariant.h>
#include <qwidget.h>
#include <qdialog.h>
#include <QTextEdit>
#include <qstringlist.h>
#include <qstring.h>
#include <QProcess>
#include <QFile>

#include "linboDialog.hh"
#include "linboLogConsole.hh"

class linboGuiImpl;

class linboImageSelectorImpl : public QWidget, public Ui::linboImageSelector, public linboDialog
{
  Q_OBJECT

private:
  QString line, myCache, mySavePath, info, baseImage;
  QStringList myCommand, mySaveCommand, myLoadCommand;
  QProcess *process;
  QStringList arguments;
  QFile *file;
  QWidget *myMainApp,*myParent;
  linboProgressImpl *progwindow;
  QTextEdit *Console;
  bool upload;
  linboGUIImpl* app;
  linboDialog* neighbourDialog;
  linboLogConsole* logConsole;

public slots:
  void readFromStdout();
  void readFromStderr();
  void processFinished( int retval,
                        QProcess::ExitStatus status);
  virtual void precmd();
  virtual void postcmd();
  void postcmd2();
  void selectionWatcher();

public:
  linboImageSelectorImpl( QWidget* parent = 0);

  ~linboImageSelectorImpl();

  void setTextBrowser( const QString& new_consolefontcolorstdout,
		       const QString& new_consolefontcolorstderr,
		       QTextEdit* newBrowser );
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
