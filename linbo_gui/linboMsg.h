#ifndef LINBOMSG_H
#define LINBOMSG_H

#include <qobject.h>
#include <qlabel.h>
#include <qvariant.h>
#include <qwidget.h>
#include <qdialog.h>
#include <QProcess>
#include <qstring.h>

#include "linboDialog.h"

namespace Ui {
    class linboMsg;
}

class linboMsg : public QWidget, public linboDialog
{
  Q_OBJECT

  
private:
  QProcess* process;
  QStringList arguments;
  QString line;
  QWidget *myMainApp,*myParent;

public:
  linboMsg( QWidget* parent = 0 );

   ~linboMsg();

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

private:
  Ui::linboMsg *ui;

};
#endif
