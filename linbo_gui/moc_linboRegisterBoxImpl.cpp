/****************************************************************************
** Meta object code from reading C++ file 'linboRegisterBoxImpl.hh'
**
** Created: Fri Sep 18 10:37:44 2009
**      by: The Qt Meta Object Compiler version 61 (Qt 4.5.2)
**
** WARNING! All changes made in this file will be lost!
*****************************************************************************/

#include "linboRegisterBoxImpl.hh"
#if !defined(Q_MOC_OUTPUT_REVISION)
#error "The header file 'linboRegisterBoxImpl.hh' doesn't include <QObject>."
#elif Q_MOC_OUTPUT_REVISION != 61
#error "This file was generated using the moc from 4.5.2. It"
#error "cannot be used with the include files from this version of Qt."
#error "(The moc has changed too much.)"
#endif

QT_BEGIN_MOC_NAMESPACE
static const uint qt_meta_data_linboRegisterBoxImpl[] = {

 // content:
       2,       // revision
       0,       // classname
       0,    0, // classinfo
       4,   12, // methods
       0,    0, // properties
       0,    0, // enums/sets
       0,    0, // constructors

 // slots: signature, parameters, type, tag, flags
      22,   21,   21,   21, 0x0a,
      32,   21,   21,   21, 0x0a,
      41,   21,   21,   21, 0x0a,
      58,   21,   21,   21, 0x0a,

       0        // eod
};

static const char qt_meta_stringdata_linboRegisterBoxImpl[] = {
    "linboRegisterBoxImpl\0\0postcmd()\0"
    "precmd()\0readFromStderr()\0readFromStdout()\0"
};

const QMetaObject linboRegisterBoxImpl::staticMetaObject = {
    { &QWidget::staticMetaObject, qt_meta_stringdata_linboRegisterBoxImpl,
      qt_meta_data_linboRegisterBoxImpl, 0 }
};

const QMetaObject *linboRegisterBoxImpl::metaObject() const
{
    return &staticMetaObject;
}

void *linboRegisterBoxImpl::qt_metacast(const char *_clname)
{
    if (!_clname) return 0;
    if (!strcmp(_clname, qt_meta_stringdata_linboRegisterBoxImpl))
        return static_cast<void*>(const_cast< linboRegisterBoxImpl*>(this));
    if (!strcmp(_clname, "Ui::linboRegisterBox"))
        return static_cast< Ui::linboRegisterBox*>(const_cast< linboRegisterBoxImpl*>(this));
    if (!strcmp(_clname, "linboDialog"))
        return static_cast< linboDialog*>(const_cast< linboRegisterBoxImpl*>(this));
    return QWidget::qt_metacast(_clname);
}

int linboRegisterBoxImpl::qt_metacall(QMetaObject::Call _c, int _id, void **_a)
{
    _id = QWidget::qt_metacall(_c, _id, _a);
    if (_id < 0)
        return _id;
    if (_c == QMetaObject::InvokeMetaMethod) {
        switch (_id) {
        case 0: postcmd(); break;
        case 1: precmd(); break;
        case 2: readFromStderr(); break;
        case 3: readFromStdout(); break;
        default: ;
        }
        _id -= 4;
    }
    return _id;
}
QT_END_MOC_NAMESPACE
