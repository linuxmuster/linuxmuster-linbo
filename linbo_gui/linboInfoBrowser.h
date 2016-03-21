#ifndef LINBOINFOBROWSER_H
#define LINBOINFOBROWSER_H

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
#include <qfile.h>

#include "linboDialog.h"
#include "linbogui.h"
#include "linboLogConsole.h"

namespace Ui {
    class linboInfoBrowser;
}

class LinboGUI;

class linboInfoBrowser : public QWidget, public linboDialog
{
  Q_OBJECT

private:
  QString line;
  QWidget *myMainApp,*myParent;
  LinboGUI *app;
  QProcess* process;
  QStringList myUploadCommand, myLoadCommand, mySaveCommand, arguments;
  QString filepath;
  QFile *file;
  QTextEdit *Console;
  linboLogConsole* logConsole;
  

public slots:
  void readFromStdout();
  void readFromStderr();
  void processFinished( int retval,
                        QProcess::ExitStatus status);

  virtual void precmd();
  virtual void postcmd();



public:
  linboInfoBrowser( QWidget* parent );

  ~linboInfoBrowser();

  void setTextBrowser( const QString& new_consolefontcolorstdout,
		       const QString& new_consolefontcolorstderr,
		       QTextEdit* newBrowser );

  void setMainApp( QWidget* newMainApp );

  void setCommand(const QStringList& );
  void setLoadCommand(const QStringList& );
  void setSaveCommand(const QStringList& );
  void setUploadCommand(const QStringList& );

  QStringList getCommand();

  void setFilePath( const QString& newFilepath );

private:
    Ui::linboInfoBrowser *ui;

};
#endif
