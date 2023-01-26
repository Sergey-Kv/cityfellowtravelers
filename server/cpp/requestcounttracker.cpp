#include "requestcounttracker.h"

RequestCountTracker::RequestCountTracker() {}

bool RequestCountTracker::execute(Task task, Object object, QHostAddress ipAdress) {
    QHash<QHostAddress, NumberOfRequestsToday>::iterator it = requestsCountTable.find(ipAdress);
    if(it == requestsCountTable.end()) {
        requestsCountTable.insert(ipAdress, NumberOfRequestsToday());
        return false;
    }

    quint16 *objectPointer;
    switch(object) {
    case Object::Connections: { objectPointer = &it.value().numberOfConnections; break; }
    case Object::ConnectionsMax: { objectPointer = &it.value().numberOfConnections; break; }
    case Object::RequestsToPlanATrip: { objectPointer = &it.value().numberOfRequestsToPlanATrip; break; }
    case Object::RequestsToSearchForADriver: { objectPointer = &it.value().numberOfRequestsToSearchForADriver; break; }
    case Object::RequestsToDeleteATrip: { objectPointer = &it.value().numberOfRequestsToDeleteATrip; break; }
    }

    if((task == Task::Increment || task == Task::IncrementAndCheck) && *objectPointer < 65535)
        ++*objectPointer;

    if(task == Task::IncrementAndCheck || task == Task::Check) {
        switch(object) {
        case Object::Connections: { return *objectPointer > 300; break; }
        case Object::ConnectionsMax: { return *objectPointer > 1000; break; }
        case Object::RequestsToPlanATrip: { return *objectPointer > 100; break; }
        case Object::RequestsToSearchForADriver: { return *objectPointer > 200; break; }
        case Object::RequestsToDeleteATrip: { return *objectPointer > 300; break; }
        }
    }
    return false;
}

void RequestCountTracker::reset() {
    requestsCountTable.clear();
}

int RequestCountTracker::getTheNumberOfUniqueIpAddressesConnectedInTheLastDay() {
    return requestsCountTable.size();
}

RequestCountTracker::NumberOfRequestsToday::NumberOfRequestsToday()
    : numberOfConnections(1),
      numberOfRequestsToPlanATrip(0),
      numberOfRequestsToSearchForADriver(0),
      numberOfRequestsToDeleteATrip(0) {}
