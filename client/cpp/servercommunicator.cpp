#include "servercommunicator.h"
#include <QStandardPaths>
#include <QDataStream>
#include "functions.h"
#include <QDateTime>
#include <QRandomGenerator>
#include <QFileInfo>
#include <QFile>
#include <QDir>

ServerCommunicator::ServerCommunicator(TripsManager *tmnPointer, TouAndPpManager *tppPointer, QObject *parent)
    : QObject{parent},
      pathToAppDataLocation(QStandardPaths::writableLocation(QStandardPaths::AppDataLocation)),
      tmnPointer(tmnPointer),
      tppPointer(tppPointer),
      rsaEncr(QRSAEncryption::Rsa::RSA_1024),
      aesEncr(QAESEncryption::AES_128, QAESEncryption::ECB),
      applicationVersion(100),
      waitingForDisconnectedStateToConnect(false),
      sheduledTask(SheduledTaskForServer::None)
{
    extractServerAddress();

    //initialize public rsa key
    QFileInfo checkFile(":/bin/publicKey.bin");
    if(checkFile.exists() && checkFile.isFile()) {
        QFile fileObj(":/bin/publicKey.bin");
        if(fileObj.open(QIODevice::ReadOnly)) {
            QDataStream inOfFileObj(&fileObj);
            inOfFileObj.setVersion(QDataStream::Qt_5_15);
            inOfFileObj >> publicKey;
        }
        fileObj.close();
    }

    //initialize aes key
    QRandomGenerator* globalGenerator = QRandomGenerator::global();
    QRandomGenerator generator;
    for(int i = 0; i < 4; i++) {
        generator.seed(globalGenerator->bounded((quint32)0, (quint32)4294967295));
        for(int j = 0; j < 4; j++)
            aesKey.append(static_cast<qint8>(generator.bounded(-128, 128)));
    }

    connect(&myTcpSocket, SIGNAL(stateChanged(QAbstractSocket::SocketState)), this, SLOT(slotStateChanged(QAbstractSocket::SocketState)));
    connect(&myTcpSocket, SIGNAL(errorOccurred(QAbstractSocket::SocketError)), this, SLOT(slotErrorOccurred(QAbstractSocket::SocketError)));
    connect(&myTcpSocket, SIGNAL(readyRead()), this, SLOT(slotReadyRead()));

    serverResponseWaitingTimer.setSingleShot(true);
    connect(&serverResponseWaitingTimer, SIGNAL(timeout()), this, SLOT(slotServerResponseWaitingTimerAlarm()));
}

void ServerCommunicator::planATripRequest(const QList<QGeoCoordinate> &route, const QString &fromDepatrureTimeStr, int fromDepDateDay, int fromDepDateMonth, int fromDepDateYear, bool withToDepT, const QString &toDepatrureTimeStr, int toDepDateDay, int toDepDateMonth, int toDepDateYear, const QString &emptySeatsStr, int currencyNumber, const QString &estimatedPrice, const QString &comment, const QString &name, const QString &contacts, bool termsAcceped)
{
    if(tmnPointer->getMyTripCount() >= 20) {
        emit errorSenderInQml(true, 10, 1);
        return;
    }
    if(fromDepatrureTimeStr.size() != 5) {
        emit errorSenderInQml(true, 10, 2);
        return;
    }
    if(withToDepT && toDepatrureTimeStr.size() != 5) {
        emit errorSenderInQml(true, 10, 2);
        return;
    }
    quint32 fromTime = Functions::localDateAndTimeStrToMinSinceEpoch(fromDepatrureTimeStr, fromDepDateDay, fromDepDateMonth, fromDepDateYear);
    quint32 toTime;
    if(withToDepT)
        toTime = Functions::localDateAndTimeStrToMinSinceEpoch(toDepatrureTimeStr, toDepDateDay, toDepDateMonth, toDepDateYear);
    else
        toTime = fromTime;
    quint32 currMinSinceEpoch = QDateTime::currentSecsSinceEpoch() / 60;
    if(fromTime < currMinSinceEpoch - 10) {
        emit errorSenderInQml(true, 10, 3);
        return;
    }
    if(fromTime > toTime) {
        emit errorSenderInQml(true, 10, 4);
        return;
    }
    if(toTime > currMinSinceEpoch + (60 * 24 * 4)) {
        emit errorSenderInQml(true, 10, 5);
        return;
    }
    quint16 emptySeats = emptySeatsStr.toInt();
    if(emptySeats < 1 || emptySeats > 200) {
        emit errorSenderInQml(true, 10, 6);
        return;
    }
    if(comment.size() > 1000) {
        emit errorSenderInQml(true, 10, 7);
        return;
    }
    if(contacts.size() > 200) {
        emit errorSenderInQml(true, 10, 8);
        return;
    }
    if(contacts.size() < 1) {
        emit errorSenderInQml(true, 10, 9);
        return;
    }
    if(!termsAcceped) {
        emit errorSenderInQml(true, 10, 10);
        return;
    }
    QVector<coord> processedRoute;
    for(QList<QGeoCoordinate>::const_iterator it = route.constBegin(); it != route.constEnd(); ++it)
        processedRoute.append(coord(it->latitude() * 10000000, it->longitude() * 10000000));
    plATrData.routeCoordNumber = processedRoute.size();
    plATrData.route = processedRoute;
    plATrData.fromDepartureTime = fromTime;
    plATrData.toDepartureTime = toTime;
    plATrData.emptySeats = emptySeats;
    plATrData.currencyNumber = currencyNumber;
    plATrData.estimatedPrice = estimatedPrice;
    plATrData.comment = comment;
    plATrData.name = name;
    plATrData.contacts = contacts;
    sheduledTask = SheduledTaskForServer::PlanATrip;
    tryToSendData(10000);
}

