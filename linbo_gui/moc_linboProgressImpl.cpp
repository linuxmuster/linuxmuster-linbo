/****************************************************************************
** Meta object code from reading C++ file 'linboProgressImpl.hh'
**
** Created: Fri Sep 18 10:37:34 2009
**      by: The Qt Meta Object Compiler version 61 (Qt 4.5.2)
**
** WARNING! All changes made in this file will be lost!
*****************************************************************************/

#include "linboProgressImpl.hh"
#if !defined(Q_MOC_OUTPUT_REVISION)
#error "The header file 'linboProgressImpl.hh' doesn't include <QObject>."
#elif Q_MOC_OUTPUT_REVISION != 61
#error "This file was generated using the moc from 4.5.2. It"
#error "cannot be used with the include files from this version of Qt."
#error "(The moc has changed too much.)"
#endif

QT_BEGIN_MOC_NAMESPACE
static const uint qt_meta_data_linboProgressImpl[] = {

 // content:
       2,       // revision
       0,       // classname
       0,    0, // classinfo
       1,   12, // methods
       0,    0, // properties
       0,    0, // enums/sets
       0,    0, // constructors

 // slots: signature, parameters, type, tag, flags
      19,   18,   18,   18, 0x0a,

       0        // eod
};

static const char qt_meta_stringdata_linboProgressImpl[] = {
    "linboProgressImpl\0\0killLinboCmd()\0"
};

const QMetaObject linboProgressImpl::staticMetaObject = {
    { &QWidget::staticMetaObject, qt_meta_stringdata_linboProgressImpl,
      qt_meta_data_linboProgressImpl, 0 }
};

const QMetaObject *linboProgressImpl::metaObject() const
{
    return &staticMetaObject;
}

void *linboProgressImpl::qt_metacast(const char *_clname)
{
    if (!_clname) return 0;
    if (!strcmp(_clname, qt_meta_stringdata_linboProgressImpl))
        return static_cast<void*>(const_cast< linboProgressImpl*>(this));
    if (!strcmp(_clname, "Ui::linboProgress"))
        return static_cast< Ui::linboProgress*>(const_cast< linboProgressImpl*>(this));
    return QWidget::qt_metacast(_clname);
}

int linboProgressImpl::qt_metacall(QMetaObject::Call _c, int _id, void **_a)
{
    _id = QWidget::qt_metacall(_c, _id, _a);
    if (_id < 0)
        return _id;
    if (_c == QMetaObject::InvokeMetaMethod) {
        switch (_id) {
        case 0: killLinboCmd(); break;
        default: ;
        }
        _id -= 1;
    }
    return _id;
}
QT_END_MOC_NAMESPACE
