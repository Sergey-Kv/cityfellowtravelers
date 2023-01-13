#include "touandppmanager.h"
#include <QStandardPaths>
#include <QFileInfo>
#include <QDir>

TouAndPpManager::TouAndPpManager(QObject *parent)
    : QObject{parent},
      pathToAppDataLocation(QStandardPaths::writableLocation(QStandardPaths::AppDataLocation)),
      areTouAndPpLoadedFromFile(false)
{}

void TouAndPpManager::loadTouAndPpFromSomeFile()
{
    QFileInfo checkFile(pathToAppDataLocation + "/v100/legalGrounds/termsOfUseAndPrivacyPolicy.bin");
    bool fileExists = checkFile.exists() && checkFile.isFile();
    if(fileExists) {
        QFile fileObj(pathToAppDataLocation + "/v100/legalGrounds/termsOfUseAndPrivacyPolicy.bin");
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
        else
            fileExists = false;
        fileObj.close();
    }
    if(!fileExists) {
        QFileInfo checkFile2(":/bin/termsOfUseAndPrivacyPolicy.bin");
        bool fileExists2 = checkFile2.exists() && checkFile2.isFile();
        if(fileExists2) {
            QFile fileObj2(":/bin/termsOfUseAndPrivacyPolicy.bin");
            if(fileObj2.open(QIODevice::ReadOnly)) {
                QDataStream inOfFileObj2(&fileObj2);
                inOfFileObj2.setVersion(QDataStream::Qt_5_15);
                inOfFileObj2 >> touAndPp.version
                        >> touAndPp.touHeader_en
                        >> touAndPp.touText_en
                        >> touAndPp.ppHeader_en
                        >> touAndPp.ppText_en
                        >> touAndPp.touHeader_ru
                        >> touAndPp.touText_ru
                        >> touAndPp.ppHeader_ru
                        >> touAndPp.ppText_ru;
            }
            else
                touAndPp.version = 0;
            fileObj2.close();
        }
    }
    areTouAndPpLoadedFromFile = true;
}

quint16 TouAndPpManager::getAcceptanceVersion()
{
    if(!areTouAndPpLoadedFromFile)
        loadTouAndPpFromSomeFile();
    return touAndPp.version;
}

void TouAndPpManager::updateTouAndPp(QDataStream &inOfServerDataBlock)
{
    inOfServerDataBlock >> touAndPp.version
            >> touAndPp.touHeader_en
            >> touAndPp.touText_en
            >> touAndPp.ppHeader_en
            >> touAndPp.ppText_en
            >> touAndPp.touHeader_ru
            >> touAndPp.touText_ru
            >> touAndPp.ppHeader_ru
            >> touAndPp.ppText_ru;
    QDir dirOfTouAndPp(pathToAppDataLocation + "/v100/legalGrounds");
    if(!dirOfTouAndPp.exists()) {
        dirOfTouAndPp.mkpath(".");
    }
    QFile fileObj(pathToAppDataLocation + "/v100/legalGrounds/termsOfUseAndPrivacyPolicy.bin");
    bool fileOpened = fileObj.open(QIODevice::WriteOnly);
    if(fileOpened) {
        QDataStream outOfFileObj(&fileObj);
        outOfFileObj.setVersion(QDataStream::Qt_5_15);
        outOfFileObj << touAndPp.version << touAndPp.touHeader_en << touAndPp.touText_en << touAndPp.ppHeader_en << touAndPp.ppText_en << touAndPp.touHeader_ru << touAndPp.touText_ru << touAndPp.ppHeader_ru << touAndPp.ppText_ru;
    }
    fileObj.close();
}

void TouAndPpManager::installTouAndPpInQml()
{
    if(!areTouAndPpLoadedFromFile)
        loadTouAndPpFromSomeFile();
    emit installTouAndPp(touAndPp.touHeader_en, touAndPp.touText_en, touAndPp.ppHeader_en, touAndPp.ppText_en, touAndPp.touHeader_ru, touAndPp.touText_ru, touAndPp.ppHeader_ru, touAndPp.ppText_ru);
}
