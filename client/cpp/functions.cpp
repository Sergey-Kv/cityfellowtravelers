#include "functions.h"
#include <cmath>
#include <QPair>
#include <QDateTime>
#include <QLocale>
#ifdef __ANDROID__
#include <QAndroidJniObject>
#include <QtAndroid>
#endif // __ANDROID__

bool Functions::is24HourFormat = true;

Functions::Functions(QObject *parent) : QObject{parent}
{
#ifdef __ANDROID__
    is24HourFormat = static_cast<bool>(QAndroidJniObject::callStaticMethod<jboolean>("android/text/format/DateFormat",
                                                                             "is24HourFormat",
                                                                             "(Landroid/content/Context;)Z",
                                                                             QtAndroid::androidActivity().object<jobject>()));
#endif // __ANDROID__
}

double Functions::distBetwTwoCoordInMeters(const QGeoCoordinate &coord1, const QGeoCoordinate &coord2) {
    return sqrt(pow(abs(coord1.latitude() - coord2.latitude()) * 111250.0, 2.0) + pow(abs(coord1.longitude() - coord2.longitude()) * 40050000.0 * cos((coord1.latitude() + coord2.latitude()) / 2.0 * M_PI / 180.0) / 360.0, 2.0));
}

double Functions::pointsFromDistanceAndZoomlevel(double distInMeters, double zoomLevel, double latitudeWhereYouAre) {
    return pow(2.0, zoomLevel) * distInMeters / cos(latitudeWhereYouAre * M_PI / 180.0) * 0.00000645;
}

double Functions::distanceFromPointsAndZoomlevel(int numberOfPoints, double zoomLevel, double latitudeWhereYouAre) {
    return numberOfPoints / 0.00000645 / pow(2.0, zoomLevel) * cos(latitudeWhereYouAre * M_PI / 180.0);
}

bool Functions::isPolylineNeededToAbbrev(const QList<QGeoCoordinate> &polyline, QPair<int, QList<QGeoCoordinate>::const_iterator> &indexAndIteratorPairOfLastAbbrevCoord, double distOfPermissibleVariationInMeters) {
//    need to return:
//      polylineNeededToAbbrev                    via return
//      if polylineNeededToAbbrev is true:
//        indexAndIteratorPairOfLastAbbrevCoord   via &link
    QPair<int, QList<QGeoCoordinate>::const_iterator> coordA = indexAndIteratorPairOfLastAbbrevCoord;
    double dist_coordA_coordN;
    double dist_coordN_coordZ;
    double dist_coordA_coordZ = distBetwTwoCoordInMeters(*coordA.second, polyline.constLast());
    double angleBetw_coordA_coordN_coordZ;
    double angleBetw_coordA_coordZ_coordN;
    double angleBetw_coordZ_coordA_coordN;
    double distFromNToLineAZ;
    bool polylineNeededToAbbrev = false;
    double minAngleBetw_coordA_coordN_coordZ = M_PI;
    for(QPair<int, QList<QGeoCoordinate>::const_iterator> coordN(polyline.size() - 2, polyline.constEnd() - 2); coordN.first != coordA.first; --coordN.first, --coordN.second) {
        dist_coordA_coordN = distBetwTwoCoordInMeters(*coordA.second, *coordN.second);
        dist_coordN_coordZ = distBetwTwoCoordInMeters(*coordN.second, polyline.constLast());
        if(dist_coordA_coordN + dist_coordN_coordZ <= dist_coordA_coordZ || dist_coordA_coordN + dist_coordA_coordZ <= dist_coordN_coordZ || dist_coordN_coordZ + dist_coordA_coordZ <= dist_coordA_coordN) {
            continue;
        }

        angleBetw_coordA_coordN_coordZ = acos((pow(dist_coordA_coordN, 2.0) + pow(dist_coordN_coordZ, 2.0) - pow(dist_coordA_coordZ, 2.0)) / (2.0 * dist_coordA_coordN * dist_coordN_coordZ));
        if(angleBetw_coordA_coordN_coordZ < minAngleBetw_coordA_coordN_coordZ) {
            indexAndIteratorPairOfLastAbbrevCoord = coordN;
            minAngleBetw_coordA_coordN_coordZ = angleBetw_coordA_coordN_coordZ;
        }

        if(polylineNeededToAbbrev)
            continue;

        angleBetw_coordA_coordZ_coordN = acos((pow(dist_coordA_coordZ, 2.0) + pow(dist_coordN_coordZ, 2.0) - pow(dist_coordA_coordN, 2.0)) / (2.0 * dist_coordA_coordZ * dist_coordN_coordZ));
        if(angleBetw_coordA_coordZ_coordN >= M_PI_2) { //eliminates some cases when it is impossible to draw a perpendicular from N to segment AZ
            if(dist_coordN_coordZ >= distOfPermissibleVariationInMeters)
                polylineNeededToAbbrev = true;
        }
        else {
            angleBetw_coordZ_coordA_coordN = acos((pow(dist_coordA_coordZ, 2.0) + pow(dist_coordA_coordN, 2.0) - pow(dist_coordN_coordZ, 2.0)) / (2.0 * dist_coordA_coordZ * dist_coordA_coordN));
            if(angleBetw_coordZ_coordA_coordN >= M_PI_2) { //eliminates another part of the cases when it is impossible to draw a perpendicular from N to segment AZ
                if(dist_coordA_coordN >= distOfPermissibleVariationInMeters)
                    polylineNeededToAbbrev = true;
            }
            else {
                distFromNToLineAZ = dist_coordN_coordZ * sin(angleBetw_coordA_coordZ_coordN);
                if(distFromNToLineAZ >= distOfPermissibleVariationInMeters)
                    polylineNeededToAbbrev = true;
            }
        }
    }
    return polylineNeededToAbbrev;
}

