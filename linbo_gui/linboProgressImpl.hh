#ifndef LINBOPROGRESSIMPL_HH
#define LINBOPROGRESSIMPL_HH

#include "ui_linboProgress.h"

// #include "linboProgress.hh"
#include <qobject.h>
#include <qwidget.h>
#include <qdialog.h>
#include <q3process.h>
#include <qpushbutton.h>
#include <q3textbrowser.h>

class linboProgressImpl : public QWidget, public Ui::linboProgress
{
  Q_OBJECT

private:
  Q3Process *myProcess;
  Q3TextBrowser* Console;
  QWidget *myParent;

public:
  linboProgressImpl( QWidget* parent = 0 );

  ~linboProgressImpl();

  void setProcess( Q3Process* newProcess );
  void setTextBrowser( Q3TextBrowser* newBrowser );

public slots:
  void killLinboCmd();

};
#endif
