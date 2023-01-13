#include "squaremanager.h"
#include <cmath>
#include <QDateTime>

SquareManager::SquareManager() {}

void SquareManager::add(quint32 tripId, const QVector<coord> &route, quint32 fromDepartureTime, quint32 toDepartureTime, quint16 emptySeats)
{
    QList<quint32> squares;
    createSquaresForRoute(route, squares);
    tripInfo.insert(tripId, info(fromDepartureTime, toDepartureTime, emptySeats));
    for(QList<quint32>::const_iterator it = squares.constBegin(); it != squares.constEnd(); ++it) {
        QHash<quint32, QSet<quint32>>::iterator it2 = squaresBigArr.find(*it);
        if(it2 == squaresBigArr.end())
            it2 = squaresBigArr.insert(*it, QSet<quint32>());
        it2.value().insert(tripId);
    }
}

void SquareManager::remove(quint32 tripId, const QVector<coord> &route)
{
    QList<quint32> squares;
    createSquaresForRoute(route, squares); //costly
    for(QList<quint32>::const_iterator it = squares.constBegin(); it != squares.constEnd(); ++it) {
        QHash<quint32, QSet<quint32>>::iterator it2 = squaresBigArr.find(*it);
        if(it2 == squaresBigArr.end())
            continue;
        it2.value().remove(tripId);
        if(it2.value().isEmpty())
            squaresBigArr.remove(*it);
    }
}

void SquareManager::find(coord markerA, coord markerB, quint16 searchRadius, quint16 numberOfPeople, quint32 fromDepartureTime, quint32 toDepartureTime, QVector<quint32> &idArray)
{
    QList<quint32> squaresA;
    QList<quint32> squaresB;
    addSquaresAroundThePoint(markerA, searchRadius, &squaresA);
    addSquaresAroundThePoint(markerB, searchRadius, &squaresB);
    QVector<quint32> arrA;
    QVector<quint32> arrB;
    bool coincide;
    QHash<quint32, QSet<quint32>>::const_iterator it2;
    for(QList<quint32>::const_iterator it = squaresA.constBegin(); it != squaresA.constEnd(); ++it) {
        it2 = squaresBigArr.constFind(*it);
        if(it2 == squaresBigArr.constEnd())
            continue;
        for(QSet<quint32>::const_iterator it3 = it2.value().constBegin(); it3 != it2.value().constEnd(); ++it3) {
            coincide = false;
            for(QVector<quint32>::const_iterator it4 = arrA.constBegin(); it4 != arrA.constEnd(); ++it4) {
                if(*it4 == *it3) {
                    coincide = true;
                    break;
                }
            }
            if(!coincide)
                arrA.append(*it3);
        }
    }

    for(QList<quint32>::const_iterator it = squaresB.constBegin(); it != squaresB.constEnd(); ++it) {
        it2 = squaresBigArr.constFind(*it);
        if(it2 == squaresBigArr.constEnd())
            continue;
        for(QSet<quint32>::const_iterator it3 = it2.value().constBegin(); it3 != it2.value().constEnd(); ++it3) {
            coincide = false;
            for(QVector<quint32>::const_iterator it4 = arrB.constBegin(); it4 != arrB.constEnd(); ++it4) {
                if(*it4 == *it3) {
                    coincide = true;
                    break;
                }
            }
            if(!coincide)
                arrB.append(*it3);
        }
    }

    QVector<quint32> arrAAndB;
    for(QVector<quint32>::const_iterator it = arrA.constBegin(); it != arrA.constEnd(); ++it) {
        for(QVector<quint32>::const_iterator it2 = arrB.constBegin(); it2 != arrB.constEnd(); ++it2) {
            if(*it2 == *it) {
                arrAAndB.append(*it);
                break;
            }
        }
    }

    for(QVector<quint32>::const_iterator it = arrAAndB.constBegin(); it != arrAAndB.constEnd(); ++it) {
        QHash<quint32, info>::const_iterator it2 = tripInfo.constFind(*it);
        if(it2 == tripInfo.constEnd())
            continue;
        info const &inf = it2.value();

        //checking for the number of seats
        if(numberOfPeople > inf.emptySeats)
            continue;

        //check by extreme time limits with an allowable error of 31 min. and 61 min.
        if(toDepartureTime + 31 < inf.fromDepartureTime || fromDepartureTime - 61 > inf.toDepartureTime)
            continue;

        idArray.append(*it);
    }
}