void Functions::calculateMapPositionToShow1Route(const QList<QGeoCoordinate> &route1, const QGeoCoordinate &markerA, const QGeoCoordinate &markerB, double markersWidth, double markersHeight, double mapWidth, double mapHeight, double indent)
{
    QList<QList<QGeoCoordinate>> routes;
    routes.append(route1);
    QList<QGeoCoordinate> markers;
    markers.append(markerA);
    markers.append(markerB);
    calculateMapPositionToShowMapElemens(routes, markers, markersWidth, markersHeight, mapWidth, mapHeight, indent);
}

void Functions::calculateMapPositionToShow2Route(const QList<QGeoCoordinate> &route1, const QList<QGeoCoordinate> &route2, const QGeoCoordinate &markerA, const QGeoCoordinate &markerB, double markersWidth, double markersHeight, double mapWidth, double mapHeight, double indent)
{
    QList<QList<QGeoCoordinate>> routes;
    routes.append(route1);
    routes.append(route2);
    QList<QGeoCoordinate> markers;
    markers.append(markerA);
    markers.append(markerB);
    calculateMapPositionToShowMapElemens(routes, markers, markersWidth, markersHeight, mapWidth, mapHeight, indent);
}

void Functions::calculateMapPositionToShow2Markers(const QGeoCoordinate &markerA, const QGeoCoordinate &markerB, double markersWidth, double markersHeight, double mapWidth, double mapHeight, double indent)
{
    QList<QList<QGeoCoordinate>> routes;
    QList<QGeoCoordinate> markers;
    markers.append(markerA);
    markers.append(markerB);
    calculateMapPositionToShowMapElemens(routes, markers, markersWidth, markersHeight, mapWidth, mapHeight, indent);
}

void Functions::calculateMapPositionToShow1RouteAnd4Markers(const QList<QGeoCoordinate> &route1, const QGeoCoordinate &drivMarkerA, const QGeoCoordinate &drivMarkerB, const QGeoCoordinate &passMarkerA, const QGeoCoordinate &passMarkerB, double markersWidth, double markersHeight, double mapWidth, double mapHeight, double indent)
{
    QList<QList<QGeoCoordinate>> routes;
    routes.append(route1);
    QList<QGeoCoordinate> markers;
    markers.append(drivMarkerA);
    markers.append(drivMarkerB);
    markers.append(passMarkerA);
    markers.append(passMarkerB);
    calculateMapPositionToShowMapElemens(routes, markers, markersWidth, markersHeight, mapWidth, mapHeight, indent);
}

