#ifndef LINBOIMAGESELECTOR_H
#define LINBOIMAGESELECTOR_H

#include <qobject.h>
#include <qdialog.h>

#include "folgeaktion.h"
#include "command.h"

namespace Ui {
    class linboImageSelector;
}

class linboImageSelector : public QDialog
{
  Q_OBJECT

private:
    int nr;
  Command *command;
  bool upload;

public:
  linboImageSelector( QWidget* parent = 0, int newnr = 0, Command* newCommand = 0);

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
