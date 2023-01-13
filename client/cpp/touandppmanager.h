#ifndef TOUANDPPMANAGER_H
#define TOUANDPPMANAGER_H

#include <QObject>
#include <QDataStream>
#include "commonDataStructures.h"

class TouAndPpManager : public QObject
{
    Q_OBJECT
public:
    explicit TouAndPpManager(QObject *parent = nullptr);
    void loadTouAndPpFromSomeFile();
    quint16 getAcceptanceVersion();
    void updateTouAndPp(QDataStream &inOfServerDataBlock);
    void installTouAndPpInQml();

private:
    QString pathToAppDataLocation;
    bool areTouAndPpLoadedFromFile;
    termsOfUseAndPrivPol touAndPp;

signals:
    void installTouAndPp(const QString &touHeader_en_fq, const QString &touText_en_fq, const QString &ppHeader_en_fq, const QString &ppText_en_fq, const QString &touHeader_ru_fq, const QString &touText_ru_fq, const QString &ppHeader_ru_fq, const QString &ppText_ru_fq);
};

#endif // TOUANDPPMANAGER_H
