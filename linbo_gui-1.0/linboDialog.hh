#ifndef LINBODIALOG_HH
#define LINBODIALOG_HH

#include <qstringlist.h>
#include <qwidget.h>
#include <QProcess>

class linboDialog {
public:
  linboDialog() {};
  virtual ~linboDialog() {};

  virtual void precmd() = 0;
  virtual void postcmd() = 0;
  virtual void setCommand(const QStringList& ) = 0;
  virtual QStringList getCommand() = 0;
  virtual void setMainApp( QWidget* ) = 0;
  virtual void readFromStdout() = 0;
  virtual void readFromStderr() = 0;
  virtual void processFinished( int, QProcess::ExitStatus) = 0;
};

#endif