void ServerCommunicator::searchForADriverRequest(const QGeoCoordinate &markerA, const QGeoCoordinate &markerB, const QString &fromDepatrureTimeStr, int fromDepDateDay, int fromDepDateMonth, int fromDepDateYear, bool withToDepT, const QString &toDepatrureTimeStr, int toDepDateDay, int toDepDateMonth, int toDepDateYear, const QString &numberOfPeopleStr, int searchRadius, bool termsAcceped)
{
    if(fromDepatrureTimeStr.size() != 5) {
        emit errorSenderInQml(true, 11, 1);
        return;
    }
    if(withToDepT && toDepatrureTimeStr.size() != 5) {
        emit errorSenderInQml(true, 11, 2);
        return;
    }
    quint32 fromTime = Functions::localDateAndTimeStrToMinSinceEpoch(fromDepatrureTimeStr, fromDepDateDay, fromDepDateMonth, fromDepDateYear);
    quint32 toTime;
    if(withToDepT)
        toTime = Functions::localDateAndTimeStrToMinSinceEpoch(toDepatrureTimeStr, toDepDateDay, toDepDateMonth, toDepDateYear);
    else
        toTime = fromTime;
    quint32 currMinSinceEpoch = QDateTime::currentSecsSinceEpoch() / 60;
    if(fromTime < currMinSinceEpoch - 10) {
        emit errorSenderInQml(true, 11, 3);
        return;
    }
    if(fromTime > toTime) {
        emit errorSenderInQml(true, 11, 4);
        return;
    }
    if(toTime > currMinSinceEpoch + (60 * 24 * 4)) {
        emit errorSenderInQml(true, 11, 5);
        return;
    }
    quint16 numberOfPeople = numberOfPeopleStr.toInt();
    if(numberOfPeople < 1 || numberOfPeople > 200) {
        emit errorSenderInQml(true, 11, 6);
        return;
    }
    if(searchRadius < 10 || searchRadius > 1000) {
        emit errorSenderInQml(true, 11, 7);
        return;
    }
    if(!termsAcceped) {
        emit errorSenderInQml(true, 11, 8);
        return;
    }
    seFoADrData.markerA = coord(markerA.latitude() * 10000000, markerA.longitude() * 10000000);
    seFoADrData.markerB = coord(markerB.latitude() * 10000000, markerB.longitude() * 10000000);
    seFoADrData.fromDepartureTime = fromTime;
    seFoADrData.toDepartureTime = toTime;
    seFoADrData.numberOfPeople = numberOfPeople;
    seFoADrData.searchRadius = searchRadius;
    sheduledTask = SheduledTaskForServer::SearchForADriver;
    tryToSendData(10000);
}

