#ifndef LINBOPROGRESSIMPL_HH
#define LINBOPROGRESSIMPL_HH

#include "linboProgress.hh"
#include <qobject.h>
#include <qwidget.h>
#include <qdialog.h>
#include <qprocess.h>
#include <qpushbutton.h>
#include <qtextbrowser.h>

class linboProgressImpl : public linboProgress
{
  Q_OBJECT

private:
  QProcess *myProcess;
  QTextBrowser* Console;

public:
  linboProgressImpl( QWidget* parent = 0,
                     const char* name = 0,
                     bool modal = FALSE,
                     WFlags fl = 0 );

  ~linboProgressImpl();

  void setProcess( QProcess* newProcess );
  void setTextBrowser( QTextBrowser* newBrowser );

public slots:
  void killLinboCmd();

};
#endif
