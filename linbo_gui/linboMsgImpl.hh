#ifndef LINBOMSGIMPL_HH
#define LINBOMSGIMPL_HH

#include "ui_linboMsg.h"
#include <qobject.h>
#include <qlabel.h>
#include <qvariant.h>
#include <qwidget.h>
#include <qdialog.h>
#include <QProcess>
#include <qstring.h>

#include "linboDialog.hh"


class linboMsgImpl : public QWidget, public Ui::linboMsg, public linboDialog
{
  Q_OBJECT

  
private:
  QProcess* process;
  QStringList arguments;
  QString line;
  QWidget *myMainApp,*myParent;

public:
  linboMsgImpl( QWidget* parent = 0 );

   ~linboMsgImpl();

  virtual void precmd();
  virtual void postcmd();
  virtual void setCommand(const QStringList& arglist);
  virtual QStringList getCommand();
  // not needed here
  virtual void setMainApp( QWidget* newMainApp );
  void execute();

public slots:
  void readFromStderr();
  void readFromStdout();
  void processFinished( int retval,
                        QProcess::ExitStatus status);


};
#endif
