/****************************************************************************
** Meta object code from reading C++ file 'linboImageUploadImpl.hh'
**
** Created: Fri Sep 18 10:37:06 2009
**      by: The Qt Meta Object Compiler version 61 (Qt 4.5.2)
**
** WARNING! All changes made in this file will be lost!
*****************************************************************************/

#include "linboImageUploadImpl.hh"
#if !defined(Q_MOC_OUTPUT_REVISION)
#error "The header file 'linboImageUploadImpl.hh' doesn't include <QObject>."
#elif Q_MOC_OUTPUT_REVISION != 61
#error "This file was generated using the moc from 4.5.2. It"
#error "cannot be used with the include files from this version of Qt."
#error "(The moc has changed too much.)"
#endif

QT_BEGIN_MOC_NAMESPACE
static const uint qt_meta_data_linboImageUploadImpl[] = {

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
      39,   21,   21,   21, 0x0a,
      56,   21,   21,   21, 0x0a,
      65,   21,   21,   21, 0x0a,

       0        // eod
};

static const char qt_meta_stringdata_linboImageUploadImpl[] = {
    "linboImageUploadImpl\0\0readFromStdout()\0"
    "readFromStderr()\0precmd()\0postcmd()\0"
};

const QMetaObject linboImageUploadImpl::staticMetaObject = {
    { &QWidget::staticMetaObject, qt_meta_stringdata_linboImageUploadImpl,
      qt_meta_data_linboImageUploadImpl, 0 }
};

const QMetaObject *linboImageUploadImpl::metaObject() const
{
    return &staticMetaObject;
}

void *linboImageUploadImpl::qt_metacast(const char *_clname)
{
    if (!_clname) return 0;
    if (!strcmp(_clname, qt_meta_stringdata_linboImageUploadImpl))
        return static_cast<void*>(const_cast< linboImageUploadImpl*>(this));
    if (!strcmp(_clname, "Ui::linboImageUpload"))
        return static_cast< Ui::linboImageUpload*>(const_cast< linboImageUploadImpl*>(this));
    if (!strcmp(_clname, "linboDialog"))
        return static_cast< linboDialog*>(const_cast< linboImageUploadImpl*>(this));
    return QWidget::qt_metacast(_clname);
}

int linboImageUploadImpl::qt_metacall(QMetaObject::Call _c, int _id, void **_a)
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
