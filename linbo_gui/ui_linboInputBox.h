/********************************************************************************
** Form generated from reading ui file 'linboInputBox.ui'
**
** Created: Fri Sep 18 10:34:16 2009
**      by: Qt User Interface Compiler version 4.5.2
**
** WARNING! All changes made in this file will be lost when recompiling ui file!
********************************************************************************/

#ifndef UI_LINBOINPUTBOX_H
#define UI_LINBOINPUTBOX_H

#include <Qt3Support/Q3MimeSourceFactory>
#include <QtCore/QVariant>
#include <QtGui/QAction>
#include <QtGui/QApplication>
#include <QtGui/QButtonGroup>
#include <QtGui/QDialog>
#include <QtGui/QHeaderView>
#include <QtGui/QLabel>
#include <QtGui/QLineEdit>

QT_BEGIN_NAMESPACE

class Ui_linboInputBox
{
public:
    QLabel *inputLabel;
    QLineEdit *input;

    void setupUi(QDialog *linboInputBox)
    {
        if (linboInputBox->objectName().isEmpty())
            linboInputBox->setObjectName(QString::fromUtf8("linboInputBox"));
        linboInputBox->resize(202, 85);
        QSizePolicy sizePolicy(static_cast<QSizePolicy::Policy>(5), static_cast<QSizePolicy::Policy>(5));
        sizePolicy.setHorizontalStretch(0);
        sizePolicy.setVerticalStretch(0);
        sizePolicy.setHeightForWidth(linboInputBox->sizePolicy().hasHeightForWidth());
        linboInputBox->setSizePolicy(sizePolicy);
        linboInputBox->setCursor(QCursor(static_cast<Qt::CursorShape>(0)));
        inputLabel = new QLabel(linboInputBox);
        inputLabel->setObjectName(QString::fromUtf8("inputLabel"));
        inputLabel->setGeometry(QRect(10, 10, 180, 30));
        inputLabel->setAlignment(Qt::AlignCenter);
        inputLabel->setWordWrap(false);
        input = new QLineEdit(linboInputBox);
        input->setObjectName(QString::fromUtf8("input"));
        input->setGeometry(QRect(20, 40, 160, 30));
        input->setEchoMode(QLineEdit::Normal);
        input->setAlignment(Qt::AlignHCenter);

        retranslateUi(linboInputBox);

        QMetaObject::connectSlotsByName(linboInputBox);
    } // setupUi

    void retranslateUi(QDialog *linboInputBox)
    {
        linboInputBox->setWindowTitle(QApplication::translate("linboInputBox", "Eingabe", 0, QApplication::UnicodeUTF8));
        inputLabel->setText(QApplication::translate("linboInputBox", "Dateinamen eingeben", 0, QApplication::UnicodeUTF8));
        Q_UNUSED(linboInputBox);
    } // retranslateUi

};

namespace Ui {
    class linboInputBox: public Ui_linboInputBox {};
} // namespace Ui

QT_END_NAMESPACE

#endif // UI_LINBOINPUTBOX_H
