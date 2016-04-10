#ifndef LINBOOSWIDGET_H
#define LINBOOSWIDGET_H

#include <qwidget.h>
#include <qlabel.h>
#include <qtoolbutton.h>
#include <qicon.h>

#include "image_description.h"

namespace Ui {
    class LinboOSWidget;
}

class LinboOSWidget : public QWidget
{
    Q_OBJECT

    enum DefaultButton {
        Start, Sync, New
    };

private:
    int nr;
    os_item* item;
    DefaultButton defaultButton;

public:
    LinboOSWidget(QWidget *parent = 0, int newnr = 0, os_item *newItem = 0);
    ~LinboOSWidget();

signals:
    void doStart(int nr);
    void doSync(int nr);
    void doNew(int nr);
    void doInfo(int nr);

private slots:
    void on_tbDefault_clicked();

    void on_tbStart_clicked();

    void on_tbSync_clicked();

    void on_tbNew_clicked();

    void on_tbInfo_clicked();

private:
    DefaultButton buttonFromAction(const QString& defaultAction);
    void composeDefaultIcon();
    Ui::LinboOSWidget *ui;
};

#endif
