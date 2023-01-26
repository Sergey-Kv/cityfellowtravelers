#ifndef DATAHANDLER_H
#define DATAHANDLER_H

#include <QDataStream>
#include <QHostAddress>
#include "requestcounttracker.h"
#include <QVector>
#include <QList>
#include "squaremanager.h"
#include <QSqlDatabase>
#include <QSqlQuery>
#include <QString>
#include <QHash>

class DataHandler
{
public:
    DataHandler();
    void handleTheRequest(QDataStream &inOfClientDataBlock, QHostAddress ipAddress, RequestCountTracker &requestCountTracker, QDataStream &outOfDataBlock);
    void handleCode2(QDataStream &inOfClientDataBlock, RequestCountTracker &requestCountTracker, QDataStream &outOfDataBlock);
    void handleCode10(QDataStream &inOfClientDataBlock, QHostAddress ipAddress, RequestCountTracker &requestCountTracker, QDataStream &outOfDataBlock);
    void handleCode11(QDataStream &inOfClientDataBlock, QHostAddress ipAddress, RequestCountTracker &requestCountTracker, QDataStream &outOfDataBlock);
    void handleCode12(QDataStream &inOfClientDataBlock, QHostAddress ipAddress, RequestCountTracker &requestCountTracker, QDataStream &outOfDataBlock);
    void handleCode13(QDataStream &inOfClientDataBlock, QDataStream &outOfDataBlock);
    void editStatistics(quint32 numberOfUniqueConnectedIpAddresses);
    void incrementNumberOfConnectionsExceedingTheDailyLimit(bool isMaxLimit);
    void clearTheOldData();
    ~DataHandler();
    quint32 minimumAllowedMinutes;
    quint32 maximumAllowedMinutes;

private:
    termsOfUseAndPrivPol touAndPp;
    QSqlDatabase db;
    QSqlQuery* query;
    QString pathToDatabase;
    SquareManager squaManager;
    qint64 adminPassword;
    struct forStatistics {
        forStatistics();
        quint32 numberOfRequestsToCreateATripRejectedDueToExceedingTheDailyLimit;
        quint32 numberOfRequestsToCreateATrip; // without NORTCATRDTETDL
        quint32 numberOfRequestsToCreateATripThatEndedSuccessfully;
        quint32 numberOfRequestsToSearchForADriverRejectedDueToExceedingTheDailyLimit;
        quint32 numberOfRequestsToSearchForADriver; // without NORTSFADRDTETDL
        quint32 numberOfRequestsToSearchForADriverThatEndedSuccessfullyAndWhereSomethingWasFound;
        quint32 numberOfRequestsToSearchForADriverThatEndedSuccessfullyAndWhereNothingWasFound;
        quint32 numberOfRequestsToDeleteATripRejectedDueToExceedingTheDailyLimit;
        quint32 numberOfRequestsToDeleteATrip; // without NORTDATRDTETDL
        quint32 numberOfRequestsToCheckTouAndPp;
        quint32 numberOfConnectionsExceedingTheDailyMaxLimit;
        quint32 numberOfConnectionsExceedingTheDailyLimit; // with answering
        quint32 numberOfUniqueConnectedIpAddresses;
    };
    QList<forStatistics> statistics;

    /*struct dataForDb {
        quint16 deleteCode;
        quint16 routeCoordNumber; QVector<coord> route;
        quint32 fromDepartureTime; quint32 toDepartureTime;
        quint16 emptySeats;
        quint16 currencyNumber; QString estimatedPrice;
        QString comment;
        QString name;
        QString contacts;
        QHostAddress ipAddress;
        quint32 creationTime;
    };*/
};

#endif // DATAHANDLER_H
