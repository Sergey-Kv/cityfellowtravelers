/* server responses:
   c1_1_  - server ip address has changed, set a new one
    1_2   - too many connections today from your ip address
    1_3   - can't work with your app version
    1_4   - invalid operation code
   c1_5_  - show this message on the screen
    1_6   - your data is incorrect
    2_3   - incorrect administrator password
    2_4   - server is runninng
   c10_1_ - server ip address has changed, set a new one and repeat the request to plan a trip
    10_2  - too many requests to plan a trip today from your ip address
    10_3  - error on server: value "lastDriversTripId" not found in database
    10_4_ - request to plan a trip completed successfully, take your data
   c11_1_ - server ip address has changed, set a new one and repeat the request to search for a driver
    11_2  - too many requests to search for a driver today from your ip address
    11_3_ - request to search for a driver completed successfully, take your data
   c12_1_ - server ip address has changed, set a new one and repeat the request to delete a trip
    12_2  - too many requests to delete a trip today from your ip address
    12_3_ - request to delete a trip completed successfully, take your data
   c13_1_ - server ip address has changed, set a new one and repeat the request to check the acceptance version
    13_2  - you have a valid acceptance version
    13_3_ - you have an invalid acceptance version, take valid version data

c - only handled on the client side
*/

#include "datahandler.h"
#include <QFileInfo>
#include <QFile>
#include <QCoreApplication>
#include "timecout.h"
#include <QtGlobal>
#include <QVector>
#include <cmath>
#include <algorithm>
#include <QDateTime>
#include <QRandomGenerator>

