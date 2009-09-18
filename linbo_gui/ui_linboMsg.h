/********************************************************************************
** Form generated from reading ui file 'linboMsg.ui'
**
** Created: Fri Sep 18 10:34:17 2009
**      by: Qt User Interface Compiler version 4.5.2
**
** WARNING! All changes made in this file will be lost when recompiling ui file!
********************************************************************************/

#ifndef UI_LINBOMSG_H
#define UI_LINBOMSG_H

#include <Qt3Support/Q3MimeSourceFactory>
#include <QtCore/QVariant>
#include <QtGui/QAction>
#include <QtGui/QApplication>
#include <QtGui/QButtonGroup>
#include <QtGui/QDialog>
#include <QtGui/QHeaderView>
#include <QtGui/QLabel>

QT_BEGIN_NAMESPACE

class Ui_linboMsg
{
public:
    QLabel *message;

    void setupUi(QDialog *linboMsg)
    {
        if (linboMsg->objectName().isEmpty())
            linboMsg->setObjectName(QString::fromUtf8("linboMsg"));
        linboMsg->resize(323, 149);
        message = new QLabel(linboMsg);
        message->setObjectName(QString::fromUtf8("message"));
        message->setGeometry(QRect(10, 10, 301, 140));
        message->setAlignment(Qt::AlignCenter);
        message->setWordWrap(false);

        retranslateUi(linboMsg);

        QMetaObject::connectSlotsByName(linboMsg);
    } // setupUi

    void retranslateUi(QDialog *linboMsg)
    {
        linboMsg->setWindowTitle(QApplication::translate("linboMsg", "Mitteilung", 0, QApplication::UnicodeUTF8));
        message->setText(QApplication::translate("linboMsg", "Ein Fehler trat auf. Bitte nehmen Sie diesen Fehler zur kenntnis.", 0, QApplication::UnicodeUTF8));
        Q_UNUSED(linboMsg);
    } // retranslateUi

};

namespace Ui {
    class linboMsg: public Ui_linboMsg {};
} // namespace Ui

QT_END_NAMESPACE

#endif // UI_LINBOMSG_H
