#ifndef SERVERCOMMUNICATOR_H
#define SERVERCOMMUNICATOR_H

#include <QObject>
#include "tripsmanager.h"
#include "touandppmanager.h"
#include <QList>
#include <QGeoCoordinate>
#include <QByteArray>
#include <qrsaencryption.h>
#include <qaesencryption.h>
#include <QHostAddress>
#include <QtGlobal>
#include <QTcpSocket>
#include <QTimer>
#include <QString>
#include "commonDataStructures.h"

class ServerCommunicator : public QObject
{
    Q_OBJECT
public:
    explicit ServerCommunicator(TripsManager *tmnPointer, TouAndPpManager *tppPointer, QObject *parent = nullptr);
    Q_INVOKABLE void planATripRequest(const QList<QGeoCoordinate> &route,
                                      const QString &fromDepatrureTimeStr,
                                      bool isFromTimeAmOrPm,
                                      int fromDepDateDay,
                                      int fromDepDateMonth,
                                      int fromDepDateYear,
                                      bool withToDepT,
                                      const QString &toDepatrureTimeStr,
                                      bool isToTimeAmOrPm,
                                      int toDepDateDay,
                                      int toDepDateMonth,
                                      int toDepDateYear,
                                      const QString &emptySeatsStr,
                                      int currencyNumber,
                                      const QString &estimatedPrice,
                                      const QString &comment,
                                      const QString &name,
                                      const QString &contacts,
                                      bool termsAcceped);
    Q_INVOKABLE void searchForADriverRequest(const QGeoCoordinate &markerA,
                                             const QGeoCoordinate &markerB,
                                             const QString &fromDepatrureTimeStr,
                                             bool isFromTimeAmOrPm,
                                             int fromDepDateDay,
                                             int fromDepDateMonth,
                                             int fromDepDateYear,
                                             bool withToDepT,
                                             const QString &toDepatrureTimeStr,
                                             bool isToTimeAmOrPm,
                                             int toDepDateDay,
                                             int toDepDateMonth,
                                             int toDepDateYear,
                                             const QString &numberOfPeopleStr,
                                             int searchRadius,
                                             bool termsAcceped);
    Q_INVOKABLE void deleteATripRequest(int tripId,
                                        int deleteCode);
    Q_INVOKABLE void checkTheAcceptanceVersion();
    void tryToSendData(int howManyMsecToWait);
    void sendData();
    void processAnswerCode1(QDataStream &inOfServerDataBlock);
    void processAnswerCode10(QDataStream &inOfServerDataBlock);
    void processAnswerCode11(QDataStream &inOfServerDataBlock);
    void processAnswerCode12(QDataStream &inOfServerDataBlock);
    void processAnswerCode13(QDataStream &inOfServerDataBlock);
    void extractServerAddress();
    void installAndSaveNewServerAddress(QDataStream &inOfServerDataBlock);

private:
    QString pathToAppDataLocation;
    TripsManager *tmnPointer;
    TouAndPpManager *tppPointer;
    QHostAddress serverIpAdress;
    quint16 serverPort;
    QByteArray publicKey;
    QRSAEncryption rsaEncr;
    QByteArray aesKey;
    QAESEncryption aesEncr;
    quint16 applicationVersion;
    QTcpSocket myTcpSocket;
    quint32 sizeOfDataFromServer;
    bool waitingForDisconnectedStateToConnect;
    enum class SheduledTaskForServer {PlanATrip, SearchForADriver, DeleteATrip, CheckTheAcceptanceVersion, None};
    SheduledTaskForServer sheduledTask;
    QTimer serverResponseWaitingTimer;
    dataForPlanATripRequest plATrData;
    dataForSearchForADriverRequest seFoADrData;
    dataForDeleteATripRequest deATrData;
    dataForCheckTheAcceptanceVersion chAcVeData;

signals:
    void errorSenderInQml(bool fromHereOrServer_fq, int errorCode1_fq, int errorCode2_fq);
    void showWindowWithText(const QString &textToShowWindow_en_fq, const QString &textForBackButton_en_fq, const QString &textToShowWindow_ru_fq, const QString &textForBackButton_ru_fq, bool showOnlyIfLoading_fq);

private slots:
    void slotStateChanged(QAbstractSocket::SocketState socketState);
    void slotErrorOccurred(QAbstractSocket::SocketError error);
    void slotServerResponseWaitingTimerAlarm();
    void slotReadyRead();
};

#endif // SERVERCOMMUNICATOR_H
