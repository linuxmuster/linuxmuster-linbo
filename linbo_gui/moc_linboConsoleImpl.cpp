/****************************************************************************
** Meta object code from reading C++ file 'linboConsoleImpl.hh'
**
** Created: Fri Sep 18 10:36:47 2009
**      by: The Qt Meta Object Compiler version 61 (Qt 4.5.2)
**
** WARNING! All changes made in this file will be lost!
*****************************************************************************/

#include "linboConsoleImpl.hh"
#if !defined(Q_MOC_OUTPUT_REVISION)
#error "The header file 'linboConsoleImpl.hh' doesn't include <QObject>."
#elif Q_MOC_OUTPUT_REVISION != 61
#error "This file was generated using the moc from 4.5.2. It"
#error "cannot be used with the include files from this version of Qt."
#error "(The moc has changed too much.)"
#endif

QT_BEGIN_MOC_NAMESPACE
static const uint qt_meta_data_linboConsoleImpl[] = {

 // content:
       2,       // revision
       0,       // classname
       0,    0, // classinfo
       6,   12, // methods
       0,    0, // properties
       0,    0, // enums/sets
       0,    0, // constructors

 // slots: signature, parameters, type, tag, flags
      18,   17,   17,   17, 0x0a,
      28,   17,   17,   17, 0x0a,
      37,   17,   17,   17, 0x0a,
      54,   17,   17,   17, 0x0a,
      71,   17,   17,   17, 0x0a,
      84,   17,   17,   17, 0x0a,

       0        // eod
};

static const char qt_meta_stringdata_linboConsoleImpl[] = {
    "linboConsoleImpl\0\0postcmd()\0precmd()\0"
    "readFromStderr()\0readFromStdout()\0"
    "showOutput()\0execute()\0"
};

const QMetaObject linboConsoleImpl::staticMetaObject = {
    { &QWidget::staticMetaObject, qt_meta_stringdata_linboConsoleImpl,
      qt_meta_data_linboConsoleImpl, 0 }
};

const QMetaObject *linboConsoleImpl::metaObject() const
{
    return &staticMetaObject;
}

void *linboConsoleImpl::qt_metacast(const char *_clname)
{
    if (!_clname) return 0;
    if (!strcmp(_clname, qt_meta_stringdata_linboConsoleImpl))
        return static_cast<void*>(const_cast< linboConsoleImpl*>(this));
    if (!strcmp(_clname, "Ui::linboConsole"))
        return static_cast< Ui::linboConsole*>(const_cast< linboConsoleImpl*>(this));
    if (!strcmp(_clname, "linboDialog"))
        return static_cast< linboDialog*>(const_cast< linboConsoleImpl*>(this));
    return QWidget::qt_metacast(_clname);
}

int linboConsoleImpl::qt_metacall(QMetaObject::Call _c, int _id, void **_a)
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
        case 4: showOutput(); break;
        case 5: execute(); break;
        default: ;
        }
        _id -= 6;
    }
    return _id;
}
QT_END_MOC_NAMESPACE
