#ifndef REQUESTCOUNTTRACKER_H
#define REQUESTCOUNTTRACKER_H

#include <QHash>
#include <QHostAddress>

class RequestCountTracker
{
public:
    RequestCountTracker();
    enum class Task {Increment, IncrementAndCheck, Check};
    enum class Object {Connections, ConnectionsMax, RequestsToPlanATrip, RequestsToSearchForADriver, RequestsToDeleteATrip};
    bool execute(Task task, Object object, QHostAddress ipAdress);
    void reset();

private:
    struct NumberOfRequestsToday
    {
        NumberOfRequestsToday();
        quint16 numberOfConnections;
        quint16 numberOfRequestsToPlanATrip;
        quint16 numberOfRequestsToSearchForADriver;
        quint16 numberOfRequestsToDeleteATrip;
    };
    QHash<QHostAddress, NumberOfRequestsToday> requestsCountTable;
};

#endif // REQUESTCOUNTTRACKER_H