void Functions::calculateMapPositionToShowMapElemens(const QList<QList<QGeoCoordinate> > &routes, const QList<QGeoCoordinate> &markers, double markersWidth, double markersHeight, double mapWidth, double mapHeight, double indent)
{
    QGeoCoordinate resultCoordinate;
    double resultZoomLevel = 11;
    double zoomLevel = resultZoomLevel + 1;
    for(int i = 0; abs(resultZoomLevel - zoomLevel) > 0.001 && i < 100; ++i) {
        zoomLevel = resultZoomLevel;
        double minLatitude = 90;
        double maxLatitude = -90;
        double minLongitude = 180;
        double maxLongitude = -180;
        for(QList<QList<QGeoCoordinate>>::const_iterator h = routes.begin(); h != routes.end(); ++h) {
            for(QList<QGeoCoordinate>::const_iterator i = (*h).begin(); i != (*h).end(); ++i) {
                if((*i).latitude() < minLatitude)  minLatitude = (*i).latitude();
                if((*i).latitude() > maxLatitude)  maxLatitude = (*i).latitude();
                if((*i).longitude() < minLongitude)  minLongitude = (*i).longitude();
                if((*i).longitude() > maxLongitude)  maxLongitude = (*i).longitude();
            }
        }
        for(QList<QGeoCoordinate>::const_iterator i = markers.begin(); i != markers.end(); ++i) {
            double minLat = (*i).latitude();
            double maxLat = (*i).latitude() + convertMetersToDegrees(distanceFromPointsAndZoomlevel(markersHeight, zoomLevel, (*i).latitude()));
            double halfOfMarkerWidthInDegrees = convertMetersToDegrees(distanceFromPointsAndZoomlevel(markersWidth / 2, zoomLevel, (*i).latitude()), (*i).latitude());
            double minLon = (*i).longitude() - halfOfMarkerWidthInDegrees;
            double maxLon = (*i).longitude() + halfOfMarkerWidthInDegrees;
            if(minLat < minLatitude)  minLatitude = minLat;
            if(maxLat > maxLatitude)  maxLatitude = maxLat;
            if(minLon < minLongitude)  minLongitude = minLon;
            if(maxLon > maxLongitude)  maxLongitude = maxLon;
        }
        resultCoordinate = QGeoCoordinate((minLatitude + maxLatitude) / 2, (minLongitude + maxLongitude) / 2);
        double zoomlevelForHeight = zoomlevelFromDistanceAndPoints(convertDegreesToMeters(maxLatitude - minLatitude), mapHeight - indent*2, resultCoordinate.latitude());
        double zoomlevelForWidth = zoomlevelFromDistanceAndPoints(convertDegreesToMeters(maxLongitude - minLongitude, resultCoordinate.latitude()), mapWidth - indent*2, resultCoordinate.latitude());
        resultZoomLevel = std::min(zoomlevelForHeight, zoomlevelForWidth);
    }
    emit changeMapPosition(resultCoordinate, resultZoomLevel);
}

double Functions::zoomlevelFromDistanceAndPoints(const double &distInMeters, int numberOfPoints, const double &latitudeWhereYouAre) {
    return log2(numberOfPoints / 0.00000645 / distInMeters * cos(latitudeWhereYouAre * M_PI / 180.0));
}

double Functions::convertMetersToDegrees(double numderOfMeters, const double &currentLatitudeIfYouAreCalculatingLongitude) {
    return numderOfMeters / (40050000.0 * cos(currentLatitudeIfYouAreCalculatingLongitude * M_PI / 180.0) / 360.0);
}

double Functions::convertDegreesToMeters(double distInDegrees, const double &currentLatitudeIfYouAreCalculatingLongitude) {
    return distInDegrees * (40050000.0 * cos(currentLatitudeIfYouAreCalculatingLongitude * M_PI / 180.0) / 360.0);
}

double Functions::polylineLengthInMeters(const QList<QGeoCoordinate> &polyline)
{
    QList<QGeoCoordinate>::const_iterator i = polyline.begin();
    if(i == polyline.end())
        return 0;
    double length = 0;
    QGeoCoordinate previousCoordinate = *i;
    for(++i ; i != polyline.end(); previousCoordinate = *(i++))
        length += distBetwTwoCoordInMeters(previousCoordinate, *i);
    return length;
}

void Functions::compressRouteFromInternet(const QGeoCoordinate &coordA, const QGeoCoordinate &coordB, const QList<QGeoCoordinate> &path)
{
    QList<QGeoCoordinate> compressedRoute;
    if(true || path.size() < 3) // compression doesn't work well, so not used
        compressedRoute = path;
    else {
        compressedRoute.append(path.first());
        QList<QGeoCoordinate> tempRoute;
        QPair<int, QList<QGeoCoordinate>::const_iterator> indexAndIteratorPairOfLastAbbrevCoord;
        tempRoute.append(path.first());
        int indexOfLastAbbrevCoord = 0;
        QList<QGeoCoordinate>::const_iterator pathIterator = path.constBegin() + 1;
        for(int i = 1; i < path.size(); ++i, ++pathIterator) {
            tempRoute.append(path.at(i));
            if(i - indexOfLastAbbrevCoord < 2)
                continue;
            indexAndIteratorPairOfLastAbbrevCoord = QPair<int, QList<QGeoCoordinate>::const_iterator>(indexOfLastAbbrevCoord, tempRoute.constEnd() - (tempRoute.size() - indexOfLastAbbrevCoord));
            if(isPolylineNeededToAbbrev(tempRoute, indexAndIteratorPairOfLastAbbrevCoord, 0.5)) {
                indexOfLastAbbrevCoord = indexAndIteratorPairOfLastAbbrevCoord.first;
                compressedRoute.append(*indexAndIteratorPairOfLastAbbrevCoord.second);
            }
        }
        compressedRoute.append(path.last());
    }
    compressedRoute.prepend(coordA);
    compressedRoute.append(coordB);
    emit putTheRouteInTemporaryStorage(compressedRoute);
}

