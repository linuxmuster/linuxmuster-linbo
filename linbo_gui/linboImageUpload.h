#ifndef LINBOIMAGEUPLOAD_H
#define LINBOIMAGEUPLOAD_H

#include <qobject.h>
#include <qlabel.h>
#include <qlineedit.h>
#include <qvariant.h>
#include <qdialog.h>
#include <QTextEdit>
#include <qstringlist.h>
#include <qlistwidget.h>
#include <qstring.h>
#include <QProcess>

#include "linbogui.h"
#include "folgeaktion.h"
#include "image_description.h"

namespace Ui {
class linboImageUpload;
}
class LinboGUI;

class linboImageUpload : public QDialog
{
    Q_OBJECT

private:
    vector<image_item>* history;

public:
    linboImageUpload( QWidget* parent = 0, vector<image_item>* new_history = 0);
    ~linboImageUpload();

    QListWidgetItem *findImageItem(QString imageName);

signals:
    void finished(const QString& imageName, FolgeAktion aktion);

private slots:
    void on_okButton_clicked();

private:
    Ui::linboImageUpload *ui;

};
#endif
