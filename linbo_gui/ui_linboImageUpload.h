/********************************************************************************
** Form generated from reading ui file 'linboImageUpload.ui'
**
** Created: Fri Sep 18 10:34:16 2009
**      by: Qt User Interface Compiler version 4.5.2
**
** WARNING! All changes made in this file will be lost when recompiling ui file!
********************************************************************************/

#ifndef UI_LINBOIMAGEUPLOAD_H
#define UI_LINBOIMAGEUPLOAD_H

#include <Qt3Support/Q3ListBox>
#include <Qt3Support/Q3MimeSourceFactory>
#include <QtCore/QVariant>
#include <QtGui/QAction>
#include <QtGui/QApplication>
#include <QtGui/QButtonGroup>
#include <QtGui/QDialog>
#include <QtGui/QHeaderView>
#include <QtGui/QLabel>
#include <QtGui/QPushButton>

QT_BEGIN_NAMESPACE

class Ui_linboImageUpload
{
public:
    Q3ListBox *listBox;
    QLabel *OSLabel;
    QPushButton *cancelButton;
    QPushButton *okButton;

    void setupUi(QDialog *linboImageUpload)
    {
        if (linboImageUpload->objectName().isEmpty())
            linboImageUpload->setObjectName(QString::fromUtf8("linboImageUpload"));
        linboImageUpload->resize(341, 213);
        listBox = new Q3ListBox(linboImageUpload);
        listBox->setObjectName(QString::fromUtf8("listBox"));
        listBox->setGeometry(QRect(10, 70, 320, 90));
        listBox->setVScrollBarMode(Q3ScrollView::Auto);
        listBox->setHScrollBarMode(Q3ScrollView::Auto);
        OSLabel = new QLabel(linboImageUpload);
        OSLabel->setObjectName(QString::fromUtf8("OSLabel"));
        OSLabel->setGeometry(QRect(10, 10, 310, 51));
        OSLabel->setAlignment(Qt::AlignCenter);
        OSLabel->setWordWrap(false);
        cancelButton = new QPushButton(linboImageUpload);
        cancelButton->setObjectName(QString::fromUtf8("cancelButton"));
        cancelButton->setGeometry(QRect(230, 170, 100, 31));
        okButton = new QPushButton(linboImageUpload);
        okButton->setObjectName(QString::fromUtf8("okButton"));
        okButton->setGeometry(QRect(10, 170, 100, 31));

        retranslateUi(linboImageUpload);

        QMetaObject::connectSlotsByName(linboImageUpload);
    } // setupUi

    void retranslateUi(QDialog *linboImageUpload)
    {
        linboImageUpload->setWindowTitle(QApplication::translate("linboImageUpload", "Image Auswahl", 0, QApplication::UnicodeUTF8));
        listBox->clear();
        listBox->insertItem(QApplication::translate("linboImageUpload", "New Item", 0, QApplication::UnicodeUTF8));
        OSLabel->setText(QApplication::translate("linboImageUpload", "Welches Image soll hochgeladen werden?", 0, QApplication::UnicodeUTF8));
        cancelButton->setText(QApplication::translate("linboImageUpload", "Abbruch", 0, QApplication::UnicodeUTF8));
#ifndef QT_NO_TOOLTIP
        cancelButton->setProperty("toolTip", QVariant(QApplication::translate("linboImageUpload", "Abbrechen ohne Hochladen", 0, QApplication::UnicodeUTF8)));
#endif // QT_NO_TOOLTIP
        okButton->setText(QApplication::translate("linboImageUpload", "OK", 0, QApplication::UnicodeUTF8));
#ifndef QT_NO_TOOLTIP
        okButton->setProperty("toolTip", QVariant(QApplication::translate("linboImageUpload", "L\303\244dt das ausgew\303\244hlte<br>Image auf den Server hoch", 0, QApplication::UnicodeUTF8)));
#endif // QT_NO_TOOLTIP
        Q_UNUSED(linboImageUpload);
    } // retranslateUi

};

namespace Ui {
    class linboImageUpload: public Ui_linboImageUpload {};
} // namespace Ui

QT_END_NAMESPACE

#endif // UI_LINBOIMAGEUPLOAD_H
