/********************************************************************************
** Form generated from reading ui file 'linboCounter.ui'
**
** Created: Fri Sep 18 10:34:16 2009
**      by: Qt User Interface Compiler version 4.5.2
**
** WARNING! All changes made in this file will be lost when recompiling ui file!
********************************************************************************/

#ifndef UI_LINBOCOUNTER_H
#define UI_LINBOCOUNTER_H

#include <Qt3Support/Q3MimeSourceFactory>
#include <QtCore/QVariant>
#include <QtGui/QAction>
#include <QtGui/QApplication>
#include <QtGui/QButtonGroup>
#include <QtGui/QCheckBox>
#include <QtGui/QDialog>
#include <QtGui/QHeaderView>
#include <QtGui/QLCDNumber>
#include <QtGui/QLabel>
#include <QtGui/QPushButton>

QT_BEGIN_NAMESPACE

class Ui_linboCounter
{
public:
    QLCDNumber *counter;
    QCheckBox *timeoutCheck;
    QLabel *text;
    QPushButton *logoutButton;

    void setupUi(QDialog *linboCounter)
    {
        if (linboCounter->objectName().isEmpty())
            linboCounter->setObjectName(QString::fromUtf8("linboCounter"));
        linboCounter->resize(131, 172);
        counter = new QLCDNumber(linboCounter);
        counter->setObjectName(QString::fromUtf8("counter"));
        counter->setGeometry(QRect(0, 50, 131, 41));
        counter->setFrameShape(QFrame::NoFrame);
        counter->setFrameShadow(QFrame::Raised);
        counter->setNumDigits(5);
        counter->setMode(QLCDNumber::Dec);
        counter->setSegmentStyle(QLCDNumber::Filled);
        timeoutCheck = new QCheckBox(linboCounter);
        timeoutCheck->setObjectName(QString::fromUtf8("timeoutCheck"));
        timeoutCheck->setGeometry(QRect(5, 100, 130, 30));
        timeoutCheck->setChecked(true);
        text = new QLabel(linboCounter);
        text->setObjectName(QString::fromUtf8("text"));
        text->setGeometry(QRect(10, 10, 111, 31));
        text->setAlignment(Qt::AlignCenter);
        text->setWordWrap(false);
        logoutButton = new QPushButton(linboCounter);
        logoutButton->setObjectName(QString::fromUtf8("logoutButton"));
        logoutButton->setGeometry(QRect(0, 130, 130, 40));
        logoutButton->setFlat(false);

        retranslateUi(linboCounter);

        QMetaObject::connectSlotsByName(linboCounter);
    } // setupUi

    void retranslateUi(QDialog *linboCounter)
    {
        linboCounter->setWindowTitle(QApplication::translate("linboCounter", "Root ", 0, QApplication::UnicodeUTF8));
        timeoutCheck->setText(QApplication::translate("linboCounter", "Timeout", 0, QApplication::UnicodeUTF8));
        text->setText(QApplication::translate("linboCounter", "Root Modus", 0, QApplication::UnicodeUTF8));
        logoutButton->setText(QApplication::translate("linboCounter", "LOGOUT", 0, QApplication::UnicodeUTF8));
        Q_UNUSED(linboCounter);
    } // retranslateUi

};

namespace Ui {
    class linboCounter: public Ui_linboCounter {};
} // namespace Ui

QT_END_NAMESPACE

#endif // UI_LINBOCOUNTER_H
