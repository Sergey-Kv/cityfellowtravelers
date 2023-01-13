#ifndef FUNCTIONS_H
#define FUNCTIONS_H

#include <QObject>
#include <QGeoCoordinate>
#include <QString>

class Functions : public QObject
{
    Q_OBJECT
public:
    explicit Functions(QObject *parent = nullptr);
    Q_INVOKABLE static double distBetwTwoCoordInMeters(const QGeoCoordinate &coord1, const QGeoCoordinate &coord2);
    static double pointsFromDistanceAndZoomlevel(double distInMeters, double zoomLevel, double latitudeWhereYouAre);
    static double distanceFromPointsAndZoomlevel(int numberOfPoints, double zoomLevel, double latitudeWhereYouAre);
    static bool isPolylineNeededToAbbrev(const QList<QGeoCoordinate> &polyline, QPair<int, QList<QGeoCoordinate>::const_iterator> &indexAndIteratorPairOfLastAbbrevCoord, double distOfPermissibleVariationInMeters);

    Q_INVOKABLE void calculateMapPositionToShow1Route(const QList<QGeoCoordinate> &route1, const QGeoCoordinate& markerA, const QGeoCoordinate& markerB, double markersWidth, double markersHeight, double mapWidth, double mapHeight, double indent);
    Q_INVOKABLE void calculateMapPositionToShow2Route(const QList<QGeoCoordinate> &route1, const QList<QGeoCoordinate> &route2, const QGeoCoordinate &markerA, const QGeoCoordinate &markerB, double markersWidth, double markersHeight, double mapWidth, double mapHeight, double indent);
    Q_INVOKABLE void calculateMapPositionToShow2Markers(const QGeoCoordinate &markerA, const QGeoCoordinate &markerB, double markersWidth, double markersHeight, double mapWidth, double mapHeight, double indent);
    Q_INVOKABLE void calculateMapPositionToShow1RouteAnd4Markers(const QList<QGeoCoordinate> &route1, const QGeoCoordinate& drivMarkerA, const QGeoCoordinate& drivMarkerB, const QGeoCoordinate& passMarkerA, const QGeoCoordinate& passMarkerB, double markersWidth, double markersHeight, double mapWidth, double mapHeight, double indent);
    void calculateMapPositionToShowMapElemens(const QList<QList<QGeoCoordinate>> &routes, const QList<QGeoCoordinate> &markers, double markersWidth, double markersHeight, double mapWidth, double mapHeight, double indent);
    static double zoomlevelFromDistanceAndPoints(const double& distInMeters, int numberOfPoints, const double &latitudeWhereYouAre);
    static double convertMetersToDegrees(double numderOfMeters, const double &currentLatitudeIfYouAreCalculatingLongitude = 0);
    static double convertDegreesToMeters(double distInDegrees, const double &currentLatitudeIfYouAreCalculatingLongitude = 0);
    Q_INVOKABLE static double polylineLengthInMeters(const QList<QGeoCoordinate> &polyline);
    Q_INVOKABLE void compressRouteFromInternet(const QGeoCoordinate &coordA, const QGeoCoordinate &coordB, const QList<QGeoCoordinate> &path);
    Q_INVOKABLE void getDateAndTimeForExtraOpt();
    static quint32 localDateAndTimeStrToMinSinceEpoch(const QString &timeStr, int day, int month, int year);

signals:
    void changeMapPosition(const QGeoCoordinate &mapCenter_fq, double mapZoomLevel_fq);
    void putTheRouteInTemporaryStorage(const QList<QGeoCoordinate> &route_fq);
    void updateDateAndTimeForExtraOpt(const QString &fromCheckOutTime_fq, const QString &toCheckOutTime_fq, int day1_fq, int day2_fq, int day3_fq, int day4_fq, int month1_fq, int month2_fq, int month3_fq, int month4_fq, int year1_fq, int year2_fq, int year3_fq, int year4_fq, const QString &datePlus2Days_fq, const QString &datePlus3Days_fq, bool withTransition_fq);
};

#endif // FUNCTIONS_H
