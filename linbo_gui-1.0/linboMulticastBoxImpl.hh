#ifndef LINBOMULTICASTBOXIMPL_HH
#define LINBOMULTICASTBOXIMPL_HH

#include "ui_linboMulticastBox.h"

#include <qobject.h>
#include <qlabel.h>
#include <qlineedit.h>
#include <qvariant.h>
#include <qwidget.h>
#include <qdialog.h>
#include <QTextEdit>
#include <q3buttongroup.h>
#include <qstringlist.h>
#include <qstring.h>
#include <QProcess>
#include "linboGUIImpl.hh"

#include "linboDialog.hh"
#include "linboLogConsole.hh"

using namespace Ui;

class linboMulticastBoxImpl : public QWidget, public Ui::linboMulticastBox, public linboDialog
{
  Q_OBJECT

private:
  linboGUIImpl* app;
  QString line;
  linboProgressImpl *progwindow;
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
  linboMulticastBoxImpl( QWidget* parent = 0 );

  ~linboMulticastBoxImpl();

  void setTextBrowser( const QString& new_consolefontcolorstdout,
		       const QString& new_consolefontcolorstderr,
		       QTextEdit* newBrowser );
  virtual void setCommand(const QStringList& arglist);
  virtual QStringList getCommand();
  virtual void setRsyncCommand(const QStringList& arglist);
  virtual void setMulticastCommand(const QStringList& arglist);
  virtual void setBittorrentCommand(const QStringList& arglist);
  virtual void setMainApp( QWidget* newMainApp );
};
#endif
