#ifndef SQUAREMANAGER_H
#define SQUAREMANAGER_H

#include <QtGlobal>
#include <QVector>
#include "commonDataStructures.h"
#include <QHash>
#include <QSet>

class SquareManager
{
public:
    SquareManager();
    void add(quint32 tripId, const QVector<coord> &route, quint32 fromDepartureTime, quint32 toDepartureTime, quint16 emptySeats);
    void remove(quint32 tripId, const QVector<coord> &route);
    void find(coord markerA, coord markerB, quint16 searchRadius, quint16 numberOfPeople,
              quint32 fromDepartureTime, quint32 toDepartureTime, QVector<quint32> &idArray);
    void getOldIds(QVector<quint32> &tripIds);

    void createSquaresForRoute(const QVector<coord> &route, QList<quint32> &squares);
    void addSquaresBetweenTwoPoints(coord coord1, coord coord2, QList<quint32> &squares);
    void addSquaresAroundThePoint(coord markerCoord, quint16 searchRadius, QList<quint32> *squares);
    static double distBetwTwoCoordInMeters(coord coord1, coord coord2);
    static bool routeMatchingCheck(const QVector<coord> &route, coord markerA, coord markerB, quint16 searchRadius);

    quint32 mergeSquare(qint16 lat, qint16 lon);
private:
    struct info {
        info (quint32 fromDepartureTime, quint32 toDepartureTime,quint16 emptySeats)
            : fromDepartureTime(fromDepartureTime), toDepartureTime(toDepartureTime), emptySeats(emptySeats) {}
        quint32 fromDepartureTime; quint32 toDepartureTime;
        quint16 emptySeats;
    };
    QHash<quint32, QSet<quint32>> squaresBigArr; //this is QHash<MERGED SQUARE, QSet<TRIP ID>>
    QHash<quint32, info> tripInfo;               //this is QHash<TRIP ID, TRIP INFO>
};

#endif // SQUAREMANAGER_H
