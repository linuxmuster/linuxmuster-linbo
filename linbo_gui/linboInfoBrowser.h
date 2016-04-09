#ifndef LINBOINFOBROWSER_H
#define LINBOINFOBROWSER_H

#include <qobject.h>
#include <qdialog.h>
#include <qstring.h>

namespace Ui {
    class linboInfoBrowser;
}

class linboInfoBrowser : public QDialog
{
  Q_OBJECT

private:
  QString filename;

signals:
  void writeInfo(const QString& filename, const QString& info);

public:
  linboInfoBrowser( QWidget* parent = 0, const QString& newFilename = 0, const QString& newInfo = 0, bool newReadOnly = true);
  ~linboInfoBrowser();

private slots:
  void on_saveButton_clicked();

private:
    Ui::linboInfoBrowser *ui;

};
#endif