void ServerCommunicator::deleteATripRequest(int tripId, int deleteCode)
{
    deATrData.tripId = quint32(tripId);
    deATrData.deleteCode = quint32(deleteCode);
    sheduledTask = SheduledTaskForServer::DeleteATrip;
    tryToSendData(10000);
}

void ServerCommunicator::checkTheAcceptanceVersion()
{
    chAcVeData.version = tppPointer->getAcceptanceVersion();
    sheduledTask = SheduledTaskForServer::CheckTheAcceptanceVersion;
    tryToSendData(10000);
}

void ServerCommunicator::tryToSendData(int howManyMsecToWait)
{
    if(myTcpSocket.state() == QAbstractSocket::ConnectedState)
        sendData();
    else {
        if(myTcpSocket.state() == QAbstractSocket::UnconnectedState)
            myTcpSocket.connectToHost(serverIpAdress, serverPort);
        else
            waitingForDisconnectedStateToConnect = true;
        serverResponseWaitingTimer.start(howManyMsecToWait);
    }
}

void ServerCommunicator::slotStateChanged(QAbstractSocket::SocketState socketState)
{
    if(socketState == QAbstractSocket::ConnectedState) {
        sizeOfDataFromServer = 0;
        sendData();
    }
    else if(socketState == QAbstractSocket::UnconnectedState) {
        if(sheduledTask != SheduledTaskForServer::None && waitingForDisconnectedStateToConnect) {
            waitingForDisconnectedStateToConnect = false;
            myTcpSocket.connectToHost(serverIpAdress, serverPort);
        }
        else {
            emit errorSenderInQml(true, 1, 1);
            sheduledTask = SheduledTaskForServer::None;
            serverResponseWaitingTimer.stop();
        }
    }
}

void ServerCommunicator::slotErrorOccurred(QAbstractSocket::SocketError error)
{
    if(error == QAbstractSocket::NetworkError) {
        if(sheduledTask != SheduledTaskForServer::None) {
            emit errorSenderInQml(true, 1, 1);
            waitingForDisconnectedStateToConnect = false;
            sheduledTask = SheduledTaskForServer::None;
            serverResponseWaitingTimer.stop();
        }
    }
}

void ServerCommunicator::slotServerResponseWaitingTimerAlarm()
{
    emit errorSenderInQml(true, 1, 2);
    sheduledTask = SheduledTaskForServer::None;
}

void ServerCommunicator::sendData()
{
    if(sheduledTask == SheduledTaskForServer::None)
        return;
    QByteArray dataBlock;
    QDataStream outOfDataBlock(&dataBlock, QIODevice::WriteOnly);
    outOfDataBlock.setVersion(QDataStream::Qt_5_15);
    outOfDataBlock << applicationVersion;
    switch(sheduledTask) {
    case SheduledTaskForServer::PlanATrip: {
        outOfDataBlock << quint8(10)
                       << plATrData.routeCoordNumber;
        for(QVector<coord>::const_iterator it = plATrData.route.constBegin(); it != plATrData.route.constEnd(); ++it)
            outOfDataBlock << it->latit << it->longit;
        outOfDataBlock << plATrData.fromDepartureTime << plATrData.toDepartureTime
                       << plATrData.emptySeats
                       << plATrData.currencyNumber << plATrData.estimatedPrice
                       << plATrData.comment
                       << plATrData.name
                       << plATrData.contacts;
        break;
    }
    case SheduledTaskForServer::SearchForADriver: {
        outOfDataBlock << quint8(11)
                       << seFoADrData.markerA.latit << seFoADrData.markerA.longit
                       << seFoADrData.markerB.latit << seFoADrData.markerB.longit
                       << seFoADrData.fromDepartureTime << seFoADrData.toDepartureTime
                       << seFoADrData.numberOfPeople
                       << seFoADrData.searchRadius;
        break;
    }
    case SheduledTaskForServer::DeleteATrip: {
        outOfDataBlock << quint8(12)
                       << deATrData.tripId
                       << deATrData.deleteCode;
        break;
    }
    case SheduledTaskForServer::CheckTheAcceptanceVersion: {
        outOfDataBlock << quint8(13)
                       << chAcVeData.version;
        break;
    }
    case SheduledTaskForServer::None: {
        break;
    }
    }
    if(publicKey.isEmpty()) {
        emit errorSenderInQml(true, 1, 3);
    }
    else {
        QByteArray finalDataBlock;
        QDataStream outOfFinalDataBlock(&finalDataBlock, QIODevice::WriteOnly);
        outOfFinalDataBlock.setVersion(QDataStream::Qt_5_15);
        outOfFinalDataBlock << quint32(0) << rsaEncr.encode(aesKey, publicKey) << aesEncr.encode(dataBlock, aesKey);
        if(static_cast<quint32>(dataBlock.size() - sizeof(quint32)) > 200000) {        // 200000 bytes is 0.2 megabytes
            emit errorSenderInQml(true, 1, 4);
        }
        else {
            outOfFinalDataBlock.device()->seek(0);
            outOfFinalDataBlock << static_cast<quint32>(dataBlock.size() - sizeof(quint32));
            myTcpSocket.write(finalDataBlock);
            serverResponseWaitingTimer.start(20000);
        }
    }
    sheduledTask = SheduledTaskForServer::None;
}

