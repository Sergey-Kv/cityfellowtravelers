#ifndef VALUESAVER_H
#define VALUESAVER_H

#include <QObject>
#include <QGeoCoordinate>
#include <QString>

class ValueSaver : public QObject
{
    Q_OBJECT
public:
    explicit ValueSaver(QObject *parent = nullptr);
    Q_INVOKABLE void extractStoredValues();
    Q_INVOKABLE void saveValues(const QGeoCoordinate &savedLocationForMarkerA,
                                double savedZoomLevelForFields1And2,
                                int page2_field3_comboBox_activeMenuPoint,
                                bool page3_departureTimeAtOrFromTo,
                                const QString &page3_emptySeats,
                                int page3_currencyNumber,
                                const QString &page3_name,
                                const QString &page3_contacts,
                                bool page4_needToDepartAtOrFromTo,
                                const QString &page4_howManyPeople,
                                int page4_searchRadius,
                                double page5_mapHKoef);

private:
    QString pathToAppDataLocation;

signals:
    void installSavedValues(const QGeoCoordinate &savedLocationForMarkerA_fq,
                            double savedZoomLevelForFields1And2_fq,
                            int page2_field3_comboBox_activeMenuPoint_fq,
                            bool page3_departureTimeAtOrFromTo_fq,
                            const QString &page3_emptySeats_fq,
                            int page3_currencyNumber_fq,
                            const QString &page3_name_fq,
                            const QString &page3_contacts_fq,
                            bool page4_needToDepartAtOrFromTo_fq,
                            const QString &page4_howManyPeople_fq,
                            int page4_searchRadius_fq,
                            double page5_mapHKoef_fq);
};

#endif // VALUESAVER_H
