#ifndef UTILS_H
#define UTILS_H

#include <QProcess>
#include <QVariant>
#include <DPalette>
#include <iostream>

class Process : public QProcess {
    Q_OBJECT

public:
    Process(QObject *parent = 0) : QProcess(parent) { }

    Q_INVOKABLE void start(const QString &program, const QVariantList &arguments) {
        QStringList args;

        // convert QVariantList from QML to QStringList for QProcess

        for (int i = 0; i < arguments.length(); i++)
            args << arguments[i].toString();

        QProcess::start(program, args);
    }

    Q_INVOKABLE QByteArray readAll() {
        return QProcess::readAllStandardError()+QProcess::readAllStandardOutput();
    }
    Q_INVOKABLE QByteArray readStdout(){
        return QProcess::readAllStandardOutput();
    }
    Q_INVOKABLE QByteArray readStderr(){
        return QProcess::readAllStandardError();
    }
    Q_INVOKABLE int exitCode(){return QProcess::exitCode();}
    Q_INVOKABLE bool wait(){
        return QProcess::waitForFinished();
    }
    Q_INVOKABLE bool isReadable(){
        return QProcess::isReadable();
    }
};

#endif // UTILS_H
