/********************************************************************************
** Form generated from reading ui file 'linboImageSelector.ui'
**
** Created: Fri Sep 18 10:34:16 2009
**      by: Qt User Interface Compiler version 4.5.2
**
** WARNING! All changes made in this file will be lost when recompiling ui file!
********************************************************************************/

#ifndef UI_LINBOIMAGESELECTOR_H
#define UI_LINBOIMAGESELECTOR_H

#include <Qt3Support/Q3ButtonGroup>
#include <Qt3Support/Q3Frame>
#include <Qt3Support/Q3GroupBox>
#include <Qt3Support/Q3ListBox>
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
#include <QtGui/QRadioButton>
#include <QtGui/QTextEdit>

QT_BEGIN_NAMESPACE

class Ui_linboImageSelector
{
public:
    QLabel *textLabel2;
    Q3ButtonGroup *imageButtons;
    QRadioButton *baseRadioButton;
    QRadioButton *incrRadioButton;
    QLabel *textLabel2_2;
    QLineEdit *specialName;
    QLabel *descriptionLabel;
    QPushButton *createButton;
    QPushButton *createUploadButton;
    QPushButton *cancelButton;
    Q3ListBox *listBox;
    QTextEdit *infoEditor;

    void setupUi(QDialog *linboImageSelector)
    {
        if (linboImageSelector->objectName().isEmpty())
            linboImageSelector->setObjectName(QString::fromUtf8("linboImageSelector"));
        linboImageSelector->resize(384, 471);
        textLabel2 = new QLabel(linboImageSelector);
        textLabel2->setObjectName(QString::fromUtf8("textLabel2"));
        textLabel2->setGeometry(QRect(10, 0, 360, 80));
        textLabel2->setAlignment(Qt::AlignVCenter);
        textLabel2->setWordWrap(false);
        imageButtons = new Q3ButtonGroup(linboImageSelector);
        imageButtons->setObjectName(QString::fromUtf8("imageButtons"));
        imageButtons->setGeometry(QRect(10, 160, 361, 70));
        baseRadioButton = new QRadioButton(imageButtons);
        baseRadioButton->setObjectName(QString::fromUtf8("baseRadioButton"));
        baseRadioButton->setGeometry(QRect(10, 20, 251, 20));
        baseRadioButton->setChecked(true);
        incrRadioButton = new QRadioButton(imageButtons);
        incrRadioButton->setObjectName(QString::fromUtf8("incrRadioButton"));
        incrRadioButton->setGeometry(QRect(10, 40, 251, 21));
        textLabel2_2 = new QLabel(linboImageSelector);
        textLabel2_2->setObjectName(QString::fromUtf8("textLabel2_2"));
        textLabel2_2->setGeometry(QRect(10, 240, 360, 30));
        textLabel2_2->setWordWrap(false);
        specialName = new QLineEdit(linboImageSelector);
        specialName->setObjectName(QString::fromUtf8("specialName"));
        specialName->setGeometry(QRect(10, 270, 360, 30));
        descriptionLabel = new QLabel(linboImageSelector);
        descriptionLabel->setObjectName(QString::fromUtf8("descriptionLabel"));
        descriptionLabel->setGeometry(QRect(10, 310, 360, 30));
        descriptionLabel->setWordWrap(false);
        createButton = new QPushButton(linboImageSelector);
        createButton->setObjectName(QString::fromUtf8("createButton"));
        createButton->setGeometry(QRect(10, 420, 90, 40));
        createUploadButton = new QPushButton(linboImageSelector);
        createUploadButton->setObjectName(QString::fromUtf8("createUploadButton"));
        createUploadButton->setGeometry(QRect(110, 420, 160, 40));
        cancelButton = new QPushButton(linboImageSelector);
        cancelButton->setObjectName(QString::fromUtf8("cancelButton"));
        cancelButton->setGeometry(QRect(280, 420, 90, 40));
        listBox = new Q3ListBox(linboImageSelector);
        listBox->setObjectName(QString::fromUtf8("listBox"));
        listBox->setGeometry(QRect(10, 80, 360, 72));
        listBox->setVScrollBarMode(Q3ScrollView::Auto);
        listBox->setHScrollBarMode(Q3ScrollView::Auto);
        infoEditor = new QTextEdit(linboImageSelector);
        infoEditor->setObjectName(QString::fromUtf8("infoEditor"));
        infoEditor->setGeometry(QRect(10, 340, 361, 71));
        QWidget::setTabOrder(listBox, baseRadioButton);
        QWidget::setTabOrder(baseRadioButton, specialName);
        QWidget::setTabOrder(specialName, createButton);
        QWidget::setTabOrder(createButton, createUploadButton);
        QWidget::setTabOrder(createUploadButton, cancelButton);

        retranslateUi(linboImageSelector);

        QMetaObject::connectSlotsByName(linboImageSelector);
    } // setupUi

