/****************************************************************************
** Meta object code from reading C++ file 'linboCounterImpl.hh'
**
** Created: Fri Sep 18 10:36:51 2009
**      by: The Qt Meta Object Compiler version 61 (Qt 4.5.2)
**
** WARNING! All changes made in this file will be lost!
*****************************************************************************/

#include "linboCounterImpl.hh"
#if !defined(Q_MOC_OUTPUT_REVISION)
#error "The header file 'linboCounterImpl.hh' doesn't include <QObject>."
#elif Q_MOC_OUTPUT_REVISION != 61
#error "This file was generated using the moc from 4.5.2. It"
#error "cannot be used with the include files from this version of Qt."
#error "(The moc has changed too much.)"
#endif

QT_BEGIN_MOC_NAMESPACE
static const uint qt_meta_data_linboCounterImpl[] = {

 // content:
       2,       // revision
       0,       // classname
       0,    0, // classinfo
       2,   12, // methods
       0,    0, // properties
       0,    0, // enums/sets
       0,    0, // constructors

 // slots: signature, parameters, type, tag, flags
      18,   17,   17,   17, 0x0a,
      35,   17,   17,   17, 0x0a,

       0        // eod
};

static const char qt_meta_stringdata_linboCounterImpl[] = {
    "linboCounterImpl\0\0readFromStderr()\0"
    "readFromStdout()\0"
};

const QMetaObject linboCounterImpl::staticMetaObject = {
    { &QWidget::staticMetaObject, qt_meta_stringdata_linboCounterImpl,
      qt_meta_data_linboCounterImpl, 0 }
};

const QMetaObject *linboCounterImpl::metaObject() const
{
    return &staticMetaObject;
}

void *linboCounterImpl::qt_metacast(const char *_clname)
{
    if (!_clname) return 0;
    if (!strcmp(_clname, qt_meta_stringdata_linboCounterImpl))
        return static_cast<void*>(const_cast< linboCounterImpl*>(this));
    if (!strcmp(_clname, "Ui::linboCounter"))
        return static_cast< Ui::linboCounter*>(const_cast< linboCounterImpl*>(this));
    if (!strcmp(_clname, "linboDialog"))
        return static_cast< linboDialog*>(const_cast< linboCounterImpl*>(this));
    return QWidget::qt_metacast(_clname);
}

int linboCounterImpl::qt_metacall(QMetaObject::Call _c, int _id, void **_a)
{
    _id = QWidget::qt_metacall(_c, _id, _a);
    if (_id < 0)
        return _id;
    if (_c == QMetaObject::InvokeMetaMethod) {
        switch (_id) {
        case 0: readFromStderr(); break;
        case 1: readFromStdout(); break;
        default: ;
        }
        _id -= 2;
    }
    return _id;
}
QT_END_MOC_NAMESPACE
