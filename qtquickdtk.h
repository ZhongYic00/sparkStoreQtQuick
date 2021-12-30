#ifndef QTQUICKDTK_H
#define QTQUICKDTK_H

#include <QtQuickControls2/QQuickStyle>
#include <QQmlEngine>
#include <QQmlContext>
#include <QTimer>
#include <DApplication>
#include <DGuiApplicationHelper>
#include <DPlatformTheme>
#include <iostream>

DWIDGET_USE_NAMESPACE
void importProperties(QQmlEngine* engine){
    engine->rootContext()->setContextProperty("smallRadius",8);
    engine->rootContext()->setContextProperty("bigRadius",18);

    const auto setColorGroup = [engine](QWindow* win){
        const QString colorGroupNames[] = {"Inactive", "Active", "Inactive", "NColorGroups", "Current", "All", "Normal"};
        QString cg=colorGroupNames[QApplication::activeWindow()!=nullptr];
        std::cout<<cg.toStdString()<<std::endl;
        engine->rootContext()->setContextProperty("globalColorGroup",cg);
        engine->rootContext()->setContextProperty("dpaletteLightStyle",DGuiApplicationHelper::instance()->themeType()==DGuiApplicationHelper::LightType);
    };
    setColorGroup(nullptr);
    QObject::connect(dynamic_cast<DApplication*>(DApplication::instance()),&DApplication::focusWindowChanged,setColorGroup);
}
void enableQtQuickDTKStyle(QQmlEngine* engine){
    QQuickStyle::addStylePath("qrc:/dtk");
    importProperties(engine);
}
#endif // QTQUICKDTK_H
