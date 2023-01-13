#include <QGuiApplication>
#include <QQmlApplicationEngine>

#include <QLocale>
#include <QTranslator>

#include <QQmlContext>
#include "functions.h"
#include "routedrawing.h"
#include "valuesaver.h"
#include "tripsmanager.h"
#include "touandppmanager.h"
#include "servercommunicator.h"

int main(int argc, char *argv[])
{
#if QT_VERSION < QT_VERSION_CHECK(6, 0, 0)
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
#endif
    QGuiApplication app(argc, argv);

    QTranslator translator;
    const QStringList uiLanguages = QLocale::system().uiLanguages();
    for(const QString &currLocaleStr : uiLanguages) {
        QLocale currLocale(currLocaleStr);
        if(currLocale.language() == QLocale::Belarusian || currLocale.language() == QLocale::Ukrainian || currLocale.language() == QLocale::Kazakh)
            currLocale = QLocale(QLocale::Russian, currLocale.script(), currLocale.country());
        if(translator.load(":/i18n/city_fellow_travelers_" + currLocale.name())) {
            app.installTranslator(&translator);
            QLocale::setDefault(currLocale);  // for qml Qt.locale() to work properly
            break;
        }
    }

    QQmlApplicationEngine engine;
    const QUrl url(QStringLiteral("qrc:/qml/main.qml"));
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl) {
        if (!obj && url == objUrl)
            QCoreApplication::exit(-1);
    }, Qt::QueuedConnection);
    Functions fnc;
    engine.rootContext()->setContextProperty("fnc", &fnc);
    RouteDrawing rdr;
    engine.rootContext()->setContextProperty("rdr", &rdr);
    ValueSaver vsr;
    engine.rootContext()->setContextProperty("vsr", &vsr);
    TripsManager tmn;
    engine.rootContext()->setContextProperty("tmn", &tmn);
    TouAndPpManager tpp;
    engine.rootContext()->setContextProperty("tpp", &tpp);
    ServerCommunicator scm(&tmn, &tpp);
    engine.rootContext()->setContextProperty("scm", &scm);
    engine.load(url);

    return app.exec();
}
