/********************************************************************************
** Form generated from reading ui file 'linboConsole.ui'
**
** Created: Fri Sep 18 10:34:16 2009
**      by: Qt User Interface Compiler version 4.5.2
**
** WARNING! All changes made in this file will be lost when recompiling ui file!
********************************************************************************/

#ifndef UI_LINBOCONSOLE_H
#define UI_LINBOCONSOLE_H

#include <Qt3Support/Q3MimeSourceFactory>
#include <QtCore/QVariant>
#include <QtGui/QAction>
#include <QtGui/QApplication>
#include <QtGui/QButtonGroup>
#include <QtGui/QDialog>
#include <QtGui/QHeaderView>
#include <QtGui/QLabel>
#include <QtGui/QLineEdit>
#include <QtGui/QTextBrowser>

QT_BEGIN_NAMESPACE

class Ui_linboConsole
{
public:
    QLabel *textLabel1;
    QLineEdit *input;
    QTextBrowser *output;

    void setupUi(QDialog *linboConsole)
    {
        if (linboConsole->objectName().isEmpty())
            linboConsole->setObjectName(QString::fromUtf8("linboConsole"));
        linboConsole->resize(382, 382);
        textLabel1 = new QLabel(linboConsole);
        textLabel1->setObjectName(QString::fromUtf8("textLabel1"));
        textLabel1->setGeometry(QRect(10, 300, 161, 31));
        textLabel1->setWordWrap(false);
        input = new QLineEdit(linboConsole);
        input->setObjectName(QString::fromUtf8("input"));
        input->setGeometry(QRect(10, 340, 361, 31));
        QFont font;
        font.setFamily(QString::fromUtf8("DejaVu Sans"));
        input->setFont(font);
        output = new QTextBrowser(linboConsole);
        output->setObjectName(QString::fromUtf8("output"));
        output->setGeometry(QRect(10, 10, 361, 291));
        output->setFont(font);

        retranslateUi(linboConsole);

        QMetaObject::connectSlotsByName(linboConsole);
    } // setupUi

    void retranslateUi(QDialog *linboConsole)
    {
        linboConsole->setWindowTitle(QApplication::translate("linboConsole", "Console", 0, QApplication::UnicodeUTF8));
        textLabel1->setText(QApplication::translate("linboConsole", "Befehl eingeben:", 0, QApplication::UnicodeUTF8));
        Q_UNUSED(linboConsole);
    } // retranslateUi

};

namespace Ui {
    class linboConsole: public Ui_linboConsole {};
} // namespace Ui

QT_END_NAMESPACE

#endif // UI_LINBOCONSOLE_H
