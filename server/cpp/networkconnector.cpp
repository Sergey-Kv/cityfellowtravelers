#include "networkconnector.h"
#include <QFileInfo>
#include <QFile>
#include <QDateTime>
#include <QTcpSocket>
#include <QDataStream>
#include "timecout.h"

NetworkConnector::NetworkConnector(QObject *parent)
    : QObject{parent},
    rsaEncr(QRSAEncryption::Rsa::RSA_1024),
    aesEncr(QAESEncryption::AES_128, QAESEncryption::ECB)
{
    //initialize private rsa key
    QFileInfo checkFile("bin/privateKey.bin");
    if(checkFile.exists() && checkFile.isFile()) {
        QFile fileObj("bin/privateKey.bin");
        if(fileObj.open(QIODevice::ReadOnly)) {
            QDataStream inOfFileObj(&fileObj);
            inOfFileObj.setVersion(QDataStream::Qt_5_15);
            inOfFileObj >> privateKey;
        }
        else {
            ticerr() << "Error: Could not open privateKey.bin" << std::endl;
            fileObj.close();
            return;
        }
        fileObj.close();
    }
    else {
        ticerr() << "Error: File privateKey.bin not found" << std::endl;
        return;
    }

    connect(&everyDayTimer, SIGNAL(timeout()), this, SLOT(slotEveryDayTimerAlarm()));
    everyDayTimer.setSingleShot(true);
    qint64 mSecsSinceEpoch = QDateTime::currentMSecsSinceEpoch();
    everyDayTimer.setInterval(86400000 - (mSecsSinceEpoch % 86400000));
    everyDayTimer.start();

    quint16 listeningPort = 43583;
    myTcpServer = new QTcpServer(this);
    if(!myTcpServer->listen(QHostAddress::Any, listeningPort)) {
        ticerr() << "Unable to start the server. Error: " << (myTcpServer->errorString()).toStdString() << std::endl;
        myTcpServer->close();
        return;
    }
    connect(myTcpServer, SIGNAL(newConnection()), this, SLOT(slotNewConnection()));
    ticout() << "The server started" << std::endl;
}

void NetworkConnector::slotNewConnection() {
    QTcpSocket* clientSocket = myTcpServer->nextPendingConnection();
    connect(clientSocket, SIGNAL(readyRead()), this, SLOT(slotReadyRead()));
    connect(clientSocket, SIGNAL(disconnected()), this, SLOT(slotDisconnected()));
    if(requestCountTracker.execute(RequestCountTracker::Task::IncrementAndCheck,
                             RequestCountTracker::Object::ConnectionsMax,
                             clientSocket->peerAddress())) {
        handler.incrementNumberOfConnectionsExceedingTheDailyLimit(true);
        clientSocket->disconnectFromHost();
    }
}

void NetworkConnector::slotReadyRead() {
    QTcpSocket* clientSocket = static_cast<QTcpSocket*>(sender());
    QDataStream inOfClientSocket(clientSocket);
    inOfClientSocket.setVersion(QDataStream::Qt_5_15);
    quint32 dataSize = sizesOfDataFromClients.value(clientSocket, 0);
    if(dataSize == 0)
    {
        if(clientSocket->bytesAvailable() < static_cast<qint64>(sizeof(quint32)))
            return;
        inOfClientSocket >> dataSize;
        if(dataSize == 0 || dataSize > 200000) {        // 200000 bytes is 0.2 megabytes
            clientSocket->disconnectFromHost();
            return;
        }
        sizesOfDataFromClients.insert(clientSocket, dataSize);
    }
    if(clientSocket->bytesAvailable() < static_cast<qint64>(dataSize))
        return;

    QByteArray dataBlock;
    QDataStream outOfDataBlock(&dataBlock, QIODevice::WriteOnly);
    outOfDataBlock.setVersion(QDataStream::Qt_5_15);
    QByteArray finalDataBlock;
    QDataStream outOfFinalDataBlock(&finalDataBlock, QIODevice::WriteOnly);
    outOfFinalDataBlock.setVersion(QDataStream::Qt_5_15);
    QByteArray encodedAesKey;
    inOfClientSocket >> encodedAesKey;
    QByteArray aesKey = rsaEncr.decode(encodedAesKey, privateKey);
    if(requestCountTracker.execute(RequestCountTracker::Task::Check,
                             RequestCountTracker::Object::Connections,
                             clientSocket->peerAddress())) {
        handler.incrementNumberOfConnectionsExceedingTheDailyLimit(false);
        outOfDataBlock << quint8(1) << quint8(2);
    }
    else {
        QByteArray encodedClientDataBlock;
        inOfClientSocket >> encodedClientDataBlock;
        QByteArray clientDataBlock = aesEncr.decode(encodedClientDataBlock, aesKey);
        QDataStream inOfClientDataBlock(clientDataBlock);
        inOfClientDataBlock.setVersion(QDataStream::Qt_5_15);
        handler.handleTheRequest(inOfClientDataBlock, clientSocket->peerAddress(), requestCountTracker, outOfDataBlock);
    }
    outOfFinalDataBlock << quint32(0) << aesEncr.encode(dataBlock, aesKey);
    outOfFinalDataBlock.device()->seek(0);
    outOfFinalDataBlock << static_cast<quint32>(finalDataBlock.size() - sizeof(quint32));
    clientSocket->write(finalDataBlock);
    clientSocket->disconnectFromHost();
}

void NetworkConnector::slotDisconnected() {
    QTcpSocket* clientSocket = static_cast<QTcpSocket*>(sender());
    sizesOfDataFromClients.remove(clientSocket);
    clientSocket->deleteLater();
}

void NetworkConnector::slotEveryDayTimerAlarm() {
    if(everyDayTimer.isSingleShot()) {
        everyDayTimer.setInterval(86400000);
        everyDayTimer.setSingleShot(false);
        everyDayTimer.start();
    }
    quint32 currentMinSinceEpoch = QDateTime::currentSecsSinceEpoch() / 60;
    handler.minimumAllowedMinutes = currentMinSinceEpoch - 1440;
    handler.maximumAllowedMinutes = currentMinSinceEpoch + 1440 * 7;
    handler.editStatistics(requestCountTracker.getTheNumberOfUniqueIpAddressesConnectedInTheLastDay());
    requestCountTracker.reset();
    handler.clearTheOldData();
}
