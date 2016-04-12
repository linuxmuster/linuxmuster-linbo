#ifndef LINBOIMAGESELECTOR_H
#define LINBOIMAGESELECTOR_H

#include <qobject.h>
#include <qdialog.h>

#include "aktion.h"
#include "command.h"
#include "image_description.h"

namespace Ui {
    class linboImageSelector;
}

class linboImageSelector : public QDialog
{
  Q_OBJECT

private:
    int nr;
    vector<image_item>* history;
  Command *command;
  bool upload;

public:
  linboImageSelector( QWidget* parent = 0, int newnr = 0, vector<image_item>* new_history = 0, Command* newCommand = 0);

  ~linboImageSelector();

  static const QString& NEWNAME;

signals:
  void finished(int nr, const QString& imageName, const QString& info, bool isnew, bool upload, Aktion folgeAktion);

private slots:
  void on_listBox_itemSelectionChanged();

  void on_createButton_clicked();

  void on_createUploadButton_clicked();

private:
  Ui::linboImageSelector *ui;
  void finish();

};
#endif
