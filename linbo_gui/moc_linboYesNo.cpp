/****************************************************************************
** Meta object code from reading C++ file 'linboYesNo.hh'
**
** Created: Tue Jul 14 14:59:34 2009
**      by: The Qt Meta Object Compiler version 61 (Qt 4.5.2)
**
** WARNING! All changes made in this file will be lost!
*****************************************************************************/

#include "linboYesNo.hh"
#if !defined(Q_MOC_OUTPUT_REVISION)
#error "The header file 'linboYesNo.hh' doesn't include <QObject>."
#elif Q_MOC_OUTPUT_REVISION != 61
#error "This file was generated using the moc from 4.5.2. It"
#error "cannot be used with the include files from this version of Qt."
#error "(The moc has changed too much.)"
#endif

QT_BEGIN_MOC_NAMESPACE
static const uint qt_meta_data_linboYesNo[] = {

 // content:
       2,       // revision
       0,       // classname
       0,    0, // classinfo
       1,   12, // methods
       0,    0, // properties
       0,    0, // enums/sets
       0,    0, // constructors

 // slots: signature, parameters, type, tag, flags
      12,   11,   11,   11, 0x09,

       0        // eod
};

static const char qt_meta_stringdata_linboYesNo[] = {
    "linboYesNo\0\0languageChange()\0"
};

const QMetaObject linboYesNo::staticMetaObject = {
    { &QDialog::staticMetaObject, qt_meta_stringdata_linboYesNo,
      qt_meta_data_linboYesNo, 0 }
};

const QMetaObject *linboYesNo::metaObject() const
{
    return &staticMetaObject;
}

void *linboYesNo::qt_metacast(const char *_clname)
{
    if (!_clname) return 0;
    if (!strcmp(_clname, qt_meta_stringdata_linboYesNo))
        return static_cast<void*>(const_cast< linboYesNo*>(this));
    if (!strcmp(_clname, "Ui::linboYesNo"))
        return static_cast< Ui::linboYesNo*>(const_cast< linboYesNo*>(this));
    return QDialog::qt_metacast(_clname);
}

int linboYesNo::qt_metacall(QMetaObject::Call _c, int _id, void **_a)
{
    _id = QDialog::qt_metacall(_c, _id, _a);
    if (_id < 0)
        return _id;
    if (_c == QMetaObject::InvokeMetaMethod) {
        switch (_id) {
        case 0: languageChange(); break;
        default: ;
        }
        _id -= 1;
    }
    return _id;
}
QT_END_MOC_NAMESPACE