    void retranslateUi(QDialog *linboImageSelector)
    {
        linboImageSelector->setWindowTitle(QApplication::translate("linboImageSelector", "Image erstellen", 0, QApplication::UnicodeUTF8));
#ifndef QT_NO_WHATSTHIS
        linboImageSelector->setWhatsThis(QString());
#endif // QT_NO_WHATSTHIS
        textLabel2->setText(QApplication::translate("linboImageSelector", "Vorhandenes Image neu erstellen oder [Neues Image] zur Erstellung einer neuen Image-Datei ausw\303\244hlen.\n"
"\n"
"Auswahl:", 0, QApplication::UnicodeUTF8));
        imageButtons->setTitle(QApplication::translate("linboImageSelector", "Image-Typ f\303\274r neue Image-Datei:", 0, QApplication::UnicodeUTF8));
        baseRadioButton->setText(QApplication::translate("linboImageSelector", "Neues Basisimage", 0, QApplication::UnicodeUTF8));
        incrRadioButton->setText(QApplication::translate("linboImageSelector", "Differentielles Image", 0, QApplication::UnicodeUTF8));
        textLabel2_2->setText(QApplication::translate("linboImageSelector", "Dateiname f\303\274r neue Imagedatei eingeben:", 0, QApplication::UnicodeUTF8));
        specialName->setText(QApplication::translate("linboImageSelector", "Neu", 0, QApplication::UnicodeUTF8));
        descriptionLabel->setText(QApplication::translate("linboImageSelector", "Informationen zum Image:", 0, QApplication::UnicodeUTF8));
#ifndef QT_NO_TOOLTIP
        createButton->setToolTip(QApplication::translate("linboImageSelector", "Erstellt das ausgew\303\244hlte Image<br>im lokalen Cache", 0, QApplication::UnicodeUTF8));
#endif // QT_NO_TOOLTIP
        createButton->setText(QApplication::translate("linboImageSelector", "Erstellen", 0, QApplication::UnicodeUTF8));
#ifndef QT_NO_TOOLTIP
        createUploadButton->setToolTip(QApplication::translate("linboImageSelector", "Erstellt das ausgew\303\244hlte Image im lokalen Cache und l\303\244dt es <br> anschliessend auf den Server hoch", 0, QApplication::UnicodeUTF8));
#endif // QT_NO_TOOLTIP
        createUploadButton->setText(QApplication::translate("linboImageSelector", "Erstellen+Hochladen", 0, QApplication::UnicodeUTF8));
#ifndef QT_NO_TOOLTIP
        cancelButton->setToolTip(QApplication::translate("linboImageSelector", "Abbrechen ohne Imageerstellung", 0, QApplication::UnicodeUTF8));
#endif // QT_NO_TOOLTIP
        cancelButton->setText(QApplication::translate("linboImageSelector", "Abbruch", 0, QApplication::UnicodeUTF8));
        listBox->clear();
        listBox->insertItem(QApplication::translate("linboImageSelector", "New Item", 0, QApplication::UnicodeUTF8));
        Q_UNUSED(linboImageSelector);
    } // retranslateUi

};

namespace Ui {
    class linboImageSelector: public Ui_linboImageSelector {};
} // namespace Ui

QT_END_NAMESPACE

#endif // UI_LINBOIMAGESELECTOR_H