void SquareManager::getOldIds(QVector<quint32> &tripIds)
{
    quint32 expiredDate = QDateTime::currentSecsSinceEpoch() / 60 - 1440;
    for(QHash<quint32, info>::const_iterator it = tripInfo.constBegin(); it != tripInfo.constEnd(); ++it) {
        if(it.value().toDepartureTime < expiredDate)
            tripIds.append(it.key());
    }
}

void SquareManager::createSquaresForRoute(const QVector<coord> &route, QList<quint32> &squares)
{
    QVector<coord>::const_iterator it = route.constBegin();
    if(it == route.constEnd())
        return;
    squares.append(mergeSquare(it->latit / 100000 - (it->latit < 0 ? 1 : 0), it->longit / 100000 - (it->longit < 0 ? 1 : 0)));
    coord prev(*it);
    for(++it; it != route.constEnd(); prev = *(it++))
        addSquaresBetweenTwoPoints(prev, *it, squares);
}

//finds and adds all squares between two coordinates. recursive function
void SquareManager::addSquaresBetweenTwoPoints(coord coord1, coord coord2, QList<quint32> &squares)
{
    qint16 square1Lat = coord1.latit / 100000 - (coord1.latit < 0 ? 1 : 0);
    qint16 square1Lon = coord1.longit / 100000 - (coord1.longit < 0 ? 1 : 0);
    qint16 square2Lat = coord2.latit / 100000 - (coord2.latit < 0 ? 1 : 0);
    qint16 square2Lon = coord2.longit / 100000 - (coord2.longit < 0 ? 1 : 0);
    if(square1Lat == square2Lat && square1Lon == square2Lon)
        return;
    if((square1Lat == square2Lat && (square1Lon - square2Lon == 1 || square2Lon - square1Lon == 1)) || ((square1Lat - square2Lat == 1 || square2Lat - square1Lat == 1) && square1Lon == square2Lon) || distBetwTwoCoordInMeters(coord1, coord2) < 1.0) {
        quint32 mergedSquare2 = mergeSquare(square2Lat, square2Lon);
        bool addOrNot = true;
        for(QList<quint32>::iterator it = squares.begin(); it != squares.end(); ++it) { // check for duplicate values
            if(*it == mergedSquare2) {
                addOrNot = false;
                break;
            }
        }
        if(addOrNot)
            squares.append(mergedSquare2);
    }
    else {
        coord intermediatePoint(((qint64)coord1.latit + (qint64)coord2.latit) / 2, ((qint64)coord1.longit + (qint64)coord2.longit) / 2);
        addSquaresBetweenTwoPoints(coord1, intermediatePoint, squares);
        addSquaresBetweenTwoPoints(intermediatePoint, coord2, squares);
    }
}

