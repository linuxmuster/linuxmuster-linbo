#ifndef LINBODIALOG_HH
#define LINBODIALOG_HH

#include <qstringlist.h>
#include <qwidget.h>

class linboDialog {
public:
  linboDialog() {};
  virtual ~linboDialog() {};

  virtual void precmd() = 0;
  virtual void postcmd() = 0;
  virtual void setCommand(const QStringList& ) = 0;
  virtual QStringList getCommand() = 0;
  virtual void setMainApp( QWidget* newMainApp ) = 0;
};

#endif
