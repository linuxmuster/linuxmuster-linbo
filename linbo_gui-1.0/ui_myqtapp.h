/********************************************************************************
** Form generated from reading ui file 'myqtapp.ui'
**
** Created: Mon Jul 13 20:27:34 2009
**      by: Qt User Interface Compiler version 4.5.2
**
** WARNING! All changes made in this file will be lost when recompiling ui file!
********************************************************************************/

#ifndef UI_MYQTAPP_H
#define UI_MYQTAPP_H

#include <QtCore/QVariant>
#include <QtGui/QAction>
#include <QtGui/QApplication>
#include <QtGui/QButtonGroup>
#include <QtGui/QCheckBox>
#include <QtGui/QComboBox>
#include <QtGui/QHeaderView>
#include <QtGui/QLabel>
#include <QtGui/QLineEdit>
#include <QtGui/QPushButton>
#include <QtGui/QSpinBox>
#include <QtGui/QTextEdit>
#include <QtGui/QWidget>

QT_BEGIN_NAMESPACE

class Ui_myQtAppDLG
{
public:
    QLabel *label;
    QLabel *label_2;
    QLabel *label_3;
    QPushButton *pushButton_do;
    QPushButton *pushButton_clear;
    QPushButton *pushButton_about;
    QSpinBox *spinBox2;
    QTextEdit *textEdit;
    QSpinBox *spinBox1;
    QCheckBox *checkBox;
    QPushButton *pushButton_browse;
    QComboBox *comboBox;
    QLineEdit *lineEdit;

    void setupUi(QWidget *myQtAppDLG)
    {
        if (myQtAppDLG->objectName().isEmpty())
            myQtAppDLG->setObjectName(QString::fromUtf8("myQtAppDLG"));
        myQtAppDLG->resize(390, 280);
        myQtAppDLG->setMinimumSize(QSize(390, 280));
        myQtAppDLG->setMaximumSize(QSize(390, 280));
        label = new QLabel(myQtAppDLG);
        label->setObjectName(QString::fromUtf8("label"));
        label->setGeometry(QRect(20, 50, 51, 21));
        label_2 = new QLabel(myQtAppDLG);
        label_2->setObjectName(QString::fromUtf8("label_2"));
        label_2->setGeometry(QRect(20, 80, 61, 21));
        label_3 = new QLabel(myQtAppDLG);
        label_3->setObjectName(QString::fromUtf8("label_3"));
        label_3->setGeometry(QRect(20, 10, 31, 21));
        QSizePolicy sizePolicy(static_cast<QSizePolicy::Policy>(0), static_cast<QSizePolicy::Policy>(0));
        sizePolicy.setHorizontalStretch(0);
        sizePolicy.setVerticalStretch(0);
        sizePolicy.setHeightForWidth(label_3->sizePolicy().hasHeightForWidth());
        label_3->setSizePolicy(sizePolicy);
        pushButton_do = new QPushButton(myQtAppDLG);
        pushButton_do->setObjectName(QString::fromUtf8("pushButton_do"));
        pushButton_do->setGeometry(QRect(20, 250, 91, 24));
        pushButton_clear = new QPushButton(myQtAppDLG);
        pushButton_clear->setObjectName(QString::fromUtf8("pushButton_clear"));
        pushButton_clear->setGeometry(QRect(170, 250, 75, 24));
        pushButton_about = new QPushButton(myQtAppDLG);
        pushButton_about->setObjectName(QString::fromUtf8("pushButton_about"));
        pushButton_about->setGeometry(QRect(300, 250, 75, 24));
        spinBox2 = new QSpinBox(myQtAppDLG);
        spinBox2->setObjectName(QString::fromUtf8("spinBox2"));
        spinBox2->setGeometry(QRect(80, 80, 46, 22));
        textEdit = new QTextEdit(myQtAppDLG);
        textEdit->setObjectName(QString::fromUtf8("textEdit"));
        textEdit->setGeometry(QRect(20, 120, 351, 121));
        spinBox1 = new QSpinBox(myQtAppDLG);
        spinBox1->setObjectName(QString::fromUtf8("spinBox1"));
        spinBox1->setGeometry(QRect(80, 50, 46, 22));
        checkBox = new QCheckBox(myQtAppDLG);
        checkBox->setObjectName(QString::fromUtf8("checkBox"));
        checkBox->setGeometry(QRect(140, 50, 70, 19));
        pushButton_browse = new QPushButton(myQtAppDLG);
        pushButton_browse->setObjectName(QString::fromUtf8("pushButton_browse"));
        pushButton_browse->setGeometry(QRect(300, 10, 75, 24));
        sizePolicy.setHeightForWidth(pushButton_browse->sizePolicy().hasHeightForWidth());
        pushButton_browse->setSizePolicy(sizePolicy);
        comboBox = new QComboBox(myQtAppDLG);
        comboBox->setObjectName(QString::fromUtf8("comboBox"));
        comboBox->setGeometry(QRect(140, 80, 111, 22));
        lineEdit = new QLineEdit(myQtAppDLG);
        lineEdit->setObjectName(QString::fromUtf8("lineEdit"));
        lineEdit->setGeometry(QRect(60, 10, 231, 22));

        retranslateUi(myQtAppDLG);

        QMetaObject::connectSlotsByName(myQtAppDLG);
    } // setupUi

