#ifndef LINBOIMAGEUPLOAD_H
#define LINBOIMAGEUPLOAD_H

#include <qobject.h>
#include <qlabel.h>
#include <qlineedit.h>
#include <qvariant.h>
#include <qwidget.h>
#include <qdialog.h>
#include <QTextEdit>
#include <qstringlist.h>
#include <qlistwidget.h>
#include <qstring.h>
#include <QProcess>

#include "linbogui.h"
#include "linboProgress.h"
#include "linboDialog.h"
#include "linboLogConsole.h"

namespace Ui {
    class linboImageUpload;
}
class LinboGUI;

class linboImageUpload : public QWidget, public linboDialog
{
  Q_OBJECT

private:
  QString line;
  QStringList arguments;
  QProcess *process;
  LinboGUI* app;
  QWidget *myMainApp,*myParent;
  QTextEdit *Console;
  linboProgress *progwindow;
  linboLogConsole* logConsole;
  

public slots:
  void readFromStdout();
  void readFromStderr();
  virtual void precmd();
  virtual void postcmd();
  void processFinished( int retval,
                        QProcess::ExitStatus status);

public:
  linboImageUpload( QWidget* parent = 0);
    QListWidgetItem *findImageItem(QString imageName);
    void insertImageItem(QListWidgetItem imageItem);
    void insertImageItem(QString imageName);
    void setCurrentImageItem(QListWidgetItem* imageItem);

  ~linboImageUpload();

  void setTextBrowser( const QString& new_consolefontcolorstdout,
		       const QString& new_consolefontcolorstderr,
		       QTextEdit* newBrowser );
  virtual void setCommand(const QStringList& arglist);
  virtual QStringList getCommand();
  virtual void setMainApp( QWidget* newMainApp );

private:
  Ui::linboImageUpload *ui;

};
#endif
