#ifndef LINBOPUSHBUTTON_H
#define LINBOPUSHBUTTON_H

#include <qpushbutton.h>
#include <qstring.h>
#include <qwidget.h>
#include <qprocess.h>
#include <QTextEdit>
#include <qstringlist.h>
#include <qtimer.h>
#include <qdialog.h>
#include "linboProgress.h"
#include "linboYesNo.h"
#include "linboPasswordBox.h"
#include "linboMsg.h"
#include "linboInputBox.h"
#include "linboDialog.h"
#include "linbogui.h"
#include "linboLogConsole.h"

class linboGUl;
class linboLogConsole;

namespace Ui {
    class linboInfoBrowser;
}

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
  LinboGUI* app;
  bool progress;
  linbopushbutton* neighbour;
  linboProgress *progwindow;
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
