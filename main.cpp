#include <iostream>
#include <DApplication>
#include <DMainWindow>
#include <DPalette>
#include <DGuiApplicationHelper>
#include <DTitlebar>
#include <QQmlApplicationEngine>
#include <QtQuickWidgets/QQuickWidget>
#include <QQmlContext>
#include <QDesktopWidget>
#include <QScreen>
#include <QGraphicsEffect>
#include <QLocale>
#include <QTranslator>
#include <QDebug>
#include <QtQml>
#include <QQuickItem>
#include "dtk/include/qtquickdtk.h"
#include "utils.h"

DWIDGET_USE_NAMESPACE
int main(int argc, char* argv[])
{
#if QT_VERSION < QT_VERSION_CHECK(6, 0, 0)
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
#endif

    DApplication app(argc,argv);

    QTranslator translator;
    const QStringList uiLanguages = QLocale::system().uiLanguages();
    for (const QString& locale : uiLanguages) {
        const QString baseName = "sparkStoreQtQuick_" + QLocale(locale).name();
        if (translator.load(":/i18n/" + baseName)) {
            app.installTranslator(&translator);
            break;
        }
    }

    app.setOrganizationName("rubbishtech");
    app.setOrganizationDomain("rubbishtech.org");
    app.setApplicationName("sparkStoreQtQuick");

    DMainWindow win;
    QQuickWidget widget;
    const QUrl url(QStringLiteral("qrc:/main.qml"));
    auto *settingsAction=new QAction("Settings");
    auto *tasklistAction=new QAction("Tasks");
    qmlRegisterType<Process>("Process",1,0,"Process");
    qmlRegisterSingletonType(QUrl("qrc:/components/Backend.qml"),"singleton.backend",1,0,"Backend");

    widget.engine()->rootContext()->setContextProperty("SettingsAction",settingsAction);
    win.titlebar()->menu()->addAction(settingsAction);
    widget.engine()->rootContext()->setContextProperty("TasklistAction",tasklistAction);
    win.titlebar()->menu()->addAction(tasklistAction);

    enableQtQuickDTKStyle(widget.engine());
    widget.setSource(url);
    widget.setResizeMode(QQuickWidget::SizeRootObjectToView);
    win.setCentralWidget(&widget);

    win.show();

    return app.exec();
}
