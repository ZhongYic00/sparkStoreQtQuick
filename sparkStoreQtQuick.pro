QT += quick quickcontrols2

CONFIG += c++11

CONFIG(release, debug|release): DEFINES += QT_NO_WARNING_OUTPUT QT_NO_DEBUG_OUTPUT

# You can make your code fail to compile if it uses deprecated APIs.
# In order to do so, uncomment the following line.
#DEFINES += QT_DISABLE_DEPRECATED_BEFORE=0x060000    # disables all the APIs deprecated before Qt 6.0.0

SOURCES += \
        main.cpp \
        dtk/include/qmldpalette.cpp

RESOURCES += \
    dtk/resources/dtk.qrc \
    qmls.qrc

TRANSLATIONS += \
    sparkStoreQtQuick_zh_CN.ts
CONFIG += lrelease
CONFIG += embed_translations
QT += dtkcore dtkgui dtkwidget quickwidgets

# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH =

# Additional import path used to resolve QML modules just for Qt Quick Designer
QML_DESIGNER_IMPORT_PATH =

# Default rules for deployment.
qnx: target.path = /tmp/$${TARGET}/bin
else: unix:!android: target.path = /opt/$${TARGET}/bin
!isEmpty(target.path): INSTALLS += target

HEADERS += \
    dtk/include/qmldpalette.h \
    dtk/include/qtquickdtk.h \
    utils.h

DISTFILES += \
    components/Appinfo.qml \
    components/Backend.qml \
    components/Tasklist.qml \
    components/Worker.qml \
    main.qml \
    components/ApplistView.qml \
    components/DetailsView.qml \
    components/ImageView.qml \
    components/SettingsView.qml \
    components/utils.js