void ServerCommunicator::slotReadyRead()
{
    QDataStream inOfMyTcpSocket(&myTcpSocket);
    inOfMyTcpSocket.setVersion(QDataStream::Qt_5_15);
    if(sizeOfDataFromServer == 0)
    {
        if(myTcpSocket.bytesAvailable() < static_cast<qint64>(sizeof(quint32)))
            return;
        inOfMyTcpSocket >> sizeOfDataFromServer;
    }
    if(myTcpSocket.bytesAvailable() < static_cast<qint64>(sizeOfDataFromServer))
        return;
    sizeOfDataFromServer = 0;

    QByteArray encodedServerDataBlock;
    inOfMyTcpSocket >> encodedServerDataBlock;
    QByteArray serverDataBlock = aesEncr.decode(encodedServerDataBlock, aesKey);
    QDataStream inOfServerDataBlock(serverDataBlock);
    inOfServerDataBlock.setVersion(QDataStream::Qt_5_15);
    quint8 operationCode1;
    inOfServerDataBlock >> operationCode1;
    switch(operationCode1)
    {
    case 1: { processAnswerCode1(inOfServerDataBlock); break; }
    case 10: { processAnswerCode10(inOfServerDataBlock); break; }
    case 11: { processAnswerCode11(inOfServerDataBlock); break; }
    case 12: { processAnswerCode12(inOfServerDataBlock); break; }
    case 13: { processAnswerCode13(inOfServerDataBlock); break; }
    }
    serverResponseWaitingTimer.stop();
}

void ServerCommunicator::processAnswerCode1(QDataStream &inOfServerDataBlock)
{
    quint8 operationCode2;
    inOfServerDataBlock >> operationCode2;
    if(operationCode2 == 1) {
        installAndSaveNewServerAddress(inOfServerDataBlock);
        emit errorSenderInQml(false, 1, 1);
    }
    else if(operationCode2 == 2)
        emit errorSenderInQml(false, 1, 2);
    else if(operationCode2 == 3)
        emit errorSenderInQml(false, 1, 3);
    else if(operationCode2 == 4)
        emit errorSenderInQml(false, 1, 4);
    else if(operationCode2 == 5) {
        QString textToShowWindow_en, textForBackButton_en, textToShowWindow_ru, textForBackButton_ru;
        bool showOnlyIfLoading;
        inOfServerDataBlock >> textToShowWindow_en >> textForBackButton_en >> textToShowWindow_ru >> textForBackButton_ru >> showOnlyIfLoading;
        emit showWindowWithText(textToShowWindow_en, textForBackButton_en, textToShowWindow_ru, textForBackButton_ru, showOnlyIfLoading);
    }
    else if(operationCode2 == 6)
        emit errorSenderInQml(false, 1, 6);
}

