#ifndef LINBOPUSHBUTTON_HH
#define LINBOPUSHBUTTON_HH

#include <qpushbutton.h>
#include <qstring.h>
#include <qwidget.h>
#include <qprocess.h>
#include <qtextbrowser.h>
#include <qstringlist.h>
#include <qtimer.h>
#include <qdialog.h>
#include "linboProgressImpl.hh"
#include "linboYesNoImpl.hh"
#include "linboPasswordBoxImpl.hh"
#include "linboMsgImpl.hh"
#include "linboInfoBrowser.hh"
#include "linboInputBoxImpl.hh"
#include "linboDialog.hh"
#include "linboGUIImpl.hh"

class linboGUIImpl;

class linbopushbutton : public QPushButton
{
  Q_OBJECT

private:
  QString myCommand, line;
  QTextBrowser* Console;
  QProcess *myprocess;
  QTimer *timer;
  QDialog* myQDialog;
  linboDialog* myLinboDialog;
  QWidget *myMainApp;
  linboGUIImpl* app;
  bool progress;
  linbopushbutton* neighbour;

public:
  linbopushbutton( QWidget* parent = 0,
                   const char* name = 0,
                   bool modal = FALSE,
                   WFlags fl = 0 );

  ~linbopushbutton();

  void setTextBrowser( QTextBrowser* newBrowser );
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