void SquareManager::addSquaresAroundThePoint(coord markerCoord, quint16 searchRadius, QList<quint32> *squares)
{
    //First, let's find the boundaries:
    qint16 minSquareLon = markerCoord.longit / 100000 - (markerCoord.longit < 0 ? 1 : 0);
    qint16 maxSquareLat = markerCoord.latit / 100000 - (markerCoord.latit < 0 ? 1 : 0);
    qint16 maxSquareLon = minSquareLon;
    qint16 minSquareLat = maxSquareLat;
    //go to the left:
    while(distBetwTwoCoordInMeters(coord(markerCoord.latit, qint32(minSquareLon) * 100000), markerCoord) <= searchRadius)
        minSquareLon--;
    //go up:
    while(distBetwTwoCoordInMeters(coord(qint32(maxSquareLat + 1) * 100000, markerCoord.longit), markerCoord) <= searchRadius)
        maxSquareLat++;
    //go right:
    while(distBetwTwoCoordInMeters(markerCoord, coord(markerCoord.latit, qint32(maxSquareLon + 1) * 100000)) <= searchRadius)
        maxSquareLon++;
    //go down:
    while(distBetwTwoCoordInMeters(markerCoord, coord(qint32(minSquareLat) * 100000, markerCoord.longit)) <= searchRadius)
        minSquareLat--;

    //now we go along the matrix of squares and measure the distance from the square to the coordinate (along the nearest trajectory). If less than the search radius, add this square to the list of squares
    qint32 latit, longit;
    qint16 squareLon;
    for(qint16 squareLat = minSquareLat; squareLat <= maxSquareLat; ++squareLat) {
        for(squareLon = minSquareLon; squareLon <= maxSquareLon; ++squareLon) {
            //find the nearest square latitude to the coordinate
            if(qint32(squareLat + 1) * 100000 < markerCoord.latit)
                latit = qint32(squareLat + 1) * 100000;
            else if(qint32(squareLat) * 100000 > markerCoord.latit)
                latit = qint32(squareLat) * 100000;
            else
                latit = markerCoord.latit;

            //find the nearest square longitude to the coordinate
            if(qint32(squareLon + 1) * 100000 < markerCoord.longit)
                longit = qint32(squareLon + 1) * 100000;
            else if(qint32(squareLon) * 100000 > markerCoord.longit)
                longit = qint32(squareLon) * 100000;
            else
                longit = markerCoord.longit;

            if(distBetwTwoCoordInMeters(coord(latit, longit), markerCoord) <= searchRadius)
                squares->append(mergeSquare(squareLat, squareLon));
        }
    }
}

double SquareManager::distBetwTwoCoordInMeters(coord coord1, coord coord2) {
    return sqrt(pow(abs(double(coord1.latit) - double(coord2.latit)) * 0.011125, 2.0) + pow(abs(double(coord1.longit) - double(coord2.longit)) * 4.005 * cos((double(coord1.latit) + double(coord2.latit)) / 3600000000.0 * M_PI) / 360.0, 2.0));
}