DataHandler::DataHandler()
    : pathToDatabase("trips.db"),
      query(nullptr)
{
    QFileInfo checkFile("bin/termsOfUseAndPrivacyPolicy.bin");
    if(checkFile.exists() && checkFile.isFile()) {
        QFile fileObj("bin/termsOfUseAndPrivacyPolicy.bin");
        if(fileObj.open(QIODevice::ReadOnly)) {
            QDataStream inOfFileObj(&fileObj);
            inOfFileObj.setVersion(QDataStream::Qt_5_15);
            inOfFileObj >> touAndPp.version
                    >> touAndPp.touHeader_en
                    >> touAndPp.touText_en
                    >> touAndPp.ppHeader_en
                    >> touAndPp.ppText_en
                    >> touAndPp.touHeader_ru
                    >> touAndPp.touText_ru
                    >> touAndPp.ppHeader_ru
                    >> touAndPp.ppText_ru;
        }
        else {
            ticerr() << "Error: Could not open termsOfUseAndPrivacyPolicy.bin" << std::endl;
            fileObj.close();
            return;
        }
        fileObj.close();
    }
    else {
        ticerr() << "Error: File termsOfUseAndPrivacyPolicy.bin not found" << std::endl;
        return;
    }
    QFileInfo checkFile2("bin/adminPassword.bin");
    if(checkFile2.exists() && checkFile2.isFile()) {
        QFile fileObj("bin/adminPassword.bin");
        if(fileObj.open(QIODevice::ReadOnly)) {
            QDataStream inOfFileObj(&fileObj);
            inOfFileObj.setVersion(QDataStream::Qt_5_15);
            inOfFileObj >> adminPassword;
        }
        else {
            ticerr() << "Error: Could not open adminPassword.bin" << std::endl;
            fileObj.close();
            return;
        }
        fileObj.close();
    }
    else {
        ticerr() << "Error: File adminPassword.bin not found" << std::endl;
        return;
    }
    quint32 currentMinSinceEpoch = QDateTime::currentSecsSinceEpoch() / 60;
    minimumAllowedMinutes = currentMinSinceEpoch - 1440;
    maximumAllowedMinutes = currentMinSinceEpoch + 1440 * 7;

    QFileInfo checkFile3(pathToDatabase);
    bool fileExists3 = checkFile3.exists() && checkFile3.isFile();
    db = QSqlDatabase::addDatabase("QSQLITE"); //QPSQL //QODBC
    //db.setHostName("127.0.0.1");
    db.setDatabaseName(pathToDatabase);
    //db.setUserName("postgres");
    //db.setPassword("password");
    if(!db.open()) {
        ticerr() << "Error: Could not open database" << std::endl;
        return;
    }
    query = new QSqlQuery(db);
    if(!fileExists3) {
        query->exec("CREATE TABLE DataForDatabase(lastDriversTripId INT NOT NULL);");
        query->exec("CREATE TABLE DriversTrips(id INT NOT NULL, data BLOB NOT NULL);");
        query->exec("INSERT INTO DataForDatabase(lastDriversTripId) VALUES (1)");
        ticout() << "Database not found. New one created" << std::endl;;
    }
    else {
        quint32 lastTripId;
        query->exec("SELECT lastDriversTripId FROM DataForDatabase");
        if(query->next()) {
            lastTripId = query->value(0).toUInt();
            ticout() << "The value of the variable \"lastDriversTripId\": " << lastTripId << std::endl;
        }
        else {
            ticerr() << "Error: Failed to retrieve the value of the variable \"lastDriversTripId\" from the database." << std::endl;
            return;
        }
        ticout() << "Adding data from the database. Finding trips..." << std::endl;
        QVector<quint32> tripIds;
        query->exec("SELECT id FROM DriversTrips");
        while(query->next())
            tripIds.append(query->value(0).toUInt());
        ticout() << tripIds.size() << " trips found";
        if(tripIds.size() != 0)
            std::cout << ". Processing...";
        std::cout << std::endl;
        QByteArray tripData;
        quint16 deleteCode;
        quint16 routeCoordNumber; QVector<coord> route; coord temp;
        quint32 fromDepartureTime; quint32 toDepartureTime;
        quint16 emptySeats;
        int i = 0;
        for(QVector<quint32>::const_iterator it = tripIds.constBegin(); it != tripIds.constEnd(); ++it, ++i) {
            query->prepare("SELECT data FROM DriversTrips WHERE id = ?");
            query->addBindValue(*it);
            query->exec();
            if(!query->next()) {
                ticerr() << "Error: Id \"" << *it << "\" not found in database" << std::endl;
                continue;
            }
            tripData = query->value(0).toByteArray();
            QDataStream inOfTripData(&tripData, QIODevice::ReadOnly);
            inOfTripData.setVersion(QDataStream::Qt_5_15);
            inOfTripData >> deleteCode >> routeCoordNumber;
            route.clear();
            route.reserve(routeCoordNumber);
            for(quint16 i = 0; i < routeCoordNumber; ++i) {
                inOfTripData >> temp.latit >> temp.longit;
                route.append(temp);
            }
            inOfTripData >> fromDepartureTime >> toDepartureTime
                    >> emptySeats;
            squaManager.add(*it, route, fromDepartureTime, toDepartureTime, emptySeats);
            if(i % 10000 == 9999)
                ticout() << i + 1 << " trips processed..." << std::endl;
        }
    }
}

void DataHandler::handleTheRequest(QDataStream &inOfClientDataBlock, QHostAddress ipAddress, RequestCountTracker &requestCountTracker, QDataStream &outOfDataBlock)
{
    quint16 version;
    inOfClientDataBlock >> version;
    if(version < 100) {
        outOfDataBlock << quint8(1) << quint8(3);
        return;
    }
    quint8 operationCode;
    inOfClientDataBlock >> operationCode;
    switch(operationCode) {
    case 2: { handleCode2(inOfClientDataBlock, outOfDataBlock); break; }
    case 10: { handleCode10(inOfClientDataBlock, ipAddress, requestCountTracker, outOfDataBlock); break; }
    case 11: { handleCode11(inOfClientDataBlock, ipAddress, requestCountTracker, outOfDataBlock); break; }
    case 12: { handleCode12(inOfClientDataBlock, ipAddress, requestCountTracker, outOfDataBlock); break; }
    case 13: { handleCode13(inOfClientDataBlock, outOfDataBlock); break; }
    default: { outOfDataBlock << quint8(1) << quint8(4); break; }
    }
}

void DataHandler::handleCode2(QDataStream &inOfClientDataBlock, QDataStream &outOfDataBlock)
{
    qint64 password;
    inOfClientDataBlock >> password;
    if(password != adminPassword) {
        outOfDataBlock << quint8(2) << quint8(3);
        return;
    }
    bool checkOrStop;
    inOfClientDataBlock >> checkOrStop;
    if(checkOrStop)
        outOfDataBlock << quint8(2) << quint8(4);
    else
        QCoreApplication::quit();
}

