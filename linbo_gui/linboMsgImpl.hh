#ifndef LINBOMSGIMPL_HH
#define LINBOMSGIMPL_HH

#include "linboMsg.hh"
#include <qobject.h>
#include <qlabel.h>
#include <qvariant.h>
#include <qwidget.h>
#include <qdialog.h>
#include <qprocess.h>
#include <qstring.h>

#include "linboDialog.hh"


class linboMsgImpl : public linboMsg, public linboDialog
{
  Q_OBJECT

  
private:
  QProcess* myProcess;
  QString line;

public:
  linboMsgImpl( QWidget* parent = 0,
                const char* name = 0,
                bool modal = FALSE,
                WFlags fl = 0);

   ~linboMsgImpl();

  virtual void precmd();
  virtual void postcmd();
  virtual void setCommand(const QStringList& arglist);
  virtual QStringList getCommand();
  // not needed here
  virtual void setMainApp( QWidget* newMainApp ) {};
  void execute();

public slots:
void readFromStderr();
void readFromStdout();

};
#endif
