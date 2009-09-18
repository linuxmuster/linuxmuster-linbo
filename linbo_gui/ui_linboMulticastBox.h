/********************************************************************************
** Form generated from reading ui file 'linboMulticastBox.ui'
**
** Created: Fri Sep 18 10:34:17 2009
**      by: Qt User Interface Compiler version 4.5.2
**
** WARNING! All changes made in this file will be lost when recompiling ui file!
********************************************************************************/

#ifndef UI_LINBOMULTICASTBOX_H
#define UI_LINBOMULTICASTBOX_H

#include <Qt3Support/Q3ButtonGroup>
#include <Qt3Support/Q3GroupBox>
#include <Qt3Support/Q3MimeSourceFactory>
#include <QtCore/QVariant>
#include <QtGui/QAction>
#include <QtGui/QApplication>
#include <QtGui/QButtonGroup>
#include <QtGui/QDialog>
#include <QtGui/QHeaderView>
#include <QtGui/QPushButton>
#include <QtGui/QRadioButton>

QT_BEGIN_NAMESPACE

class Ui_linboMulticastBox
{
public:
    Q3ButtonGroup *updateMethodGroup;
    QRadioButton *rsyncButton;
    QRadioButton *multicastButton;
    QRadioButton *torrentButton;
    QPushButton *okButton;
    QPushButton *cancelButton;

    void setupUi(QDialog *linboMulticastBox)
    {
        if (linboMulticastBox->objectName().isEmpty())
            linboMulticastBox->setObjectName(QString::fromUtf8("linboMulticastBox"));
        linboMulticastBox->setWindowModality(Qt::NonModal);
        linboMulticastBox->resize(203, 142);
        linboMulticastBox->setSizeGripEnabled(false);
        updateMethodGroup = new Q3ButtonGroup(linboMulticastBox);
        updateMethodGroup->setObjectName(QString::fromUtf8("updateMethodGroup"));
        updateMethodGroup->setGeometry(QRect(10, 10, 181, 91));
        rsyncButton = new QRadioButton(updateMethodGroup);
        rsyncButton->setObjectName(QString::fromUtf8("rsyncButton"));
        rsyncButton->setGeometry(QRect(8, 20, 150, 20));
        rsyncButton->setChecked(true);
        multicastButton = new QRadioButton(updateMethodGroup);
        multicastButton->setObjectName(QString::fromUtf8("multicastButton"));
        multicastButton->setGeometry(QRect(8, 40, 160, 20));
        torrentButton = new QRadioButton(updateMethodGroup);
        torrentButton->setObjectName(QString::fromUtf8("torrentButton"));
        torrentButton->setGeometry(QRect(8, 60, 163, 20));
        okButton = new QPushButton(linboMulticastBox);
        okButton->setObjectName(QString::fromUtf8("okButton"));
        okButton->setGeometry(QRect(10, 110, 61, 21));
        cancelButton = new QPushButton(linboMulticastBox);
        cancelButton->setObjectName(QString::fromUtf8("cancelButton"));
        cancelButton->setGeometry(QRect(125, 110, 65, 21));

        retranslateUi(linboMulticastBox);

        QMetaObject::connectSlotsByName(linboMulticastBox);
    } // setupUi

    void retranslateUi(QDialog *linboMulticastBox)
    {
        linboMulticastBox->setWindowTitle(QApplication::translate("linboMulticastBox", "Update Cache", 0, QApplication::UnicodeUTF8));
        updateMethodGroup->setTitle(QApplication::translate("linboMulticastBox", "Auswahl", 0, QApplication::UnicodeUTF8));
        rsyncButton->setText(QApplication::translate("linboMulticastBox", "Update mit Rsync", 0, QApplication::UnicodeUTF8));
        multicastButton->setText(QApplication::translate("linboMulticastBox", "Update mit Multicast", 0, QApplication::UnicodeUTF8));
        torrentButton->setText(QApplication::translate("linboMulticastBox", "Update mit Bittorrent", 0, QApplication::UnicodeUTF8));
#ifndef QT_NO_TOOLTIP
        okButton->setToolTip(QApplication::translate("linboMulticastBox", "Aktualisiert den lokalen<br>Cache mit der gew\303\244hlten Methode", 0, QApplication::UnicodeUTF8));
#endif // QT_NO_TOOLTIP
        okButton->setText(QApplication::translate("linboMulticastBox", "OK", 0, QApplication::UnicodeUTF8));
#ifndef QT_NO_TOOLTIP
        cancelButton->setToolTip(QApplication::translate("linboMulticastBox", "Abbrechen ohne Cache-Aktualisierung", 0, QApplication::UnicodeUTF8));
#endif // QT_NO_TOOLTIP
        cancelButton->setText(QApplication::translate("linboMulticastBox", "Abbruch", 0, QApplication::UnicodeUTF8));
        Q_UNUSED(linboMulticastBox);
    } // retranslateUi

};

namespace Ui {
    class linboMulticastBox: public Ui_linboMulticastBox {};
} // namespace Ui

QT_END_NAMESPACE

#endif // UI_LINBOMULTICASTBOX_H
