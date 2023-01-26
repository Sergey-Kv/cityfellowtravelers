#include "tripsmanager.h"
#include "commonDataStructures.h"
#include <QStandardPaths>
#include <QDateTime>
#include <QDir>
#include "functions.h"
#include <QLocale>

TripsManager::TripsManager(QObject *parent)
    : QObject{parent},
      pathToAppDataLocation(QStandardPaths::writableLocation(QStandardPaths::AppDataLocation)),
      areMyTripsLoadedFromFiles(false)
{}

void TripsManager::loadMyTripsFromFiles()
{
    if(areMyTripsLoadedFromFiles)
        myTrips.clear();
    areMyTripsLoadedFromFiles = true;
    QDir tripsDir(pathToAppDataLocation + "/v100/myTrips");
    tripsDir.setFilter(QDir::Files);
    tripsDir.setSorting(QDir::Name);
    QStringList tripsFileNamesList = tripsDir.entryList();
    myTrip tripData;
    quint16 routeCoordNumber;
    coord temp;
    quint32 howManyMinSinceEpochWasAMonthAgo = QDateTime::currentSecsSinceEpoch() / 60 - 1440 * 30;
    for(QStringList::const_iterator i = tripsFileNamesList.constBegin(); i != tripsFileNamesList.constEnd(); ++i) {
        QFile fileObj(pathToAppDataLocation + "/v100/myTrips/" + *i);
        if(fileObj.open(QIODevice::ReadOnly)) {
            QDataStream inOfFileObj(&fileObj);
            inOfFileObj.setVersion(QDataStream::Qt_5_15);
            inOfFileObj >> tripData.tripId >> tripData.deleteCode >> routeCoordNumber;
            tripData.route.clear();
            for(unsigned int i = 0; i < routeCoordNumber; ++i) {
                inOfFileObj >> temp.latit >> temp.longit;
                tripData.route.append(QGeoCoordinate(static_cast<double>(temp.latit) / 10000000.0, static_cast<double>(temp.longit) / 10000000.0));
            }
            inOfFileObj >> tripData.fromDepartureTime >> tripData.toDepartureTime >> tripData.emptySeats >> tripData.currencyNumber >> tripData.estimatedPrice >> tripData.comment >> tripData.name >> tripData.contacts;
            if(tripData.toDepartureTime < howManyMinSinceEpochWasAMonthAgo)
                continue;
            tripData.fileName = *i;
            myTrips.prepend(tripData);
        }
        fileObj.close();
    }
}

void TripsManager::fillTheModelWithInformationAboutMyTrips()
{
    if(!areMyTripsLoadedFromFiles)
        loadMyTripsFromFiles();
    QDate currDate = QDate::currentDate();
    for(QVector<myTrip>::const_iterator it = myTrips.constBegin(); it != myTrips.constEnd(); ++it)
        emit insertTrip(generateTextForTripElement(*it, currDate), false);
}

bool TripsManager::addTheTripToMyTrips(QDataStream &inOfServerDataBlock)
{
    if(!areMyTripsLoadedFromFiles)
        loadMyTripsFromFiles();
    myTrip tripData;
    quint16 routeCoordNumber;
    coord temp;
    QVector<coord> tempRoute;
    tempRoute.reserve(routeCoordNumber);
    inOfServerDataBlock >> tripData.tripId
            >> tripData.deleteCode
            >> routeCoordNumber;
    for(unsigned int i = 0; i < routeCoordNumber; ++i) {
        inOfServerDataBlock >> temp.latit >> temp.longit;
        tempRoute.append(coord(temp.latit, temp.longit));
        tripData.route.append(QGeoCoordinate(static_cast<double>(temp.latit) / 10000000.0, static_cast<double>(temp.longit) / 10000000.0));
    }
    inOfServerDataBlock >> tripData.fromDepartureTime >> tripData.toDepartureTime
            >> tripData.emptySeats
            >> tripData.currencyNumber >> tripData.estimatedPrice
            >> tripData.comment
            >> tripData.name
            >> tripData.contacts;
    tripData.fileName = QString::number(QDateTime::currentMSecsSinceEpoch());
    QDir dirOfSavedRoutes(pathToAppDataLocation + "/v100/myTrips");
    if(!dirOfSavedRoutes.exists()) {
        dirOfSavedRoutes.mkpath(".");
    }
    QFile fileObj(pathToAppDataLocation + "/v100/myTrips/" + tripData.fileName);
    bool fileOpened = fileObj.open(QIODevice::WriteOnly);
    if(fileOpened) {
        QDataStream outOfFileObj(&fileObj);
        outOfFileObj.setVersion(QDataStream::Qt_5_15);
        outOfFileObj << tripData.tripId << tripData.deleteCode << routeCoordNumber;
        for(QVector<coord>::const_iterator it = tempRoute.constBegin(); it != tempRoute.constEnd(); ++it)
            outOfFileObj << it->latit << it->longit;
        outOfFileObj << tripData.fromDepartureTime << tripData.toDepartureTime << tripData.emptySeats << tripData.currencyNumber << tripData.estimatedPrice << tripData.comment << tripData.name << tripData.contacts;
    }
    fileObj.close();
    myTrips.prepend(tripData);
    emit insertTrip(generateTextForTripElement(tripData, QDate::currentDate()), true);
    return fileOpened;
}

