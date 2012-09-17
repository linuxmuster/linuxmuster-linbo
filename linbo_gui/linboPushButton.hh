
#ifndef LINBOPUSHBUTTON_HH
#define LINBOPUSHBUTTON_HH

#include <qpushbutton.h>
#include <qstring.h>
#include <qwidget.h>
#include <qprocess.h>
#include <QTextEdit>
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
#include "linboLogConsole.hh"

class linboGUIImpl;
class linboLogConsole;

class linbopushbutton : public QPushButton
{
  Q_OBJECT

private:
  QString myCommand, line;
  QStringList arguments;
  QTextEdit* Console;
  QProcess *process;
  QTimer *timer;
  QDialog* myQDialog,*myParent;
  linboDialog* myLinboDialog;
  QWidget *myMainApp;
  // QDialog *myMainApp;
  linboGUIImpl* app;
  bool progress;
  linbopushbutton* neighbour;
  linboProgressImpl *progwindow;
  linboLogConsole *logConsole;

public:
  linbopushbutton( QWidget* parent = 0,
                   const char* name = 0 );

  ~linbopushbutton();

  void setTextBrowser( const QString& new_consolefontcolorstdout,
		       const QString& new_consolefontcolorstderr,
		       QTextEdit* newBrowser );

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
  void processFinished( int retval,
                        QProcess::ExitStatus status);


};

#endif 
