#ifndef LINBOMULTICASTBOX_H
#define LINBOMULTICASTBOX_H

#include <qobject.h>
#include <qdialog.h>

#include "downloadtype.h"

namespace Ui {
    class linboMulticastBox;
}

class linboMulticastBox : public QDialog
{
  Q_OBJECT

private:

signals:
    void finished(bool formatCache, DownloadType type);

public:
  linboMulticastBox( QWidget* parent = 0, bool formatCache = false, DownloadType type = DownloadType::RSync );

  ~linboMulticastBox();

private slots:
  void on_okButton_clicked();

private:
  Ui::linboMulticastBox *ui;
};
#endif
