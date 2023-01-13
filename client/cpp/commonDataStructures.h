#ifndef COMMONDATASTRUCTURES_H
#define COMMONDATASTRUCTURES_H

#include <QtGlobal>
#include <QVector>
#include <QString>

struct coord {
    coord();
    coord(qint32 latit, qint32 longit);
    qint32 latit;
    qint32 longit;
};

struct dataForPlanATripRequest {
    quint16 routeCoordNumber; QVector<coord> route;
    quint32 fromDepartureTime; quint32 toDepartureTime;
    quint16 emptySeats;
    quint16 currencyNumber; QString estimatedPrice;
    QString comment;
    QString name;
    QString contacts;
};

struct answerForPlanATripRequest {
    quint32 tripId;
    quint16 deleteCode;
    quint16 routeCoordNumber; QVector<coord> route;
    quint32 fromDepartureTime; quint32 toDepartureTime;
    quint16 emptySeats;
    quint16 currencyNumber; QString estimatedPrice;
    QString comment;
    QString name;
    QString contacts;
};

struct dataForSearchForADriverRequest {
    coord markerA;
    coord markerB;
    quint32 fromDepartureTime; quint32 toDepartureTime;
    quint16 numberOfPeople;
    quint16 searchRadius;
};

struct answerForSearchForADriverRequest {
    quint32 degreeOfSuitability;
    quint16 routeCoordNumber; QVector<coord> route;
    quint32 fromDepartureTime; quint32 toDepartureTime;
    quint16 emptySeats;
    quint16 currencyNumber; QString estimatedPrice;
    QString comment;
    QString name;
    QString contacts;
};

struct dataForDeleteATripRequest {
    quint32 tripId;
    quint16 deleteCode;
};

struct answerForDeleteATripRequest {
    quint32 tripId;
};

struct dataForCheckTheAcceptanceVersion {
    quint16 version;
};

struct termsOfUseAndPrivPol {
    quint16 version;
    QString touHeader_en;
    QString touText_en;
    QString ppHeader_en;
    QString ppText_en;
    QString touHeader_ru;
    QString touText_ru;
    QString ppHeader_ru;
    QString ppText_ru;
};

#endif // COMMONDATASTRUCTURES_H
