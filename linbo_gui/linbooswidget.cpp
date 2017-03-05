#include <qmessagebox.h>
#include <qpixmap.h>
#include <qpainter.h>

#include "linbooswidget.h"
#include "ui_linbooswidget.h"
#include "image_description.h"

LinboOSWidget::LinboOSWidget(QWidget *parent, int newnr, os_item *newItem) :
    QWidget(parent), nr(newnr), item(newItem), ui(new Ui::LinboOSWidget)
{
    ui->setupUi(this);
    setFocusProxy( ui->tbDefault );
    if( item != NULL ){
        ui->lName->setText(item->get_name());
        image_item img(item->image_history[item->find_current_image()]);
        defaultButton = buttonFromAction(img.get_defaultaction());
        composeDefaultIcon();
        switch(defaultButton){
        case Start:
            ui->tbDefault->setEnabled(img.get_startbutton());
            break;
        case Sync:
            ui->tbDefault->setEnabled(img.get_syncbutton());
            break;
        case New:
            ui->tbDefault->setEnabled(img.get_newbutton());
            break;
        default:
            ui->tbDefault->setEnabled(false);
            break;
        }
        ui->tbStart->setEnabled(img.get_startbutton());
        ui->tbSync->setEnabled(img.get_syncbutton());
        ui->tbNew->setEnabled(img.get_newbutton());
    } else {
        ui->lName->setText("unnamed");
        ui->tbDefault->setEnabled(false);
        ui->tbStart->setEnabled(false);
        ui->tbSync->setEnabled(false);
        ui->tbNew->setEnabled(false);
    }
}

void LinboOSWidget::composeDefaultIcon()
{
    QSize size = ui->tbDefault->iconSize();
    QPixmap custom;
    if(item != NULL){
        QIcon customI(QString("/icons/"+item->get_iconname()));
        custom = customI.pixmap(size);
    }
    if(custom.isNull()) {
        custom = ui->tbDefault->icon().pixmap(size);
    }
    QPixmap overlay;
    QSize overlaySize = ui->tbStart->iconSize();
    switch(defaultButton){
    case Start:
    default:
        overlay = ui->tbStart->icon().pixmap(overlaySize);
        break;
    case Sync:
        overlay = ui->tbSync->icon().pixmap(overlaySize);
        break;
    case New:
        overlay = ui->tbNew->icon().pixmap(overlaySize);
        break;
    }
    QPainter painter(&custom);
    painter.drawPixmap(custom.width()-overlay.width(),
                       custom.height()-overlay.height(),
                       overlay);
    QIcon icon;
    icon.addPixmap(custom);

    ui->tbDefault->setIcon(icon);
}

void LinboOSWidget::on_tbDefault_clicked()
{
    switch(defaultButton){
    case Sync:
        emit doSync(nr);
        break;
    case New:
        emit doNew(nr);
        break;
    case Start:
    default:
        emit doStart(nr);
        break;
    }
}


void LinboOSWidget::on_tbStart_clicked()
{
    emit doStart(nr);
}

void LinboOSWidget::on_tbSync_clicked()
{
    emit doSync(nr);
}

void LinboOSWidget::on_tbNew_clicked()
{
    emit doNew(nr);
}

LinboOSWidget::DefaultButton LinboOSWidget::buttonFromAction(const QString& defaultAction)
{
    if(defaultAction.compare(QString("sync"),Qt::CaseInsensitive) == 0) {
    return Sync;
    } else if (defaultAction.compare(QString("new"),Qt::CaseInsensitive) == 0) {
        return New;
    } else {
        return Start;
    }
}

LinboOSWidget::~LinboOSWidget()
{
    delete ui;
}

void LinboOSWidget::on_tbInfo_clicked()
{
    emit doInfo(nr);
}