int TripsManager::getTripIdOfMyTrip(int index)
{
    if(index < 0 || index >= myTrips.size())
        return 0;
    return myTrips.at(index).tripId;
}

int TripsManager::getDeleteCodeOfMyTrip(int index)
{
    if(index < 0 || index >= myTrips.size())
        return 0;
    return myTrips.at(index).deleteCode;
}

void TripsManager::removeTheTripFromMyTrips(QDataStream &inOfServerDataBlock)
{
    if(!areMyTripsLoadedFromFiles)
        loadMyTripsFromFiles();
    quint32 tripId;
    inOfServerDataBlock >> tripId;
    int index = 0;
    for(QVector<myTrip>::iterator it = myTrips.begin(); it != myTrips.end(); ++it, ++index) {
        if(it->tripId == tripId) {
            QFile::remove(pathToAppDataLocation + "/v100/myTrips/" + it->fileName);
            myTrips.remove(index);
            emit removeMyTrip(index);
            return;
        }
    }
}

void TripsManager::getRouteForThisIndexForMyTrips(int index)
{
    if(myTrips.size() - 1 < index || index < 0)
        return;
    const QList<QGeoCoordinate> *pointer = &myTrips.at(index).route;
    emit installRouteForMyTrip(*pointer, pointer->first(), pointer->last());
}

QString TripsManager::getTextWithCommentForThisIndexForMyTrips(int index)
{
    if(!areMyTripsLoadedFromFiles)
        loadMyTripsFromFiles();
    const myTrip &tripData = myTrips.at(index);
    QString resultText;
    if(tripData.comment != "")
        resultText += "\n" + tripData.comment;
    return resultText += "\n\n" + tr("Contacts"); //"Контакты"
}

QString TripsManager::getContactsTextForThisIndexForMyTrips(int index)
{
    const myTrip &tripData = myTrips.at(index);
    return tripData.contacts;
}

int TripsManager::getMyTripCount()
{
    if(!areMyTripsLoadedFromFiles)
        loadMyTripsFromFiles();
    return myTrips.size();
}

void TripsManager::loadFoundRoutes(QDataStream &inOfServerDataBlock)
{
    foundTrips.clear();
    coord temp;
    inOfServerDataBlock >> temp.latit >> temp.longit;
    markerA = QGeoCoordinate(static_cast<double>(temp.latit) / 10000000.0, static_cast<double>(temp.longit) / 10000000.0);
    inOfServerDataBlock >> temp.latit >> temp.longit;
    markerB = QGeoCoordinate(static_cast<double>(temp.latit) / 10000000.0, static_cast<double>(temp.longit) / 10000000.0);
    quint16 numberOfMatches;
    inOfServerDataBlock >> numberOfMatches;
    foundTrip tripData;
    quint16 routeCoordNumber;
    for(unsigned int i = 0; i < numberOfMatches; ++i) {
        inOfServerDataBlock >> tripData.degreeOfSuitability
                >> routeCoordNumber;
        tripData.route.clear();
        for(unsigned int i = 0; i < routeCoordNumber; ++i) {
            inOfServerDataBlock >> temp.latit >> temp.longit;
            tripData.route.append(QGeoCoordinate(static_cast<double>(temp.latit) / 10000000.0, static_cast<double>(temp.longit) / 10000000.0));
        }
        inOfServerDataBlock >> tripData.fromDepartureTime >> tripData.toDepartureTime
                >> tripData.emptySeats
                >> tripData.currencyNumber >> tripData.estimatedPrice
                >> tripData.comment
                >> tripData.name
                >> tripData.contacts;
        foundTrips.append(tripData);
    }
}

