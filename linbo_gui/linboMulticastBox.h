#ifndef LINBOMULTICASTBOX_H
#define LINBOMULTICASTBOX_H

#include <qobject.h>
#include <qlabel.h>
#include <qlineedit.h>
#include <qvariant.h>
#include <qwidget.h>
#include <qdialog.h>
#include <QTextEdit>
#include <qbuttongroup.h>
#include <qstringlist.h>
#include <qstring.h>
#include <QProcess>

#include "linbogui.h"
#include "linboDialog.h"
#include "linboLogConsole.h"

namespace Ui {
    class linboMulticastBox;
}
class LinboGUI;

class linboMulticastBox : public QWidget, public linboDialog
{
  Q_OBJECT

private:
  LinboGUI* app;
  QString line;
  linboProgress *progwindow;
  QStringList arguments, myCommand, myRsyncCommand, myMulticastCommand, myBittorrentCommand;
  QProcess *process;
  QWidget *myMainApp,*myParent;
  QTextEdit *Console;
  linboLogConsole *logConsole;

public slots:
  void processFinished( int retval,
			QProcess::ExitStatus status);
  void readFromStderr();
  void readFromStdout();
  virtual void precmd();
  virtual void postcmd();



public:
  linboMulticastBox( QWidget* parent = 0 );

  ~linboMulticastBox();

  void setTextBrowser( const QString& new_consolefontcolorstdout,
		       const QString& new_consolefontcolorstderr,
		       QTextEdit* newBrowser );
  virtual void setCommand(const QStringList& arglist);
  virtual QStringList getCommand();
  virtual void setRsyncCommand(const QStringList& arglist);
  virtual void setMulticastCommand(const QStringList& arglist);
  virtual void setBittorrentCommand(const QStringList& arglist);
  virtual void setMainApp( QWidget* newMainApp );

private:
  Ui::linboMulticastBox *ui;
};
#endif
