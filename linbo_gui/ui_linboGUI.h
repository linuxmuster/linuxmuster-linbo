/********************************************************************************
** Form generated from reading ui file 'linboGUI.ui'
**
** Created: Fri Sep 18 10:34:16 2009
**      by: Qt User Interface Compiler version 4.5.2
**
** WARNING! All changes made in this file will be lost when recompiling ui file!
********************************************************************************/

#ifndef UI_LINBOGUI_H
#define UI_LINBOGUI_H

#include <Qt3Support/Q3Frame>
#include <Qt3Support/Q3ScrollView>
#include <Qt3Support/Q3TextBrowser>
#include <Qt3Support/Q3TextEdit>
#include <QtCore/QVariant>
#include <QtGui/QAction>
#include <QtGui/QApplication>
#include <QtGui/QButtonGroup>
#include <QtGui/QDialog>
#include <QtGui/QHeaderView>
#include <QtGui/QLabel>
#include <QtGui/QPushButton>
#include <QtGui/QTabWidget>
#include <QtGui/QWidget>
#include "Qt3Support/Q3ScrollView"

QT_BEGIN_NAMESPACE

class Ui_linboGUI
{
public:
    QLabel *ConsoleLabel;
    Q3TextBrowser *Console;
    QTabWidget *Tabs;
    QWidget *tab;
    Q3ScrollView *startView;
    QWidget *tab1;
    Q3ScrollView *imagingView;
    QPushButton *shutdownButton;
    QPushButton *rebootButton;
    QLabel *timeLabel;
    QLabel *serverIPLabel;
    QLabel *clientIPLabel;
    QLabel *macLabel;
    QLabel *cpuLabel;
    QLabel *memLabel;
    QLabel *nameandgroup;
    QLabel *hdLabel;
    QLabel *cacheLabel;

    void setupUi(QDialog *linboGUI)
    {
        if (linboGUI->objectName().isEmpty())
            linboGUI->setObjectName(QString::fromUtf8("linboGUI"));
        linboGUI->resize(640, 479);
        linboGUI->setMaximumSize(QSize(640, 480));
        linboGUI->setSizeGripEnabled(false);
        linboGUI->setModal(false);
        ConsoleLabel = new QLabel(linboGUI);
        ConsoleLabel->setObjectName(QString::fromUtf8("ConsoleLabel"));
        ConsoleLabel->setGeometry(QRect(10, 370, 141, 20));
        ConsoleLabel->setWordWrap(false);
        Console = new Q3TextBrowser(linboGUI);
        Console->setObjectName(QString::fromUtf8("Console"));
        Console->setGeometry(QRect(10, 390, 620, 80));
        Tabs = new QTabWidget(linboGUI);
        Tabs->setObjectName(QString::fromUtf8("Tabs"));
        Tabs->setGeometry(QRect(10, 60, 620, 300));
        tab = new QWidget();
        tab->setObjectName(QString::fromUtf8("tab"));
        startView = new Q3ScrollView(tab);
        startView->setObjectName(QString::fromUtf8("startView"));
        startView->setGeometry(QRect(10, 10, 600, 250));
        startView->setAutoFillBackground(true);
        Tabs->addTab(tab, QString());
        tab1 = new QWidget();
        tab1->setObjectName(QString::fromUtf8("tab1"));
        tab1->setAutoFillBackground(true);
        imagingView = new Q3ScrollView(tab1);
        imagingView->setObjectName(QString::fromUtf8("imagingView"));
        imagingView->setGeometry(QRect(10, 10, 600, 250));
        imagingView->setAutoFillBackground(true);
        Tabs->addTab(tab1, QString());
        shutdownButton = new QPushButton(linboGUI);
        shutdownButton->setObjectName(QString::fromUtf8("shutdownButton"));
        shutdownButton->setGeometry(QRect(440, 360, 90, 21));
        rebootButton = new QPushButton(linboGUI);
        rebootButton->setObjectName(QString::fromUtf8("rebootButton"));
        rebootButton->setGeometry(QRect(540, 360, 90, 21));
        timeLabel = new QLabel(linboGUI);
        timeLabel->setObjectName(QString::fromUtf8("timeLabel"));
        timeLabel->setGeometry(QRect(570, 10, 70, 15));
        QFont font;
        font.setPointSize(8);
        timeLabel->setFont(font);
        timeLabel->setAlignment(Qt::AlignHCenter|Qt::AlignTop);
        timeLabel->setWordWrap(false);
        serverIPLabel = new QLabel(linboGUI);
        serverIPLabel->setObjectName(QString::fromUtf8("serverIPLabel"));
        serverIPLabel->setGeometry(QRect(10, 10, 120, 15));
        serverIPLabel->setFont(font);
        serverIPLabel->setAlignment(Qt::AlignLeading|Qt::AlignLeft|Qt::AlignTop);
        serverIPLabel->setWordWrap(false);
        clientIPLabel = new QLabel(linboGUI);
        clientIPLabel->setObjectName(QString::fromUtf8("clientIPLabel"));
        clientIPLabel->setGeometry(QRect(130, 10, 120, 15));
        clientIPLabel->setFont(font);
        clientIPLabel->setAlignment(Qt::AlignLeading|Qt::AlignLeft|Qt::AlignTop);
        clientIPLabel->setWordWrap(false);
        macLabel = new QLabel(linboGUI);
        macLabel->setObjectName(QString::fromUtf8("macLabel"));
        macLabel->setGeometry(QRect(250, 10, 130, 16));
        macLabel->setFont(font);
        macLabel->setAlignment(Qt::AlignLeading|Qt::AlignLeft|Qt::AlignTop);
        macLabel->setWordWrap(false);
        cpuLabel = new QLabel(linboGUI);
        cpuLabel->setObjectName(QString::fromUtf8("cpuLabel"));
        cpuLabel->setGeometry(QRect(10, 30, 240, 16));
        cpuLabel->setFont(font);
        cpuLabel->setAlignment(Qt::AlignLeading|Qt::AlignLeft|Qt::AlignTop);
        cpuLabel->setWordWrap(false);
        memLabel = new QLabel(linboGUI);
        memLabel->setObjectName(QString::fromUtf8("memLabel"));
        memLabel->setGeometry(QRect(250, 30, 130, 20));
        memLabel->setFont(font);
        memLabel->setAlignment(Qt::AlignLeading|Qt::AlignLeft|Qt::AlignTop);
        memLabel->setWordWrap(false);
        nameandgroup = new QLabel(linboGUI);
        nameandgroup->setObjectName(QString::fromUtf8("nameandgroup"));
        nameandgroup->setGeometry(QRect(380, 30, 250, 20));
        nameandgroup->setFont(font);
        nameandgroup->setAlignment(Qt::AlignLeading|Qt::AlignLeft|Qt::AlignTop);
        nameandgroup->setWordWrap(false);
        hdLabel = new QLabel(linboGUI);
        hdLabel->setObjectName(QString::fromUtf8("hdLabel"));
        hdLabel->setGeometry(QRect(380, 10, 70, 16));
        hdLabel->setFont(font);
        hdLabel->setAlignment(Qt::AlignLeading|Qt::AlignLeft|Qt::AlignTop);
        hdLabel->setWordWrap(false);
        cacheLabel = new QLabel(linboGUI);
        cacheLabel->setObjectName(QString::fromUtf8("cacheLabel"));
        cacheLabel->setGeometry(QRect(450, 10, 130, 20));
        cacheLabel->setFont(font);
        cacheLabel->setAlignment(Qt::AlignLeading|Qt::AlignLeft|Qt::AlignTop);
        cacheLabel->setWordWrap(false);

        retranslateUi(linboGUI);

        Tabs->setCurrentIndex(0);


        QMetaObject::connectSlotsByName(linboGUI);
    } // setupUi

