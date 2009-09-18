/********************************************************************************
** Form generated from reading ui file 'linboInfoBrowser.ui'
**
** Created: Fri Sep 18 10:34:16 2009
**      by: Qt User Interface Compiler version 4.5.2
**
** WARNING! All changes made in this file will be lost when recompiling ui file!
********************************************************************************/

#ifndef UI_LINBOINFOBROWSER_H
#define UI_LINBOINFOBROWSER_H

#include <Qt3Support/Q3Frame>
#include <Qt3Support/Q3MimeSourceFactory>
#include <Qt3Support/Q3TextEdit>
#include <QtCore/QVariant>
#include <QtGui/QAction>
#include <QtGui/QApplication>
#include <QtGui/QButtonGroup>
#include <QtGui/QDialog>
#include <QtGui/QHeaderView>
#include <QtGui/QPushButton>

QT_BEGIN_NAMESPACE

class Ui_linboInfoBrowser
{
public:
    Q3TextEdit *editor;
    QPushButton *saveButton;

    void setupUi(QDialog *linboInfoBrowser)
    {
        if (linboInfoBrowser->objectName().isEmpty())
            linboInfoBrowser->setObjectName(QString::fromUtf8("linboInfoBrowser"));
        linboInfoBrowser->resize(362, 292);
        editor = new Q3TextEdit(linboInfoBrowser);
        editor->setObjectName(QString::fromUtf8("editor"));
        editor->setGeometry(QRect(10, 10, 340, 230));
        editor->setReadOnly(true);
        saveButton = new QPushButton(linboInfoBrowser);
        saveButton->setObjectName(QString::fromUtf8("saveButton"));
        saveButton->setEnabled(false);
        saveButton->setGeometry(QRect(120, 250, 121, 31));

        retranslateUi(linboInfoBrowser);

        QMetaObject::connectSlotsByName(linboInfoBrowser);
    } // setupUi

    void retranslateUi(QDialog *linboInfoBrowser)
    {
        linboInfoBrowser->setWindowTitle(QApplication::translate("linboInfoBrowser", "Image Info", 0, QApplication::UnicodeUTF8));
        saveButton->setText(QApplication::translate("linboInfoBrowser", "Speichern", 0, QApplication::UnicodeUTF8));
        Q_UNUSED(linboInfoBrowser);
    } // retranslateUi

};

namespace Ui {
    class linboInfoBrowser: public Ui_linboInfoBrowser {};
} // namespace Ui

QT_END_NAMESPACE

#endif // UI_LINBOINFOBROWSER_H
