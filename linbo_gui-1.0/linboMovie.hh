/****************************************************************************
** Form interface generated from reading ui file 'linboMovie.ui'
**
** Created: Sa Jul 11 23:31:29 2009
**
** WARNING! All changes made in this file will be lost!
****************************************************************************/

#ifndef LINBOMOVIE_H
#define LINBOMOVIE_H

#include <qvariant.h>
#include <qpixmap.h>
#include <qdialog.h>
//Added by qt3to4:
#include <Q3GridLayout>
#include <QLabel>
#include <Q3HBoxLayout>
#include <Q3VBoxLayout>

class Q3VBoxLayout;
class Q3HBoxLayout;
class Q3GridLayout;
class QSpacerItem;
class QLabel;
class QPushButton;

class linboMovie : public QDialog
{
    Q_OBJECT

public:
    linboMovie( QWidget* parent = 0, const char* name = 0, bool modal = FALSE, Qt::WFlags fl = 0 );
    ~linboMovie();

    QLabel* pictureLabel;
    QPushButton* logoutButton;

protected:

protected slots:
    virtual void languageChange();

private:
    QPixmap image0;

};

#endif // LINBOMOVIE_H
