#ifndef LINBODESCBROWSER_H
#define LINBODESCBROWSER_H

#include <qobject.h>
#include <qdialog.h>
#include <qstring.h>

namespace Ui {
    class linboDescBrowser;
}

class linboDescBrowser : public QDialog
{
  Q_OBJECT

private:
  QString filename;

signals:
  void writeDesc(const QString& filename, const QString& desc);

public:
  linboDescBrowser( QWidget* parent = 0, const QString& newFilename = 0, const QString& newDesc = 0, bool newReadOnly = true);
  ~linboDescBrowser();

private slots:
  void on_saveButton_clicked();

private:
    Ui::linboDescBrowser *ui;

};
#endif