void Functions::getDateAndTimeForExtraOpt()
{
    QDateTime currentDT = QDateTime::currentDateTime();
    int currentHour = currentDT.time().hour();
    int currentHourPlus1Hour = currentDT.time().addSecs(3600).hour();
    int currentMinute = currentDT.time().minute();
    bool isFromTimeAmOrPm;
    bool isToTimeAmOrPm;
    if(!is24HourFormat) {
        isFromTimeAmOrPm = currentHour < 12;
        if(!isFromTimeAmOrPm)
            currentHour -= 12;
        isToTimeAmOrPm = currentHourPlus1Hour < 12;
        if(!isToTimeAmOrPm)
            currentHourPlus1Hour -= 12;
    }
    QString strCurrentHour = QString::number(currentHour);
    QString strCurrentHourPlus1Hour = QString::number(currentHourPlus1Hour);
    QString strCurrentMinute = QString::number(currentMinute);
    if(currentHour < 10) strCurrentHour = "0" + strCurrentHour;
    if(currentHourPlus1Hour < 10) strCurrentHourPlus1Hour = "0" + strCurrentHourPlus1Hour;
    if(currentMinute < 10) strCurrentMinute = "0" + strCurrentMinute;
    QString fromCheckOutTime = strCurrentHour + ":" + strCurrentMinute;
    QString toCheckOutTime = strCurrentHourPlus1Hour + ":" + strCurrentMinute;
    int day1 = currentDT.date().day();
    int day2 = currentDT.date().addDays(1).day();
    int day3 = currentDT.date().addDays(2).day();
    int day4 = currentDT.date().addDays(3).day();
    int month1 = currentDT.date().month();
    int month2 = currentDT.date().addDays(1).month();
    int month3 = currentDT.date().addDays(2).month();
    int month4 = currentDT.date().addDays(3).month();
    int year1 = currentDT.date().year();
    int year2 = currentDT.date().addDays(1).year();
    int year3 = currentDT.date().addDays(2).year();
    int year4 = currentDT.date().addDays(3).year();
    QString datePlus2Days = createStrDate(day3, month3, year3);
    QString datePlus3Days = createStrDate(day4, month4, year4);
    emit updateDateAndTimeForExtraOpt(is24HourFormat, fromCheckOutTime, isFromTimeAmOrPm, toCheckOutTime, isToTimeAmOrPm, day1, day2, day3, day4, month1, month2, month3, month4, year1, year2, year3, year4, datePlus2Days, datePlus3Days, currentHourPlus1Hour < currentHour);
}

QString Functions::createStrDate(int day, int month, int year)
{
    QString strDay = QString::number(day);
    QString strMonth;
    if(QLocale().language() == QLocale::Russian) {
        if(month == 1) strMonth = "янв";
        else if(month == 2) strMonth = "фев";
        else if(month == 3) strMonth = "мар";
        else if(month == 4) strMonth = "апр";
        else if(month == 5) strMonth = "мая";
        else if(month == 6) strMonth = "июня";
        else if(month == 7) strMonth = "июля";
        else if(month == 8) strMonth = "авг";
        else if(month == 9) strMonth = "сен";
        else if(month == 10) strMonth = "окт";
        else if(month == 11) strMonth = "ноя";
        else if(month == 12) strMonth = "дек";
    }
    else {
        if(month == 1) strMonth = "Jan";
        else if(month == 2) strMonth = "Feb";
        else if(month == 3) strMonth = "Mar";
        else if(month == 4) strMonth = "Apr";
        else if(month == 5) strMonth = "May";
        else if(month == 6) strMonth = "June";
        else if(month == 7) strMonth = "July";
        else if(month == 8) strMonth = "Aug";
        else if(month == 9) strMonth = "Sep";
        else if(month == 10) strMonth = "Oct";
        else if(month == 11) strMonth = "Nov";
        else if(month == 12) strMonth = "Dec";
    }
    QString strYear = QString::number(year);
    if(QLocale().language() == QLocale::Russian)
        return strDay + " " + strMonth + " " + strYear;
    else
        return strMonth + " " + strDay + " " + strYear;
}

quint32 Functions::localDateAndTimeStrToMinSinceEpoch(const QString &timeStr, bool isTimeAmOrPm, int day, int month, int year)
{
    QString variedVariable;
    variedVariable.push_back(timeStr.at(0));
    variedVariable.push_back(timeStr.at(1));
    int hour = variedVariable.toInt();
    if(!is24HourFormat && !isTimeAmOrPm)
        hour += 12;
    variedVariable.clear();
    variedVariable.push_back(timeStr.at(3));
    variedVariable.push_back(timeStr.at(4));
    int minute = variedVariable.toInt();
    return QDateTime(QDate(year, month, day), QTime(hour, minute), Qt::LocalTime).toSecsSinceEpoch() / 60;
}
