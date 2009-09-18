/****************************************************************************
** Meta object code from reading C++ file 'linboYesNoImpl.hh'
**
** Created: Fri Sep 18 10:37:49 2009
**      by: The Qt Meta Object Compiler version 61 (Qt 4.5.2)
**
** WARNING! All changes made in this file will be lost!
*****************************************************************************/

#include "linboYesNoImpl.hh"
#if !defined(Q_MOC_OUTPUT_REVISION)
#error "The header file 'linboYesNoImpl.hh' doesn't include <QObject>."
#elif Q_MOC_OUTPUT_REVISION != 61
#error "This file was generated using the moc from 4.5.2. It"
#error "cannot be used with the include files from this version of Qt."
#error "(The moc has changed too much.)"
#endif

QT_BEGIN_MOC_NAMESPACE
static const uint qt_meta_data_linboYesNoImpl[] = {

 // content:
       2,       // revision
       0,       // classname
       0,    0, // classinfo
       5,   12, // methods
       0,    0, // properties
       0,    0, // enums/sets
       0,    0, // constructors

 // slots: signature, parameters, type, tag, flags
      16,   15,   15,   15, 0x0a,
      25,   15,   15,   15, 0x0a,
      35,   15,   15,   15, 0x0a,
      52,   15,   15,   15, 0x0a,
      69,   15,   15,   15, 0x09,

       0        // eod
};

static const char qt_meta_stringdata_linboYesNoImpl[] = {
    "linboYesNoImpl\0\0precmd()\0postcmd()\0"
    "readFromStdout()\0readFromStderr()\0"
    "languageChange()\0"
};

const QMetaObject linboYesNoImpl::staticMetaObject = {
    { &QWidget::staticMetaObject, qt_meta_stringdata_linboYesNoImpl,
      qt_meta_data_linboYesNoImpl, 0 }
};

const QMetaObject *linboYesNoImpl::metaObject() const
{
    return &staticMetaObject;
}

void *linboYesNoImpl::qt_metacast(const char *_clname)
{
    if (!_clname) return 0;
    if (!strcmp(_clname, qt_meta_stringdata_linboYesNoImpl))
        return static_cast<void*>(const_cast< linboYesNoImpl*>(this));
    if (!strcmp(_clname, "Ui::linboYesNo"))
        return static_cast< Ui::linboYesNo*>(const_cast< linboYesNoImpl*>(this));
    if (!strcmp(_clname, "linboDialog"))
        return static_cast< linboDialog*>(const_cast< linboYesNoImpl*>(this));
    return QWidget::qt_metacast(_clname);
}

int linboYesNoImpl::qt_metacall(QMetaObject::Call _c, int _id, void **_a)
{
    _id = QWidget::qt_metacall(_c, _id, _a);
    if (_id < 0)
        return _id;
    if (_c == QMetaObject::InvokeMetaMethod) {
        switch (_id) {
        case 0: precmd(); break;
        case 1: postcmd(); break;
        case 2: readFromStdout(); break;
        case 3: readFromStderr(); break;
        case 4: languageChange(); break;
        default: ;
        }
        _id -= 5;
    }
    return _id;
}
QT_END_MOC_NAMESPACE
