#ifndef IP4VALIDATOR_H
#define IP4VALIDATOR_H

#include <QValidator>

class IP4Validator : public QValidator {
public:
    IP4Validator(QObject *parent=nullptr);
    void fixup(QString &input) const;
    State validate(QString &input, int &pos) const;
};
#endif // IP4VALIDATOR_H