    void retranslateUi(QWidget *myQtAppDLG)
    {
        myQtAppDLG->setWindowTitle(QApplication::translate("myQtAppDLG", "My first Qt GUI App", 0, QApplication::UnicodeUTF8));
        label->setText(QApplication::translate("myQtAppDLG", "Number 1", 0, QApplication::UnicodeUTF8));
        label_2->setText(QApplication::translate("myQtAppDLG", "Number 2", 0, QApplication::UnicodeUTF8));
        label_3->setText(QApplication::translate("myQtAppDLG", "File", 0, QApplication::UnicodeUTF8));
        pushButton_do->setText(QApplication::translate("myQtAppDLG", "Do something", 0, QApplication::UnicodeUTF8));
        pushButton_clear->setText(QApplication::translate("myQtAppDLG", "Clear", 0, QApplication::UnicodeUTF8));
        pushButton_about->setText(QApplication::translate("myQtAppDLG", "About", 0, QApplication::UnicodeUTF8));
        textEdit->setHtml(QApplication::translate("myQtAppDLG", "<html><head><meta name=\"qrichtext\" content=\"1\" /><style type=\"text/css\">\n"
"p, li { white-space: pre-wrap; }\n"
"</style></head><body style=\" font-family:MS Shell Dlg 2; font-size:8.25pt; font-weight:400; font-style:normal; text-decoration:none;\">\n"
"<p style=\" margin-top:0px; margin-bottom:0px; margin-left:0px; margin-right:0px; -qt-block-indent:0; text-indent:0px; font-family:MS; font-size:8pt;\">this is textEdit</p></body></html>", 0, QApplication::UnicodeUTF8));
        checkBox->setText(QApplication::translate("myQtAppDLG", "Yes or No", 0, QApplication::UnicodeUTF8));
        pushButton_browse->setText(QApplication::translate("myQtAppDLG", "Browse..", 0, QApplication::UnicodeUTF8));
        comboBox->clear();
        comboBox->insertItems(0, QStringList()
         << QApplication::translate("myQtAppDLG", "Apple", 0, QApplication::UnicodeUTF8)
         << QApplication::translate("myQtAppDLG", "Banana", 0, QApplication::UnicodeUTF8)
         << QApplication::translate("myQtAppDLG", "Orange", 0, QApplication::UnicodeUTF8)
         << QApplication::translate("myQtAppDLG", "Whatever", 0, QApplication::UnicodeUTF8)
        );
        Q_UNUSED(myQtAppDLG);
    } // retranslateUi

};

namespace Ui {
    class myQtAppDLG: public Ui_myQtAppDLG {};
} // namespace Ui

QT_END_NAMESPACE

#endif // UI_MYQTAPP_H
