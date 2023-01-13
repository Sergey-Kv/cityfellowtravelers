#ifndef ROUTEDRAWING_H
#define ROUTEDRAWING_H

#include <QObject>
#include <QGeoCoordinate>

class RouteDrawing : public QObject
{
    Q_OBJECT
private:
    QList<QGeoCoordinate> detailedPolyLine;
    QList<int> listOfIndexesOnDplMeaningAbbrevPolyLine;
    int indexOfLastVisibleDplCoordOnDpl;
    bool isAdditCoordOnDplExist;
    QGeoCoordinate additCoordOnDpl;
    bool isLastCoordOnDplIsCoordOfMarkerB;

public:
    explicit RouteDrawing(QObject *parent = nullptr);
    Q_INVOKABLE void newCoordArrived(const QGeoCoordinate &newCoord, double zoomLevel, bool isThisCoordOfMarkerB = false);
    Q_INVOKABLE void undoButtonPressed(double zoomLevel, int averageMapAreaLength, double latitudeWhereYouAre);
    Q_INVOKABLE void redoButtonPressed(double zoomLevel, int averageMapAreaLength, double latitudeWhereYouAre);
    Q_INVOKABLE void prepareRouteDrawing(const QGeoCoordinate &firstCoord);
    Q_INVOKABLE void getPathForQmlPolyline();
    Q_INVOKABLE static int distBetwTwoPoints(int x1, int x2, int y1, int y2);
    Q_INVOKABLE static int distBetwTwoCoordInPoints(const QGeoCoordinate &coord1, const QGeoCoordinate &coord2, double zoomLevel);

private:    //auxiliary functions
    bool movingNeededDitance(const QGeoCoordinate &beginCoord, const QGeoCoordinate &endCoord, double &distanceNeededToGo);

signals:
    void changeRouteDrawingDataInQml(int howManyCoordinatesToDelete_fq, const QList<QGeoCoordinate> &listOfCoordinatesToAdd_fq, bool stateForUndoButton_fq, bool stateForRedoButton_fq, bool isRouteFullyDrawn_fq);
    void updatePathOfQmlPolyline(const QList<QGeoCoordinate> &path_fq);
};

#endif // ROUTEDRAWING_H
