#ifndef LINBOIMAGEWIDGET_H
#define LINBOIMAGEWIDGET_H

#include <qwidget.h>

#include "image_description.h"

namespace Ui {
    class LinboImageWidget;
}

class LinboImageWidget : public QWidget
{
    Q_OBJECT

private:
    int nr;
    os_item* item;

public:
    LinboImageWidget(QWidget *parent = 0, int newnr = 0, os_item* newItem = 0);
    ~LinboImageWidget();

signals:
    void doUpload(int nr);
    void doCreate(int nr);

private slots:
    void on_tbCreate_clicked();
    void on_tbUpload_clicked();

private:
    Ui::LinboImageWidget *ui;
};

#endif