    void retranslateUi(QDialog *linboGUI)
    {
        linboGUI->setWindowTitle(QApplication::translate("linboGUI", "LINBO", 0, QApplication::UnicodeUTF8));
        ConsoleLabel->setText(QApplication::translate("linboGUI", "LINBO Console", 0, QApplication::UnicodeUTF8));
        Console->setText(QApplication::translate("linboGUI", "Welcome to LINBO\n"
"All local partitions OK.\n"
"Waiting for user input.", 0, QApplication::UnicodeUTF8));
        Tabs->setTabText(Tabs->indexOf(tab), QApplication::translate("linboGUI", "Start", 0, QApplication::UnicodeUTF8));
        Tabs->setTabText(Tabs->indexOf(tab1), QApplication::translate("linboGUI", "Imaging", 0, QApplication::UnicodeUTF8));
        shutdownButton->setText(QApplication::translate("linboGUI", "Shutdown", 0, QApplication::UnicodeUTF8));
        rebootButton->setText(QApplication::translate("linboGUI", "Reboot", 0, QApplication::UnicodeUTF8));
        timeLabel->setText(QApplication::translate("linboGUI", "Uhrzeit", 0, QApplication::UnicodeUTF8));
        serverIPLabel->setText(QApplication::translate("linboGUI", "Server IP", 0, QApplication::UnicodeUTF8));
        clientIPLabel->setText(QApplication::translate("linboGUI", "Client IP", 0, QApplication::UnicodeUTF8));
        macLabel->setText(QApplication::translate("linboGUI", "MAC", 0, QApplication::UnicodeUTF8));
        cpuLabel->setText(QApplication::translate("linboGUI", "CPU", 0, QApplication::UnicodeUTF8));
        memLabel->setText(QApplication::translate("linboGUI", "Memory", 0, QApplication::UnicodeUTF8));
        nameandgroup->setText(QApplication::translate("linboGUI", "nameandgroup", 0, QApplication::UnicodeUTF8));
        hdLabel->setText(QApplication::translate("linboGUI", "hdsize", 0, QApplication::UnicodeUTF8));
        cacheLabel->setText(QApplication::translate("linboGUI", "cachesize", 0, QApplication::UnicodeUTF8));
        Q_UNUSED(linboGUI);
    } // retranslateUi

};

namespace Ui {
    class linboGUI: public Ui_linboGUI {};
} // namespace Ui

QT_END_NAMESPACE

#endif // UI_LINBOGUI_H
