#ifndef NETWORKCONNECTOR_H
#define NETWORKCONNECTOR_H

#include <QObject>
#include "datahandler.h"
#include <QTcpServer>
#include "requestcounttracker.h"
#include <QHash>
#include <qrsaencryption.h>
#include <qaesencryption.h>
#include <QTimer>

class NetworkConnector : public QObject
{
    Q_OBJECT
public:
    explicit NetworkConnector(QObject *parent = nullptr);

private:
    DataHandler handler;
    QTcpServer* myTcpServer;
    RequestCountTracker requestCountTracker;
    QHash<QTcpSocket*, quint32> sizesOfDataFromClients;
    QByteArray privateKey;
    QRSAEncryption rsaEncr;
    QAESEncryption aesEncr;
    QTimer everyDayTimer;

private slots:
    void slotNewConnection();
    void slotReadyRead();
    void slotDisconnected();
    void slotEveryDayTimerAlarm();
};

#endif // NETWORKCONNECTOR_H
