#include "filterregex.h"
#include <QString>
#include <QTextCodec>

FilterRegex::FilterRegex(QObject *parent, const QString& valPattern, const QString& maxPattern,
                         const QString& titlePattern):
    Filter(parent),_maximum(100),_value(0),_title(QString("")),
    codec(QTextCodec::codecForName("UTF-8")),maxMatcher(0),
    valMatcher(QRegularExpression(valPattern)),titleMatcher(0)
{
    if(maxPattern != 0 && maxPattern.compare(QString("")) != 0){
        maxMatcher = QRegularExpression(maxPattern);
    }
    if(titlePattern != 0 && titlePattern.compare(QString("")) != 0){
        titleMatcher = QRegularExpression(titlePattern);
    }
}

FilterRegex::~FilterRegex()
{
    // Qt deletes codec !
    return;
}

void FilterRegex::filter(const QByteArray &output)
{
    QStringList sl = codec->toUnicode(output).split("\n");
    for(QString s : sl){
        s.replace(QChar('\''),QChar(' '));
        s.replace(QChar('"'),QChar(' '));
        if(&titleMatcher != 0){
            QRegularExpressionMatch title = titleMatcher.match(s);
            if(title.hasMatch()){
                _title = title.captured(1);
                titleChanged(_title);
            }
        }
        if(&maxMatcher != 0){
            QRegularExpressionMatch max = maxMatcher.match(s);
            if(max.hasMatch()){
                bool ok;
                int tmp = max.captured(1).toInt(&ok);
                if(ok){
                    _maximum = tmp;
                    maximumChanged(_maximum);
                }
            }
        }
        QRegularExpressionMatch val = valMatcher.match(s);
        if(val.hasMatch()){
            bool ok;
            int tmp = val.captured(1).toInt(&ok);
            if(ok && (tmp != _value)){
                _value = tmp;
                valueChanged(_value);
            }
        }
    }
}
