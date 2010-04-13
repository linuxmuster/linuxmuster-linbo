#ifndef LINBOPUSHBUTTON_HH
#define LINBOPUSHBUTTON_HH

#include <qpushbutton.h>
#include <qstring.h>
#include <qwidget.h>
#include <q3process.h>
#include <q3textbrowser.h>
#include <qstringlist.h>
#include <qtimer.h>
#include <qdialog.h>
#include "linboProgressImpl.hh"
#include "linboYesNoImpl.hh"
#include "linboPasswordBoxImpl.hh"
#include "linboMsgImpl.hh"
#include "ui_linboInfoBrowser.h"
#include "linboInputBoxImpl.hh"
#include "linboDialog.hh"
#include "linboGUIImpl.hh"

class linboGUIImpl;

class linbopushbutton : public QPushButton
{
  Q_OBJECT

private:
  QString myCommand, line;
  Q3TextBrowser* Console;
  Q3Process *myprocess;
  QTimer *timer;
  QDialog* myQDialog,*myParent;
  linboDialog* myLinboDialog;
  QWidget *myMainApp;
  // QDialog *myMainApp;
  linboGUIImpl* app;
  bool progress;
  linbopushbutton* neighbour;

public:
  linbopushbutton( QWidget* parent = 0,
                   const char* name = 0 );

  ~linbopushbutton();

  void setTextBrowser( Q3TextBrowser* newBrowser );
  // void setMainApp( QDialog* newMainApp );
  void setMainApp( QWidget* newMainApp );
  void setLinboDialog( linboDialog* newDialog );
  linboDialog* getLinboDialog();
  void setQDialog( QDialog* newDialog );
  QDialog* getQDialog();
  void setCommand(const QStringList& arglist);
  QStringList getCommand();
  void setProgress( const bool& newProgress );
  void setNeighbour( linbopushbutton* newNeighbour );
  linbopushbutton* getNeighbour();

signals:
  void Clicked( const QStringList& command );

// other buttons may click too ;-)
public slots:
  void lclicked();

private slots:
  void readFromStdout();
  void readFromStderr();

};

#endif 
