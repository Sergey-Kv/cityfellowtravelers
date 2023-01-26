#ifndef TRIPSMANAGER_H
#define TRIPSMANAGER_H

#include <QObject>
#include <QtGlobal>
#include <QDataStream>
#include <QList>
#include <QGeoCoordinate>
#include <QString>
#include <QVector>

class TripsManager : public QObject
{
    Q_OBJECT
public:
    explicit TripsManager(QObject *parent = nullptr);
    Q_INVOKABLE void loadMyTripsFromFiles();
    Q_INVOKABLE void fillTheModelWithInformationAboutMyTrips();
    bool addTheTripToMyTrips(QDataStream &inOfServerDataBlock);
    Q_INVOKABLE int getTripIdOfMyTrip(int index);
    Q_INVOKABLE int getDeleteCodeOfMyTrip(int index);
    void removeTheTripFromMyTrips(QDataStream &inOfServerDataBlock);
    Q_INVOKABLE void getRouteForThisIndexForMyTrips(int index);
    Q_INVOKABLE QString getTextWithCommentForThisIndexForMyTrips(int index);
    Q_INVOKABLE QString getContactsTextForThisIndexForMyTrips(int index);
    int getMyTripCount();

    void loadFoundRoutes(QDataStream &inOfServerDataBlock);
    Q_INVOKABLE void fillTheModelWithInformationAboutFoundTrips();
    Q_INVOKABLE void getRouteForThisIndexForFoundTrips(int index);
    Q_INVOKABLE QString getTextWithCommentForThisIndexForFoundTrips(int index);
    Q_INVOKABLE QString getContactsTextForThisIndexForFoundTrips(int index);

private:
    QString pathToAppDataLocation;

    struct myTrip {
        quint32 tripId;
        quint16 deleteCode;
        QList<QGeoCoordinate> route;
        quint32 fromDepartureTime; quint32 toDepartureTime;
        quint16 emptySeats;
        quint16 currencyNumber; QString estimatedPrice;
        QString comment;
        QString name;
        QString contacts;
        QString fileName;
    };
    bool areMyTripsLoadedFromFiles;
    QVector<myTrip> myTrips;

    struct foundTrip {
        quint32 degreeOfSuitability;
        QList<QGeoCoordinate> route;
        quint32 fromDepartureTime; quint32 toDepartureTime;
        quint16 emptySeats;
        quint16 currencyNumber; QString estimatedPrice;
        QString comment;
        QString name;
        QString contacts;
    };
    QGeoCoordinate markerA;
    QGeoCoordinate markerB;
    QVector<foundTrip> foundTrips;

    struct boolAndQStringPointer
    {
        boolAndQStringPointer(bool objectWithSpaces, QString *objectPointer);
        bool objectWithSpaces;
        QString *objectPointer;
    };

    template<typename T>
    static QString generateTextForTripElement(const T &trip, const QDate &currDate);
    static QString intToTwoCharQString(int number);

signals:
    void insertTrip(const QString &text_fq, bool beginOrEnd_fq);
    void removeMyTrip(int index_fq);
    void installRouteForMyTrip(const QList<QGeoCoordinate> &route_fq, const QGeoCoordinate& drivMarkerA_fq, const QGeoCoordinate& drivMarkerB_fq);
    void installRouteForFoundTrip(const QList<QGeoCoordinate> &route_fq, const QGeoCoordinate& drivMarkerA_fq, const QGeoCoordinate& drivMarkerB_fq, const QGeoCoordinate& passMarkerA_fq, const QGeoCoordinate& passMarkerB_fq);
};

#endif // TRIPSMANAGER_H
