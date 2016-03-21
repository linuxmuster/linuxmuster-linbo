#ifndef LINBOIMAGESELECTOR_H
#define LINBOIMAGESELECTOR_H

#include <qobject.h>
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

#include "linbogui.h"
#include "linboProgress.h"
#include "linboDialog.h"
#include "linboLogConsole.h"

namespace Ui {
    class linboImageSelector;
}
class LinboGUI;

class linboImageSelector : public QWidget, public linboDialog
{
  Q_OBJECT

private:
  QString line, myCache, mySavePath, info, baseImage;
  QStringList myCommand, mySaveCommand, myLoadCommand;
  QProcess *process;
  QStringList arguments;
  QFile *file;
  QWidget *myMainApp,*myParent;
  linboProgress *progwindow;
  QTextEdit *Console;
  bool upload;
  LinboGUI* app;
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
  linboImageSelector( QWidget* parent = 0);

  ~linboImageSelector();

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

private:
  Ui::linboImageSelector *ui;

};
#endif
