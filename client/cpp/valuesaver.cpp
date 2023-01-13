#include "valuesaver.h"
#include <QStandardPaths>
#include <QFileInfo>
#include <QFile>
#include <QDataStream>
#include <QDir>
#include <QLocale>

ValueSaver::ValueSaver(QObject *parent)
    : QObject{parent},
    pathToAppDataLocation(QStandardPaths::writableLocation(QStandardPaths::AppDataLocation))
{}

void ValueSaver::extractStoredValues()
{
    QFileInfo checkFile(pathToAppDataLocation + "/v100/settings/appValues.bin");
    bool fileExists = checkFile.exists() && checkFile.isFile();
    if(fileExists) {
        QFile fileObj(pathToAppDataLocation + "/v100/settings/appValues.bin");
        if(fileObj.open(QIODevice::ReadOnly)) {
            QDataStream inOfFileObj(&fileObj);
            inOfFileObj.setVersion(QDataStream::Qt_5_15);
            QGeoCoordinate savedLocationForMarkerA;
            double savedZoomLevelForFields1And2;
            int page2_field3_comboBox_activeMenuPoint;
            bool page3_departureTimeAtOrFromTo;
            QString page3_emptySeats;
            int page3_currencyNumber;
            QString page3_name;
            QString page3_contacts;
            bool page4_needToDepartAtOrFromTo;
            QString page4_howManyPeople;
            int page4_searchRadius;
            double page5_mapHKoef;
            inOfFileObj >> savedLocationForMarkerA
                    >> savedZoomLevelForFields1And2
                    >> page2_field3_comboBox_activeMenuPoint
                    >> page3_departureTimeAtOrFromTo
                    >> page3_emptySeats
                    >> page3_currencyNumber
                    >> page3_name
                    >> page3_contacts
                    >> page4_needToDepartAtOrFromTo
                    >> page4_howManyPeople
                    >> page4_searchRadius
                    >> page5_mapHKoef;
            emit installSavedValues(savedLocationForMarkerA, savedZoomLevelForFields1And2, page2_field3_comboBox_activeMenuPoint, page3_departureTimeAtOrFromTo, page3_emptySeats, page3_currencyNumber, page3_name, page3_contacts, page4_needToDepartAtOrFromTo, page4_howManyPeople, page4_searchRadius, page5_mapHKoef);
        }
        else
            fileExists = false;
        fileObj.close();
    }
    if(!fileExists)
        emit installSavedValues(QLocale().language() == QLocale::Russian ? QGeoCoordinate(55.75374, 37.62271) : QGeoCoordinate(51.50724, -0.12665), 10, 0, true, "4", -1, "", "", true, "1", 300, 0.4);
}

void ValueSaver::saveValues(const QGeoCoordinate &savedLocationForMarkerA, double savedZoomLevelForFields1And2, int page2_field3_comboBox_activeMenuPoint, bool page3_departureTimeAtOrFromTo, const QString &page3_emptySeats, int page3_currencyNumber, const QString &page3_name, const QString &page3_contacts, bool page4_needToDepartAtOrFromTo, const QString &page4_howManyPeople, int page4_searchRadius, double page5_mapHKoef)
{
    QDir dirOfAppValues(pathToAppDataLocation + "/v100/settings");
    if(!dirOfAppValues.exists()) {
        dirOfAppValues.mkpath(".");
    }
    QFile fileObj(pathToAppDataLocation + "/v100/settings/appValues.bin");
    bool fileOpened = fileObj.open(QIODevice::WriteOnly);
    if(fileOpened) {
        QDataStream outOfFileObj(&fileObj);
        outOfFileObj.setVersion(QDataStream::Qt_5_15);
        outOfFileObj << savedLocationForMarkerA
                     << savedZoomLevelForFields1And2
                     << page2_field3_comboBox_activeMenuPoint
                     << page3_departureTimeAtOrFromTo
                     << page3_emptySeats
                     << page3_currencyNumber
                     << page3_name
                     << page3_contacts
                     << page4_needToDepartAtOrFromTo
                     << page4_howManyPeople
                     << page4_searchRadius
                     << page5_mapHKoef;
    }
    fileObj.close();
}
