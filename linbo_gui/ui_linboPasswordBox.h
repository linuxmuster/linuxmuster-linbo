/********************************************************************************
** Form generated from reading ui file 'linboPasswordBox.ui'
**
** Created: Fri Sep 18 10:34:17 2009
**      by: Qt User Interface Compiler version 4.5.2
**
** WARNING! All changes made in this file will be lost when recompiling ui file!
********************************************************************************/

#ifndef UI_LINBOPASSWORDBOX_H
#define UI_LINBOPASSWORDBOX_H

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

class Ui_linboPasswordBox
{
public:
    QLabel *passwordLabel;
    QLineEdit *passwordInput;

    void setupUi(QDialog *linboPasswordBox)
    {
        if (linboPasswordBox->objectName().isEmpty())
            linboPasswordBox->setObjectName(QString::fromUtf8("linboPasswordBox"));
        linboPasswordBox->resize(190, 85);
        QSizePolicy sizePolicy(static_cast<QSizePolicy::Policy>(5), static_cast<QSizePolicy::Policy>(5));
        sizePolicy.setHorizontalStretch(0);
        sizePolicy.setVerticalStretch(0);
        sizePolicy.setHeightForWidth(linboPasswordBox->sizePolicy().hasHeightForWidth());
        linboPasswordBox->setSizePolicy(sizePolicy);
        linboPasswordBox->setCursor(QCursor(static_cast<Qt::CursorShape>(0)));
        passwordLabel = new QLabel(linboPasswordBox);
        passwordLabel->setObjectName(QString::fromUtf8("passwordLabel"));
        passwordLabel->setGeometry(QRect(10, 10, 172, 30));
        passwordLabel->setAlignment(Qt::AlignCenter);
        passwordLabel->setWordWrap(false);
        passwordInput = new QLineEdit(linboPasswordBox);
        passwordInput->setObjectName(QString::fromUtf8("passwordInput"));
        passwordInput->setGeometry(QRect(15, 40, 160, 30));
        passwordInput->setEchoMode(QLineEdit::Password);
        passwordInput->setAlignment(Qt::AlignHCenter);

        retranslateUi(linboPasswordBox);

        QMetaObject::connectSlotsByName(linboPasswordBox);
    } // setupUi

    void retranslateUi(QDialog *linboPasswordBox)
    {
        linboPasswordBox->setWindowTitle(QApplication::translate("linboPasswordBox", "Sicherheit", 0, QApplication::UnicodeUTF8));
        passwordLabel->setText(QApplication::translate("linboPasswordBox", "Bitte Passwort eingeben", 0, QApplication::UnicodeUTF8));
        Q_UNUSED(linboPasswordBox);
    } // retranslateUi

};

namespace Ui {
    class linboPasswordBox: public Ui_linboPasswordBox {};
} // namespace Ui

QT_END_NAMESPACE

#endif // UI_LINBOPASSWORDBOX_H
