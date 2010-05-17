#ifndef LINBOIMAGEUPLOADIMPL_HH
#define LINBOIMAGEUPLOADIMPL_HH

#include "ui_linboImageUpload.h"
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
#include "linboGUIImpl.hh"
#include "linboProgressImpl.hh"
#include "linboDialog.hh"
#include "linboLogConsole.hh"

class linboImageUploadImpl : public QWidget, public Ui::linboImageUpload, public linboDialog
{
  Q_OBJECT

private:
  QString line;
  QStringList arguments;
  QProcess *process;
  linboGUIImpl* app;
  QWidget *myMainApp,*myParent;
  QTextEdit *Console;
  linboProgressImpl *progwindow;
  linboLogConsole* logConsole;
  

public slots:
  void readFromStdout();
  void readFromStderr();
  virtual void precmd();
  virtual void postcmd();
  void processFinished( int retval,
                        QProcess::ExitStatus status);

public:
  linboImageUploadImpl( QWidget* parent = 0);

  ~linboImageUploadImpl();

  void setTextBrowser( const QString& new_consolefontcolorstdout,
		       const QString& new_consolefontcolorstderr,
		       QTextEdit* newBrowser );
  virtual void setCommand(const QStringList& arglist);
  virtual QStringList getCommand();
  virtual void setMainApp( QWidget* newMainApp );


};
#endif