void DataHandler::handleCode10(QDataStream &inOfClientDataBlock, QHostAddress ipAddress, RequestCountTracker &requestCountTracker, QDataStream &outOfDataBlock)
{
    if(requestCountTracker.execute(RequestCountTracker::Task::IncrementAndCheck,
                                   RequestCountTracker::Object::RequestsToPlanATrip,
                                   ipAddress)) {
        outOfDataBlock << quint8(10) << quint8(2);
        return;
    }
    dataForPlanATripRequest data;
    inOfClientDataBlock >> data.routeCoordNumber;
    if(data.routeCoordNumber > 50000) {
        outOfDataBlock << quint8(1) << quint8(6);
        return;
    }
    data.route.reserve(data.routeCoordNumber);
    coord temp;
    for(unsigned int i = 0; i < data.routeCoordNumber; ++i) {
        inOfClientDataBlock >> temp.latit >> temp.longit;
        if(temp.latit >= 900000000 || temp.latit <= -900000000 || temp.longit >= 1800000000 || temp.longit <= -1800000000) {
            outOfDataBlock << quint8(1) << quint8(6);
            return;
        }
        data.route.append(temp);
    }
    inOfClientDataBlock >> data.fromDepartureTime >> data.toDepartureTime
            >> data.emptySeats
            >> data.currencyNumber >> data.estimatedPrice
            >> data.comment
            >> data.name
            >> data.contacts;
    if(data.fromDepartureTime < minimumAllowedMinutes || data.fromDepartureTime > maximumAllowedMinutes || data.toDepartureTime < minimumAllowedMinutes || data.toDepartureTime > maximumAllowedMinutes
            || data.emptySeats < 1 || data.emptySeats > 200 || data.estimatedPrice.size() > 35 || data.comment.size() > 1100 || data.name.size() > 55 || data.contacts.size() > 220) {
        outOfDataBlock << quint8(1) << quint8(6);
        return;
    }

    quint32 tripId;
    query->exec("SELECT lastDriversTripId FROM DataForDatabase");
    if(query->next())
        tripId = query->value(0).toUInt();
    else {
        outOfDataBlock << quint8(10) << quint8(3);
        return;
    }
    if(tripId++ == 4294967295)
        tripId = 1;
    query->prepare("UPDATE DataForDatabase SET lastDriversTripId = ?");
    query->addBindValue(tripId);
    query->exec();
    quint32 creationTime = QDateTime::currentSecsSinceEpoch() / 60;
    QRandomGenerator randomGenerator(creationTime);
    //QRandomGenerator *randomGenerator(QRandomGenerator::global());
    quint16 deleteCode = randomGenerator.bounded(1, 65535);

    QByteArray tripData;
    QDataStream outOfTripData(&tripData, QIODevice::WriteOnly);
    outOfTripData.setVersion(QDataStream::Qt_5_15);
    outOfTripData << deleteCode << data.routeCoordNumber;
    for(QVector<coord>::const_iterator it = data.route.constBegin(); it != data.route.constEnd(); ++it)
        outOfTripData << it->latit << it->longit;
    outOfTripData << data.fromDepartureTime << data.toDepartureTime
                  << data.emptySeats
                  << data.currencyNumber << data.estimatedPrice
                  << data.comment
                  << data.name
                  << data.contacts
                  << ipAddress
                  << creationTime;

    query->prepare("INSERT INTO DriversTrips(id, data) VALUES (?, ?)");
    query->addBindValue(tripId);
    query->addBindValue(tripData);
    query->exec();

    squaManager.add(tripId, data.route, data.fromDepartureTime, data.toDepartureTime, data.emptySeats);

    outOfDataBlock << quint8(10) << quint8(4) << tripId
                   << deleteCode
                   << data.routeCoordNumber;
    for(QVector<coord>::const_iterator it = data.route.constBegin(); it != data.route.constEnd(); ++it)
        outOfDataBlock << it->latit << it->longit;
    outOfDataBlock << data.fromDepartureTime << data.toDepartureTime
                   << data.emptySeats
                   << data.currencyNumber << data.estimatedPrice
                   << data.comment
                   << data.name
                   << data.contacts;
}

