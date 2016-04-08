#ifndef LINBOIMAGESELECTOR_H
#define LINBOIMAGESELECTOR_H

#include <qobject.h>
#include <qlabel.h>
#include <qlineedit.h>
#include <qvariant.h>
#include <qdialog.h>
#include <QTextEdit>
#include <qstringlist.h>
#include <qstring.h>
#include <QProcess>
#include <QFile>

#include "linbogui.h"
#include "folgeaktion.h"

namespace Ui {
    class linboImageSelector;
}
class LinboGUI;

class linboImageSelector : public QDialog
{
  Q_OBJECT

private:
  Command *command;
  bool upload;

public:
  linboImageSelector( QWidget* parent = 0, Command* newCommand = 0);

  ~linboImageSelector();

signals:
  void finished(int nr, const QString& imageName, const QString& info, bool isnew, bool upload, FolgeAktion folgeAktion);

private slots:
  void on_listBox_itemSelectionChanged();

  void on_createButton_clicked();

  void on_createUploadButton_clicked();

private:
  Ui::linboImageSelector *ui;
  void finish();

};
#endif
