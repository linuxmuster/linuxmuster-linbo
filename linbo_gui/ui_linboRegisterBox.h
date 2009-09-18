/********************************************************************************
** Form generated from reading ui file 'linboRegisterBox.ui'
**
** Created: Fri Sep 18 10:34:17 2009
**      by: Qt User Interface Compiler version 4.5.2
**
** WARNING! All changes made in this file will be lost when recompiling ui file!
********************************************************************************/

#ifndef UI_LINBOREGISTERBOX_H
#define UI_LINBOREGISTERBOX_H

#include <Qt3Support/Q3MimeSourceFactory>
#include <QtCore/QVariant>
#include <QtGui/QAction>
#include <QtGui/QApplication>
#include <QtGui/QButtonGroup>
#include <QtGui/QDialog>
#include <QtGui/QHeaderView>
#include <QtGui/QLabel>
#include <QtGui/QLineEdit>
#include <QtGui/QPushButton>

QT_BEGIN_NAMESPACE

class Ui_linboRegisterBox
{
public:
    QLabel *textLabel2;
    QLineEdit *roomName;
    QLabel *textLabel3;
    QLineEdit *clientName;
    QLabel *textLabel3_2;
    QLineEdit *ipAddress;
    QLabel *textLabel3_2_2;
    QLineEdit *clientGroup;
    QPushButton *registerButton;
    QPushButton *cancelButton;

    void setupUi(QDialog *linboRegisterBox)
    {
        if (linboRegisterBox->objectName().isEmpty())
            linboRegisterBox->setObjectName(QString::fromUtf8("linboRegisterBox"));
        linboRegisterBox->resize(282, 412);
        textLabel2 = new QLabel(linboRegisterBox);
        textLabel2->setObjectName(QString::fromUtf8("textLabel2"));
        textLabel2->setGeometry(QRect(20, 10, 171, 31));
        textLabel2->setWordWrap(false);
        roomName = new QLineEdit(linboRegisterBox);
        roomName->setObjectName(QString::fromUtf8("roomName"));
        roomName->setGeometry(QRect(20, 50, 240, 31));
        textLabel3 = new QLabel(linboRegisterBox);
        textLabel3->setObjectName(QString::fromUtf8("textLabel3"));
        textLabel3->setGeometry(QRect(20, 100, 141, 31));
        textLabel3->setWordWrap(false);
        clientName = new QLineEdit(linboRegisterBox);
        clientName->setObjectName(QString::fromUtf8("clientName"));
        clientName->setGeometry(QRect(20, 140, 241, 31));
        textLabel3_2 = new QLabel(linboRegisterBox);
        textLabel3_2->setObjectName(QString::fromUtf8("textLabel3_2"));
        textLabel3_2->setGeometry(QRect(20, 190, 141, 31));
        textLabel3_2->setWordWrap(false);
        ipAddress = new QLineEdit(linboRegisterBox);
        ipAddress->setObjectName(QString::fromUtf8("ipAddress"));
        ipAddress->setGeometry(QRect(20, 230, 241, 31));
        textLabel3_2_2 = new QLabel(linboRegisterBox);
        textLabel3_2_2->setObjectName(QString::fromUtf8("textLabel3_2_2"));
        textLabel3_2_2->setGeometry(QRect(20, 280, 141, 31));
        textLabel3_2_2->setWordWrap(false);
        clientGroup = new QLineEdit(linboRegisterBox);
        clientGroup->setObjectName(QString::fromUtf8("clientGroup"));
        clientGroup->setGeometry(QRect(20, 320, 241, 31));
        registerButton = new QPushButton(linboRegisterBox);
        registerButton->setObjectName(QString::fromUtf8("registerButton"));
        registerButton->setGeometry(QRect(20, 370, 121, 31));
        cancelButton = new QPushButton(linboRegisterBox);
        cancelButton->setObjectName(QString::fromUtf8("cancelButton"));
        cancelButton->setGeometry(QRect(170, 370, 91, 31));
        QWidget::setTabOrder(roomName, clientName);
        QWidget::setTabOrder(clientName, ipAddress);
        QWidget::setTabOrder(ipAddress, clientGroup);
        QWidget::setTabOrder(clientGroup, registerButton);
        QWidget::setTabOrder(registerButton, cancelButton);

        retranslateUi(linboRegisterBox);

        QMetaObject::connectSlotsByName(linboRegisterBox);
    } // setupUi

    void retranslateUi(QDialog *linboRegisterBox)
    {
        linboRegisterBox->setWindowTitle(QApplication::translate("linboRegisterBox", "Rechner registrieren", 0, QApplication::UnicodeUTF8));
        textLabel2->setText(QApplication::translate("linboRegisterBox", "Raumbezeichnung", 0, QApplication::UnicodeUTF8));
        textLabel3->setText(QApplication::translate("linboRegisterBox", "Rechnername", 0, QApplication::UnicodeUTF8));
        textLabel3_2->setText(QApplication::translate("linboRegisterBox", "IP-Adresse", 0, QApplication::UnicodeUTF8));
        textLabel3_2_2->setText(QApplication::translate("linboRegisterBox", "Rechnergruppe", 0, QApplication::UnicodeUTF8));
#ifndef QT_NO_TOOLTIP
        registerButton->setToolTip(QApplication::translate("linboRegisterBox", "L\303\244dt die Rechnerinformationen auf den Server hoch", 0, QApplication::UnicodeUTF8));
#endif // QT_NO_TOOLTIP
        registerButton->setText(QApplication::translate("linboRegisterBox", "Registrieren", 0, QApplication::UnicodeUTF8));
#ifndef QT_NO_TOOLTIP
        cancelButton->setToolTip(QApplication::translate("linboRegisterBox", "Abbrechen ohne Rechnerregistrierung", 0, QApplication::UnicodeUTF8));
#endif // QT_NO_TOOLTIP
        cancelButton->setText(QApplication::translate("linboRegisterBox", "Abbruch", 0, QApplication::UnicodeUTF8));
        Q_UNUSED(linboRegisterBox);
    } // retranslateUi

};

namespace Ui {
    class linboRegisterBox: public Ui_linboRegisterBox {};
} // namespace Ui

QT_END_NAMESPACE

#endif // UI_LINBOREGISTERBOX_H