void DataHandler::handleCode11(QDataStream &inOfClientDataBlock, QHostAddress ipAddress, RequestCountTracker &requestCountTracker, QDataStream &outOfDataBlock)
{
    if(requestCountTracker.execute(RequestCountTracker::Task::IncrementAndCheck,
                                   RequestCountTracker::Object::RequestsToSearchForADriver,
                                   ipAddress)) {
        outOfDataBlock << quint8(11) << quint8(2);
        return;
    }
    dataForSearchForADriverRequest data;
    inOfClientDataBlock >> data.markerA.latit >> data.markerA.longit
            >> data.markerB.latit >> data.markerB.longit
            >> data.fromDepartureTime >> data.toDepartureTime
            >> data.numberOfPeople
            >> data.searchRadius;
    if(data.markerA.latit >= 900000000 || data.markerA.latit <= -900000000 || data.markerA.longit >= 1800000000 || data.markerA.longit <= -1800000000
            || data.markerB.latit >= 900000000 || data.markerB.latit <= -900000000 || data.markerB.longit >= 1800000000 || data.markerB.longit <= -1800000000
            || data.fromDepartureTime < minimumAllowedMinutes || data.fromDepartureTime > maximumAllowedMinutes || data.toDepartureTime < minimumAllowedMinutes || data.toDepartureTime > maximumAllowedMinutes
            || data.numberOfPeople < 1 || data.numberOfPeople > 200 || data.searchRadius < 10 || data.searchRadius > 1000) {
        outOfDataBlock << quint8(1) << quint8(6);
        return;
    }

    QVector<quint32> idArray;
    squaManager.find(data.markerA, data.markerB, data.searchRadius, data.numberOfPeople, data.fromDepartureTime, data.toDepartureTime, idArray);

    QVector<answerForSearchForADriverRequest> resVect;
    QByteArray tripData;
    answerForSearchForADriverRequest data2;
    coord temp;
    quint16 deleteCode;
    int truncated = std::min(idArray.size(), 10000);
    QVector<quint32>::const_iterator it = idArray.constBegin();
    for(int i = 0; i < truncated; ++i, ++it) {
        query->prepare("SELECT data FROM DriversTrips WHERE id = ?");
        query->addBindValue(*it);
        query->exec();
        if(!query->next()) //error
            continue;
        tripData = query->value(0).toByteArray();
        QDataStream inOfTripData(&tripData, QIODevice::ReadOnly);
        inOfTripData.setVersion(QDataStream::Qt_5_15);
        inOfTripData >> deleteCode >> data2.routeCoordNumber;
        data2.route.clear();
        data2.route.reserve(data2.routeCoordNumber);
        for(quint16 i = 0; i < data2.routeCoordNumber; ++i) {
            inOfTripData >> temp.latit >> temp.longit;
            data2.route.append(temp);
        }
        if(!SquareManager::routeMatchingCheck(data2.route, data.markerA, data.markerB, data.searchRadius))
            continue;
        inOfTripData >> data2.fromDepartureTime >> data2.toDepartureTime
                >> data2.emptySeats
                >> data2.currencyNumber >> data2.estimatedPrice
                >> data2.comment
                >> data2.name
                >> data2.contacts;
        data2.degreeOfSuitability = abs(qint32((data.fromDepartureTime + data.toDepartureTime) / 2) - qint32((data2.fromDepartureTime + data2.toDepartureTime) / 2));
        resVect.append(data2);
    }
    std::sort(resVect.begin(), resVect.end(), [](const answerForSearchForADriverRequest &a, const answerForSearchForADriverRequest &b) {
        return a.degreeOfSuitability < b.degreeOfSuitability;
    });
    int numberOfMatches = std::min(resVect.size(), 100);
    outOfDataBlock << quint8(11) << quint8(3)
                        << data.markerA.latit << data.markerA.longit
                        << data.markerB.latit << data.markerB.longit
                        << quint16(numberOfMatches);
    QVector<answerForSearchForADriverRequest>::const_iterator it2 = resVect.constBegin();
    for(int i = 0; i < numberOfMatches; ++i, ++it2) {
        outOfDataBlock << it2->degreeOfSuitability
                            << it2->routeCoordNumber;
        for(QVector<coord>::const_iterator it3 = it2->route.constBegin(); it3 != it2->route.constEnd(); ++it3)
            outOfDataBlock << it3->latit << it3->longit;
        outOfDataBlock << it2->fromDepartureTime << it2->toDepartureTime
                            << it2->emptySeats
                            << it2->currencyNumber << it2->estimatedPrice
                            << it2->comment
                            << it2->name
                            << it2->contacts;
    }
}