void TripsManager::fillTheModelWithInformationAboutFoundTrips()
{
    QDate currDate = QDate::currentDate();
    for(QVector<foundTrip>::const_iterator it = foundTrips.constBegin(); it != foundTrips.constEnd(); ++it)
        emit insertTrip(generateTextForTripElement(*it, currDate), false);
}

void TripsManager::getRouteForThisIndexForFoundTrips(int index)
{
    if(foundTrips.size() - 1 < index)
        return;
    const QList<QGeoCoordinate> *pointer = &foundTrips.at(index).route;
    emit installRouteForFoundTrip(*pointer, pointer->first(), pointer->last(), markerA, markerB);
}

QString TripsManager::getTextWithCommentForThisIndexForFoundTrips(int index)
{
    const foundTrip &tripData = foundTrips.at(index);
    QString resultText;
    if(tripData.comment != "")
        resultText += "\n" + tripData.comment;
    return resultText += "\n\n" + tr("Contacts"); //"Контакты"
}

QString TripsManager::getContactsTextForThisIndexForFoundTrips(int index)
{
    const foundTrip &tripData = foundTrips.at(index);
    return tripData.contacts;
}

template<typename T>
QString TripsManager::generateTextForTripElement(const T &trip, const QDate &currDate)
{
    QString textForTripElement;
    if(trip.name != "")
        textForTripElement = trip.name + "\n";

    int currYear = currDate.year();
    int currMonth = currDate.month();
    int currDay = currDate.day();
    QDate datePlusOneDay = currDate.addDays(1);
    int tomoYear = datePlusOneDay.year();
    int tomoMonth = datePlusOneDay.month();
    int tomoDay = datePlusOneDay.day();
    QDateTime fromDt = QDateTime::fromSecsSinceEpoch(qint64(trip.fromDepartureTime) * 60);
    int fromYear = fromDt.date().year();
    int fromMonth = fromDt.date().month();
    int fromDay = fromDt.date().day();
    int fromHour = fromDt.time().hour();
    int fromMinute = fromDt.time().minute();
    bool isFromTimeAmOrPm;
    QString fromTimeStr;
    if(!Functions::is24HourFormat) {
        isFromTimeAmOrPm = fromHour < 12;
        if(!isFromTimeAmOrPm)
            fromHour -= 12;
    }
    fromTimeStr = QString::number(fromHour) + ":" + intToTwoCharQString(fromMinute);
    if(!Functions::is24HourFormat) {
        if(isFromTimeAmOrPm)
            fromTimeStr += " AM";
        else
            fromTimeStr += " PM";
    }
    bool fromIsToday = fromDay == currDay && fromMonth == currMonth && fromYear == currYear;
    bool fromIsTomorrow = fromDay == tomoDay && fromMonth == tomoMonth && fromYear == tomoYear;
    QString fromDateStr = (fromIsToday ? tr("today") : fromIsTomorrow ? tr("tomorrow") : Functions::createStrDate(fromDay, fromMonth, fromYear)); //"сегодня" //"завтра"
    bool withTo = trip.fromDepartureTime != trip.toDepartureTime;
    bool sameDay;
    QString toTimeStr;
    bool toIsToday;
    bool toIsTomorrow;
    QString toDateStr;
    if(withTo) {
        QDateTime toDt = QDateTime::fromSecsSinceEpoch(qint64(trip.toDepartureTime) * 60);
        int toYear = toDt.date().year();
        int toMonth = toDt.date().month();
        int toDay = toDt.date().day();
        int toHour = toDt.time().hour();
        int toMinute = toDt.time().minute();
        bool isToTimeAmOrPm;
        if(!Functions::is24HourFormat) {
            isToTimeAmOrPm = toHour < 12;
            if(!isToTimeAmOrPm)
                toHour -= 12;
        }
        toTimeStr = QString::number(toHour) + ":" + intToTwoCharQString(toMinute);
        if(!Functions::is24HourFormat) {
            if(isToTimeAmOrPm)
                toTimeStr += " AM";
            else
                toTimeStr += " PM";
        }
        sameDay = fromDay == toDay && fromMonth == toMonth && fromYear == toYear;
        toIsToday = toDay == currDay && toMonth == currMonth && toYear == currYear;
        toIsTomorrow = toDay == tomoDay && toMonth == tomoMonth && toYear == tomoYear;
        toDateStr = (toIsToday ? tr("today") : toIsTomorrow ? tr("tomorrow") : Functions::createStrDate(toDay, toMonth, toYear)); //"сегодня" //"завтра"
    }
    QString departureText = tr("Departure"); //"Выезд"
    QString fromText = tr("from"); //"с"
    QString atText = tr("at"); //"в"
    QString toText = tr("to"); //"до"
    textForTripElement += departureText + " ";
    QVector<boolAndQStringPointer> objects;
    objects.reserve(6);
    if(withTo)
        objects.append(boolAndQStringPointer(false, &fromText));
    else
        objects.append(boolAndQStringPointer(false, &atText));
    objects.append(boolAndQStringPointer(!Functions::is24HourFormat, &fromTimeStr));
    if(withTo) {
        if(!sameDay)
            objects.append(boolAndQStringPointer(!(fromIsToday || fromIsTomorrow), &fromDateStr));
        objects.append(boolAndQStringPointer(false, &toText));
        objects.append(boolAndQStringPointer(!Functions::is24HourFormat, &toTimeStr));
        objects.append(boolAndQStringPointer(!(toIsToday || toIsTomorrow), &toDateStr));
    }
    else
        objects.append(boolAndQStringPointer(!(fromIsToday || fromIsTomorrow), &fromDateStr));
    textForTripElement += *(objects.at(0).objectPointer);
    for(int i = 1; i < objects.size(); ++i) {
        if(objects.at(i).objectWithSpaces || objects.at(i-1).objectWithSpaces)
            textForTripElement += "  ";
        else
            textForTripElement += " ";
        textForTripElement += *(objects.at(i).objectPointer);
    }
    textForTripElement += "\n";

    QString currencyStr;
    if(trip.currencyNumber == 643) currencyStr = tr(" RUB"); //" руб."
    else if(trip.currencyNumber == 933) currencyStr = tr(" BYN"); //" бел. руб."
    else if(trip.currencyNumber == 980) currencyStr = tr(" UAH"); //" грн."
    else if(trip.currencyNumber == 398) currencyStr = tr(" KZT"); //" тенге"
    else if(trip.currencyNumber == 840) currencyStr = tr("$");
    else if(trip.currencyNumber == 978) currencyStr = tr("€");
    else if(trip.currencyNumber == 0) currencyStr = "";
    else currencyStr = "";
    if(trip.estimatedPrice != "")
        textForTripElement += "~" + trip.estimatedPrice + currencyStr + ", ";

    QString seatsStr;
    if(QLocale().language() == QLocale::Russian) {
        if(trip.emptySeats % 10 == 0 || trip.emptySeats % 10 > 4 || (trip.emptySeats % 100 > 10 && trip.emptySeats % 100 < 20))
            seatsStr = "мест";
        else if(trip.emptySeats % 10 == 1)
            seatsStr = "место";
        else
            seatsStr = "места";
    }
    else {
        if(trip.emptySeats == 1)
            seatsStr = "seat";
        else
            seatsStr = "seats";
    }
    return textForTripElement += QString::number(trip.emptySeats) + " " + seatsStr;
}

QString TripsManager::intToTwoCharQString(int number) {
    return number < 10 ? "0" + QString::number(number) : QString::number(number);
}

TripsManager::boolAndQStringPointer::boolAndQStringPointer(bool objectWithSpaces, QString *objectPointer) : objectWithSpaces(objectWithSpaces), objectPointer(objectPointer) {}
