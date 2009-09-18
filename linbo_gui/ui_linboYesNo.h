/********************************************************************************
** Form generated from reading ui file 'linboYesNo.ui'
**
** Created: Fri Sep 18 10:34:17 2009
**      by: Qt User Interface Compiler version 4.5.2
**
** WARNING! All changes made in this file will be lost when recompiling ui file!
********************************************************************************/

#ifndef UI_LINBOYESNO_H
#define UI_LINBOYESNO_H

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

class Ui_linboYesNo
{
public:
    QPushButton *NoButton;
    QLabel *question;
    QPushButton *YesButton;

    void setupUi(QDialog *linboYesNo)
    {
        if (linboYesNo->objectName().isEmpty())
            linboYesNo->setObjectName(QString::fromUtf8("linboYesNo"));
        linboYesNo->resize(380, 113);
        NoButton = new QPushButton(linboYesNo);
        NoButton->setObjectName(QString::fromUtf8("NoButton"));
        NoButton->setGeometry(QRect(250, 70, 81, 31));
        question = new QLabel(linboYesNo);
        question->setObjectName(QString::fromUtf8("question"));
        question->setGeometry(QRect(10, 10, 370, 41));
        QFont font;
        question->setFont(font);
        question->setAlignment(Qt::AlignCenter);
        question->setWordWrap(false);
        YesButton = new QPushButton(linboYesNo);
        YesButton->setObjectName(QString::fromUtf8("YesButton"));
        YesButton->setGeometry(QRect(50, 70, 81, 31));

        retranslateUi(linboYesNo);

        QMetaObject::connectSlotsByName(linboYesNo);
    } // setupUi

    void retranslateUi(QDialog *linboYesNo)
    {
        linboYesNo->setWindowTitle(QApplication::translate("linboYesNo", "Frage", 0, QApplication::UnicodeUTF8));
        NoButton->setText(QApplication::translate("linboYesNo", "Nein", 0, QApplication::UnicodeUTF8));
        question->setText(QApplication::translate("linboYesNo", "Frage", 0, QApplication::UnicodeUTF8));
        YesButton->setText(QApplication::translate("linboYesNo", "Ja", 0, QApplication::UnicodeUTF8));
        Q_UNUSED(linboYesNo);
    } // retranslateUi

};

namespace Ui {
    class linboYesNo: public Ui_linboYesNo {};
} // namespace Ui

QT_END_NAMESPACE

#endif // UI_LINBOYESNO_H