bool SquareManager::routeMatchingCheck(const QVector<coord> &route, coord markerA, coord markerB, quint16 searchRadius)
{
    bool answerInclA = false;
    long savePointIndexNearA;
    double saveDistBetw_firstPoint_beginningAArea;
    double cornerBetw_firstPoint_secondPoint_pointA;
    double distFromAToRoute;
    double distToSecondPoint;
    double distToAreaEdge;
    double maxDist;
    double cornerBetw_secondPoint_firstPoint_pointA;
    bool offsetInFuture = false;
    double dist_firstPoint_pointA = distBetwTwoCoordInMeters(route.at(0), markerA);
    double dist_secondPoint_pointA;
    double dist_firstPoint_secondPoint;
    if(dist_firstPoint_pointA <= searchRadius) {
        savePointIndexNearA = 0;
        saveDistBetw_firstPoint_beginningAArea = 0;
        answerInclA = true;
    }
    else {
        dist_secondPoint_pointA = dist_firstPoint_pointA;
        for(long i = 0; i < route.length() - 1; i++) {
            dist_firstPoint_pointA = dist_secondPoint_pointA;
            dist_secondPoint_pointA = distBetwTwoCoordInMeters(route.at(i+1), markerA);
            dist_firstPoint_secondPoint = distBetwTwoCoordInMeters(route.at(i), route.at(i+1));
            if(dist_secondPoint_pointA <= searchRadius) {
                cornerBetw_firstPoint_secondPoint_pointA =
                        acos((pow(dist_firstPoint_secondPoint, 2) + pow(dist_secondPoint_pointA, 2) - pow(dist_firstPoint_pointA, 2)) / (2 * dist_firstPoint_secondPoint * dist_secondPoint_pointA));
                if(cornerBetw_firstPoint_secondPoint_pointA >= 1.5707963) {
                    cornerBetw_firstPoint_secondPoint_pointA = cornerBetw_firstPoint_secondPoint_pointA - (cornerBetw_firstPoint_secondPoint_pointA - 1.5707963) * 2;
                    offsetInFuture = true;
                }
                distFromAToRoute = dist_secondPoint_pointA * sin(cornerBetw_firstPoint_secondPoint_pointA);
                distToSecondPoint = sqrt(pow(dist_secondPoint_pointA, 2) - pow(distFromAToRoute, 2));
                distToAreaEdge = sqrt(pow(searchRadius, 2) - pow(distFromAToRoute, 2));
                savePointIndexNearA = i;
                if(offsetInFuture)
                    saveDistBetw_firstPoint_beginningAArea = dist_firstPoint_secondPoint + distToSecondPoint - distToAreaEdge;
                else
                    saveDistBetw_firstPoint_beginningAArea = dist_firstPoint_secondPoint - distToSecondPoint - distToAreaEdge;
                answerInclA = true;
                break;
            }
            maxDist = dist_firstPoint_pointA > dist_secondPoint_pointA ? dist_firstPoint_pointA : dist_secondPoint_pointA;
            if(maxDist - dist_firstPoint_secondPoint < searchRadius) {
                cornerBetw_firstPoint_secondPoint_pointA =
                        acos((pow(dist_firstPoint_secondPoint, 2) + pow(dist_secondPoint_pointA, 2) - pow(dist_firstPoint_pointA, 2)) / (2 * dist_firstPoint_secondPoint * dist_secondPoint_pointA));
                if(cornerBetw_firstPoint_secondPoint_pointA >= 1.5707963)
                    continue;
                cornerBetw_secondPoint_firstPoint_pointA =
                        acos((pow(dist_firstPoint_secondPoint, 2) + pow(dist_firstPoint_pointA, 2) - pow(dist_secondPoint_pointA, 2)) / (2 * dist_firstPoint_secondPoint * dist_firstPoint_pointA));
                if(cornerBetw_secondPoint_firstPoint_pointA >= 1.5707963)
                    continue;//нет
                distFromAToRoute = dist_secondPoint_pointA * sin(cornerBetw_firstPoint_secondPoint_pointA);
                if(distFromAToRoute > searchRadius)
                    continue;
                distToSecondPoint = sqrt(pow(dist_secondPoint_pointA, 2) - pow(distFromAToRoute, 2));
                distToAreaEdge = sqrt(pow(searchRadius, 2) - pow(distFromAToRoute, 2));
                savePointIndexNearA = i;
                saveDistBetw_firstPoint_beginningAArea = dist_firstPoint_secondPoint - distToSecondPoint - distToAreaEdge;
                answerInclA = true;
                break;
            }
        }
    }
    if(answerInclA == false)
        return false;
    else
    {
        //we count the same from the end for point B (variable names may not match)
        bool answerInclB = false;
        long savePointIndexNearB;
        double saveDistBetw_firstPoint_beginningBArea;
        offsetInFuture = false;
        dist_firstPoint_pointA = distBetwTwoCoordInMeters(route.at(route.length() - 1), markerB);
        if(dist_firstPoint_pointA <= searchRadius) {
            savePointIndexNearB = route.length() - 1;
            saveDistBetw_firstPoint_beginningBArea = 0;
            answerInclB = true;
        }
        else {
            dist_secondPoint_pointA = dist_firstPoint_pointA;
            for(long i = route.length() - 1; i > 0 ; i--) {
                dist_firstPoint_pointA = dist_secondPoint_pointA;
                dist_secondPoint_pointA = distBetwTwoCoordInMeters(route.at(i-1), markerB);
                dist_firstPoint_secondPoint = distBetwTwoCoordInMeters(route.at(i), route.at(i-1));
                if(dist_secondPoint_pointA <= searchRadius) {
                    cornerBetw_firstPoint_secondPoint_pointA =
                            acos((pow(dist_firstPoint_secondPoint, 2) + pow(dist_secondPoint_pointA, 2) - pow(dist_firstPoint_pointA, 2)) / (2 * dist_firstPoint_secondPoint * dist_secondPoint_pointA));
                    if(cornerBetw_firstPoint_secondPoint_pointA >= 1.5707963) {
                        cornerBetw_firstPoint_secondPoint_pointA = cornerBetw_firstPoint_secondPoint_pointA - (cornerBetw_firstPoint_secondPoint_pointA - 1.5707963) * 2;
                        offsetInFuture = true;
                    }
                    distFromAToRoute = dist_secondPoint_pointA * sin(cornerBetw_firstPoint_secondPoint_pointA);
                    distToSecondPoint = sqrt(pow(dist_secondPoint_pointA, 2) - pow(distFromAToRoute, 2));
                    distToAreaEdge = sqrt(pow(searchRadius, 2) - pow(distFromAToRoute, 2));
                    savePointIndexNearB = i - 1;
                    if(offsetInFuture)
                        saveDistBetw_firstPoint_beginningBArea = distToAreaEdge - distToSecondPoint;
                    else
                        saveDistBetw_firstPoint_beginningBArea = distToAreaEdge + distToSecondPoint;
                    answerInclB = true;
                    break;
                }
                maxDist = dist_firstPoint_pointA > dist_secondPoint_pointA ? dist_firstPoint_pointA : dist_secondPoint_pointA;
                if(maxDist - dist_firstPoint_secondPoint < searchRadius) {
                    cornerBetw_firstPoint_secondPoint_pointA =
                            acos((pow(dist_firstPoint_secondPoint, 2) + pow(dist_secondPoint_pointA, 2) - pow(dist_firstPoint_pointA, 2)) / (2 * dist_firstPoint_secondPoint * dist_secondPoint_pointA));
                    if(cornerBetw_firstPoint_secondPoint_pointA >= 1.5707963)
                        continue;
                    cornerBetw_secondPoint_firstPoint_pointA =
                            acos((pow(dist_firstPoint_secondPoint, 2) + pow(dist_firstPoint_pointA, 2) - pow(dist_secondPoint_pointA, 2)) / (2 * dist_firstPoint_secondPoint * dist_firstPoint_pointA));
                    if(cornerBetw_secondPoint_firstPoint_pointA >= 1.5707963)
                        continue;
                    distFromAToRoute = dist_secondPoint_pointA * sin(cornerBetw_firstPoint_secondPoint_pointA);
                    if(distFromAToRoute > searchRadius)
                        continue;
                    distToSecondPoint = sqrt(pow(dist_secondPoint_pointA, 2) - pow(distFromAToRoute, 2));
                    distToAreaEdge = sqrt(pow(searchRadius, 2) - pow(distFromAToRoute, 2));
                    savePointIndexNearB = i - 1;
                    saveDistBetw_firstPoint_beginningBArea = distToAreaEdge + distToSecondPoint;
                    answerInclB = true;
                    break;
                }
            }
        }
        if(answerInclB && savePointIndexNearB > savePointIndexNearA)
            return true;
        else if(savePointIndexNearB == savePointIndexNearA && saveDistBetw_firstPoint_beginningBArea > saveDistBetw_firstPoint_beginningAArea)
            return true;
        else
            return false;
    }
}

quint32 SquareManager::mergeSquare(qint16 lat, qint16 lon)
{
    quint32 merged;
    qint16 *p = reinterpret_cast<qint16*>(&merged);
    *p = lat;
    *(++p) = lon;
    return merged;
}

//void SquareManager::separateSquare(quint32 merged, qint16 &lat, qint16 &lon)
//{
//    qint16 *p = reinterpret_cast<qint16*>(&merged);
//    lat = *p;
//    lon = *(++p);
//}
