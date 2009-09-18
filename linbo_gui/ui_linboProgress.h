/********************************************************************************
** Form generated from reading ui file 'linboProgress.ui'
**
** Created: Fri Sep 18 10:34:17 2009
**      by: Qt User Interface Compiler version 4.5.2
**
** WARNING! All changes made in this file will be lost when recompiling ui file!
********************************************************************************/

#ifndef UI_LINBOPROGRESS_H
#define UI_LINBOPROGRESS_H

#include <Qt3Support/Q3MimeSourceFactory>
#include <Qt3Support/Q3ProgressBar>
#include <QtCore/QVariant>
#include <QtGui/QAction>
#include <QtGui/QApplication>
#include <QtGui/QButtonGroup>
#include <QtGui/QDialog>
#include <QtGui/QHeaderView>
#include <QtGui/QLabel>
#include <QtGui/QPushButton>

QT_BEGIN_NAMESPACE

class Ui_linboProgress
{
public:
    QLabel *progressLabel;
    Q3ProgressBar *progressBar;
    QPushButton *cancelButton;

    void setupUi(QDialog *linboProgress)
    {
        if (linboProgress->objectName().isEmpty())
            linboProgress->setObjectName(QString::fromUtf8("linboProgress"));
        linboProgress->resize(472, 106);
        linboProgress->setCursor(QCursor(static_cast<Qt::CursorShape>(3)));
        progressLabel = new QLabel(linboProgress);
        progressLabel->setObjectName(QString::fromUtf8("progressLabel"));
        progressLabel->setGeometry(QRect(20, 10, 430, 20));
        progressLabel->setAlignment(Qt::AlignCenter);
        progressLabel->setWordWrap(false);
        progressBar = new Q3ProgressBar(linboProgress);
        progressBar->setObjectName(QString::fromUtf8("progressBar"));
        progressBar->setGeometry(QRect(20, 40, 430, 21));
        progressBar->setCursor(QCursor(static_cast<Qt::CursorShape>(0)));
        progressBar->setFrameShape(QFrame::NoFrame);
        progressBar->setFrameShadow(QFrame::Sunken);
        progressBar->setPercentageVisible(false);
        cancelButton = new QPushButton(linboProgress);
        cancelButton->setObjectName(QString::fromUtf8("cancelButton"));
        cancelButton->setGeometry(QRect(190, 70, 100, 20));

        retranslateUi(linboProgress);

        QMetaObject::connectSlotsByName(linboProgress);
    } // setupUi

    void retranslateUi(QDialog *linboProgress)
    {
        linboProgress->setWindowTitle(QApplication::translate("linboProgress", "Warten...", 0, QApplication::UnicodeUTF8));
        progressLabel->setText(QApplication::translate("linboProgress", "Bitte Warten...", 0, QApplication::UnicodeUTF8));
        cancelButton->setText(QApplication::translate("linboProgress", "Abbruch", 0, QApplication::UnicodeUTF8));
        Q_UNUSED(linboProgress);
    } // retranslateUi

};

namespace Ui {
    class linboProgress: public Ui_linboProgress {};
} // namespace Ui

QT_END_NAMESPACE

#endif // UI_LINBOPROGRESS_H