void DataHandler::handleCode12(QDataStream &inOfClientDataBlock, QHostAddress ipAddress, RequestCountTracker &requestCountTracker, QDataStream &outOfDataBlock)
{
    if(requestCountTracker.execute(RequestCountTracker::Task::IncrementAndCheck,
                                   RequestCountTracker::Object::RequestsToDeleteATrip,
                                   ipAddress)) {
        outOfDataBlock << quint8(12) << quint8(2);
        return;
    }
    dataForDeleteATripRequest data;
    inOfClientDataBlock >> data.tripId
            >> data.deleteCode;

    QByteArray tripData;
    query->prepare("SELECT data FROM DriversTrips WHERE id = ?");
    query->addBindValue(data.tripId);
    query->exec();
    if(!query->next()) {
        outOfDataBlock << quint8(12) << quint8(3) << data.tripId;
        return;
    }
    tripData = query->value(0).toByteArray();
    QDataStream inOfTripData(&tripData, QIODevice::ReadOnly);
    inOfTripData.setVersion(QDataStream::Qt_5_15);
    quint16 deleteCode;
    inOfTripData >> deleteCode;
    if(deleteCode != data.deleteCode) {
        outOfDataBlock << quint8(12) << quint8(3) << data.tripId;
        return;
    }
    quint16 routeCoordNumber;
    QVector<coord> route;
    inOfTripData >> routeCoordNumber;
    route.reserve(routeCoordNumber);
    coord temp;
    for(quint16 i = 0; i < routeCoordNumber; ++i) {
        inOfTripData >> temp.latit >> temp.longit;
        route.append(temp);
    }

    query->prepare("DELETE FROM DriversTrips WHERE id = ?");
    query->addBindValue(data.tripId);
    query->exec();

    squaManager.remove(data.tripId, route);
    outOfDataBlock << quint8(12) << quint8(3) << data.tripId;
}

void DataHandler::handleCode13(QDataStream &inOfClientDataBlock, QDataStream &outOfDataBlock)
{
    dataForCheckTheAcceptanceVersion data;
    inOfClientDataBlock >> data.version;
    if(data.version == touAndPp.version)
        outOfDataBlock << quint8(13) << quint8(2);
    else
        outOfDataBlock << quint8(13) << quint8(3) << touAndPp.version
                       << touAndPp.touHeader_en
                       << touAndPp.touText_en
                       << touAndPp.ppHeader_en
                       << touAndPp.ppText_en
                       << touAndPp.touHeader_ru
                       << touAndPp.touText_ru
                       << touAndPp.ppHeader_ru
                       << touAndPp.ppText_ru;
}

void DataHandler::clearTheOldData()
{
    QVector<quint32> tripIds;
    squaManager.getOldIds(tripIds);
    QByteArray tripData;
    quint16 deleteCode;
    quint16 routeCoordNumber;
    QVector<coord> route;
    coord temp;
    for(QVector<quint32>::const_iterator it = tripIds.constBegin(); it != tripIds.constEnd(); ++it) {
        query->prepare("SELECT data FROM DriversTrips WHERE id = ?");
        query->addBindValue(*it);
        query->exec();
        if(!query->next())
            continue;
        tripData = query->value(0).toByteArray();
        QDataStream inOfTripData(&tripData, QIODevice::ReadOnly);
        inOfTripData.setVersion(QDataStream::Qt_5_15);
        inOfTripData >> deleteCode
                >> routeCoordNumber;
        route.clear();
        route.reserve(routeCoordNumber);
        for(quint16 i = 0; i < routeCoordNumber; ++i) {
            inOfTripData >> temp.latit >> temp.longit;
            route.append(temp);
        }
        squaManager.remove(*it, route);
        query->prepare("DELETE FROM DriversTrips WHERE id = ?");
        query->addBindValue(*it);
        query->exec();
    }
}

DataHandler::~DataHandler() {
    delete query;
    db.close();
}
