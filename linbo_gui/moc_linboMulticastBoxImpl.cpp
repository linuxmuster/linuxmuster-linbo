/****************************************************************************
** Meta object code from reading C++ file 'linboMulticastBoxImpl.hh'
**
** Created: Fri Sep 18 10:37:24 2009
**      by: The Qt Meta Object Compiler version 61 (Qt 4.5.2)
**
** WARNING! All changes made in this file will be lost!
*****************************************************************************/

#include "linboMulticastBoxImpl.hh"
#if !defined(Q_MOC_OUTPUT_REVISION)
#error "The header file 'linboMulticastBoxImpl.hh' doesn't include <QObject>."
#elif Q_MOC_OUTPUT_REVISION != 61
#error "This file was generated using the moc from 4.5.2. It"
#error "cannot be used with the include files from this version of Qt."
#error "(The moc has changed too much.)"
#endif

QT_BEGIN_MOC_NAMESPACE
static const uint qt_meta_data_linboMulticastBoxImpl[] = {

 // content:
       2,       // revision
       0,       // classname
       0,    0, // classinfo
       4,   12, // methods
       0,    0, // properties
       0,    0, // enums/sets
       0,    0, // constructors

 // slots: signature, parameters, type, tag, flags
      23,   22,   22,   22, 0x0a,
      40,   22,   22,   22, 0x0a,
      57,   22,   22,   22, 0x0a,
      66,   22,   22,   22, 0x0a,

       0        // eod
};

static const char qt_meta_stringdata_linboMulticastBoxImpl[] = {
    "linboMulticastBoxImpl\0\0readFromStdout()\0"
    "readFromStderr()\0precmd()\0postcmd()\0"
};

const QMetaObject linboMulticastBoxImpl::staticMetaObject = {
    { &QWidget::staticMetaObject, qt_meta_stringdata_linboMulticastBoxImpl,
      qt_meta_data_linboMulticastBoxImpl, 0 }
};

const QMetaObject *linboMulticastBoxImpl::metaObject() const
{
    return &staticMetaObject;
}

void *linboMulticastBoxImpl::qt_metacast(const char *_clname)
{
    if (!_clname) return 0;
    if (!strcmp(_clname, qt_meta_stringdata_linboMulticastBoxImpl))
        return static_cast<void*>(const_cast< linboMulticastBoxImpl*>(this));
    if (!strcmp(_clname, "Ui::linboMulticastBox"))
        return static_cast< Ui::linboMulticastBox*>(const_cast< linboMulticastBoxImpl*>(this));
    if (!strcmp(_clname, "linboDialog"))
        return static_cast< linboDialog*>(const_cast< linboMulticastBoxImpl*>(this));
    return QWidget::qt_metacast(_clname);
}

int linboMulticastBoxImpl::qt_metacall(QMetaObject::Call _c, int _id, void **_a)
{
    _id = QWidget::qt_metacall(_c, _id, _a);
    if (_id < 0)
        return _id;
    if (_c == QMetaObject::InvokeMetaMethod) {
        switch (_id) {
        case 0: readFromStdout(); break;
        case 1: readFromStderr(); break;
        case 2: precmd(); break;
        case 3: postcmd(); break;
        default: ;
        }
        _id -= 4;
    }
    return _id;
}
QT_END_MOC_NAMESPACE