void ServerCommunicator::processAnswerCode10(QDataStream &inOfServerDataBlock)
{
    quint8 operationCode2;
    inOfServerDataBlock >> operationCode2;
    if(operationCode2 == 1) {
        installAndSaveNewServerAddress(inOfServerDataBlock);
        sheduledTask = SheduledTaskForServer::PlanATrip;
        tryToSendData(10000);
    }
    else if(operationCode2 == 2)
        emit errorSenderInQml(false, 10, 2);
    else if(operationCode2 == 3)
        emit errorSenderInQml(false, 10, 3);
    else if(operationCode2 == 4) {
        if(tmnPointer->addTheTripToMyTrips(inOfServerDataBlock))
            emit errorSenderInQml(false, 10, 5);
        else
            emit errorSenderInQml(false, 10, 4);
    }
}

void ServerCommunicator::processAnswerCode11(QDataStream &inOfServerDataBlock)
{
    quint8 operationCode2;
    inOfServerDataBlock >> operationCode2;
    if(operationCode2 == 1) {
        installAndSaveNewServerAddress(inOfServerDataBlock);
        sheduledTask = SheduledTaskForServer::SearchForADriver;
        tryToSendData(10000);
    }
    else if(operationCode2 == 2)
        emit errorSenderInQml(false, 11, 2);
    else if(operationCode2 == 3) {
        tmnPointer->loadFoundRoutes(inOfServerDataBlock);
        emit errorSenderInQml(false, 11, 3);
    }
}

void ServerCommunicator::processAnswerCode12(QDataStream &inOfServerDataBlock)
{
    quint8 operationCode2;
    inOfServerDataBlock >> operationCode2;
    if(operationCode2 == 1) {
        installAndSaveNewServerAddress(inOfServerDataBlock);
        sheduledTask = SheduledTaskForServer::DeleteATrip;
        tryToSendData(10000);
    }
    else if(operationCode2 == 2)
        emit errorSenderInQml(false, 12, 2);
    else if(operationCode2 == 3)
        tmnPointer->removeTheTripFromMyTrips(inOfServerDataBlock);
}

void ServerCommunicator::processAnswerCode13(QDataStream &inOfServerDataBlock)
{
    quint8 operationCode2;
    inOfServerDataBlock >> operationCode2;
    if(operationCode2 == 1) {
        installAndSaveNewServerAddress(inOfServerDataBlock);
        sheduledTask = SheduledTaskForServer::CheckTheAcceptanceVersion;
        tryToSendData(10000);
    }
    else if(operationCode2 == 2) {
        tppPointer->installTouAndPpInQml();
    }
    else if(operationCode2 == 3) {
        tppPointer->updateTouAndPp(inOfServerDataBlock);
        tppPointer->installTouAndPpInQml();
    }
}

void ServerCommunicator::extractServerAddress()
{
    QFileInfo checkFile(pathToAppDataLocation + "/v100/settings/serverAddress.bin");
    bool fileExists = checkFile.exists() && checkFile.isFile();
    if(fileExists) {
        QFile fileObj(pathToAppDataLocation + "/v100/settings/serverAddress.bin");
        if(fileObj.open(QIODevice::ReadOnly)) {
            QDataStream inOfFileObj(&fileObj);
            inOfFileObj.setVersion(QDataStream::Qt_5_15);
            inOfFileObj >> serverIpAdress >> serverPort;
        }
        else
            fileExists = false;
        fileObj.close();
    }
    if(!fileExists) {
        serverIpAdress = QHostAddress("185.195.26.43");
        serverPort = 43583;
    }
}

void ServerCommunicator::installAndSaveNewServerAddress(QDataStream &inOfServerDataBlock)
{
    inOfServerDataBlock >> serverIpAdress >> serverPort;
    myTcpSocket.disconnectFromHost();
    QDir dirOfAppValues(pathToAppDataLocation + "/v100/settings");
    if(!dirOfAppValues.exists()) {
        dirOfAppValues.mkpath(".");
    }
    QFile fileObj(pathToAppDataLocation + "/v100/settings/serverAddress.bin");
    bool fileOpened = fileObj.open(QIODevice::WriteOnly);
    if(fileOpened) {
        QDataStream outOfFileObj(&fileObj);
        outOfFileObj.setVersion(QDataStream::Qt_5_15);
        outOfFileObj << serverIpAdress << serverPort;
    }
    fileObj.close();
}
