#include "routedrawing.h"
#include "functions.h"
#include <cmath>

RouteDrawing::RouteDrawing(QObject *parent) : QObject{parent} {}

void RouteDrawing::newCoordArrived(const QGeoCoordinate &newCoord, double zoomLevel, bool isThisCoordOfMarkerB) {
    int howManyCoordinatesToDelete;
    QList<QGeoCoordinate> listOfCoordinatesToAdd;
    isLastCoordOnDplIsCoordOfMarkerB = isThisCoordOfMarkerB;

    while(listOfIndexesOnDplMeaningAbbrevPolyLine.constLast() > indexOfLastVisibleDplCoordOnDpl) {
        listOfIndexesOnDplMeaningAbbrevPolyLine.removeLast();
    }
    while(detailedPolyLine.size() - 1 > indexOfLastVisibleDplCoordOnDpl) {
        detailedPolyLine.removeLast();
    }
    if(isAdditCoordOnDplExist) {
        detailedPolyLine.append(additCoordOnDpl);
        isAdditCoordOnDplExist = false;
        ++indexOfLastVisibleDplCoordOnDpl;
    }

    detailedPolyLine.append(newCoord);
    ++indexOfLastVisibleDplCoordOnDpl;

    QPair<int, QList<QGeoCoordinate>::const_iterator> indexAndIteratorPairOfLastAbbrevCoord(listOfIndexesOnDplMeaningAbbrevPolyLine.constLast(), detailedPolyLine.constEnd() - (detailedPolyLine.size() - listOfIndexesOnDplMeaningAbbrevPolyLine.constLast()));
    if((detailedPolyLine.size() - 1) - listOfIndexesOnDplMeaningAbbrevPolyLine.constLast() > 1
            && Functions::isPolylineNeededToAbbrev(detailedPolyLine, indexAndIteratorPairOfLastAbbrevCoord, zoomLevel < 18.0 ? 183501.0 / pow(2.0, zoomLevel) : 0.7)) {
        if(isThisCoordOfMarkerB) {
            howManyCoordinatesToDelete = indexOfLastVisibleDplCoordOnDpl - 1 - listOfIndexesOnDplMeaningAbbrevPolyLine.constLast();
            listOfIndexesOnDplMeaningAbbrevPolyLine.append(indexAndIteratorPairOfLastAbbrevCoord.first);
            listOfIndexesOnDplMeaningAbbrevPolyLine.append(detailedPolyLine.size() - 1);
            listOfCoordinatesToAdd.append(*indexAndIteratorPairOfLastAbbrevCoord.second);
            listOfCoordinatesToAdd.append(detailedPolyLine.constLast());
        }
        else {
            howManyCoordinatesToDelete = indexOfLastVisibleDplCoordOnDpl - 1 - listOfIndexesOnDplMeaningAbbrevPolyLine.constLast();
            listOfIndexesOnDplMeaningAbbrevPolyLine.append(indexAndIteratorPairOfLastAbbrevCoord.first);
            for(; indexAndIteratorPairOfLastAbbrevCoord.second != detailedPolyLine.constEnd(); ++indexAndIteratorPairOfLastAbbrevCoord.first, ++indexAndIteratorPairOfLastAbbrevCoord.second) {
                listOfCoordinatesToAdd.append(*indexAndIteratorPairOfLastAbbrevCoord.second);
            }
        }
    }
    else {
        if(isThisCoordOfMarkerB) {
            howManyCoordinatesToDelete = indexOfLastVisibleDplCoordOnDpl - 1 - listOfIndexesOnDplMeaningAbbrevPolyLine.constLast();
            listOfIndexesOnDplMeaningAbbrevPolyLine.append(detailedPolyLine.size() - 1);
            listOfCoordinatesToAdd.append(detailedPolyLine.constLast());
        }
        else {
            howManyCoordinatesToDelete = 0;
            listOfCoordinatesToAdd.append(newCoord);
        }
    }
    emit changeRouteDrawingDataInQml(howManyCoordinatesToDelete, listOfCoordinatesToAdd, true, false, isThisCoordOfMarkerB);
}

void RouteDrawing::undoButtonPressed(double zoomLevel, int averageMapAreaLength, double latitudeWhereYouAre) {
    int howManyCoordinatesToDelete = 0;
    QList<QGeoCoordinate> listOfCoordinatesToAdd;
    bool stateForUndoButton;
    bool stateForRedoButton;
    bool isRouteFullyDrawn;

    double avrgMapAreaLengthInMeters = Functions::distanceFromPointsAndZoomlevel(averageMapAreaLength, zoomLevel, latitudeWhereYouAre);
    double distanceNeededToGoBack = 0.15 * avrgMapAreaLengthInMeters;

    QList<QGeoCoordinate>::const_iterator it_dpl;
    if(detailedPolyLine.size() / 2 > indexOfLastVisibleDplCoordOnDpl)
        it_dpl = detailedPolyLine.constBegin() + indexOfLastVisibleDplCoordOnDpl;
    else
        it_dpl = detailedPolyLine.constEnd() - (detailedPolyLine.size() - indexOfLastVisibleDplCoordOnDpl);

    if(isAdditCoordOnDplExist) {
        if(movingNeededDitance(additCoordOnDpl, *it_dpl, distanceNeededToGoBack)) {
            if(isAdditCoordOnDplExist) {
                howManyCoordinatesToDelete += 1;                                              //1
                listOfCoordinatesToAdd.append(additCoordOnDpl);                               //2
                stateForUndoButton = true;                                                    //3
                stateForRedoButton = true;                                                    //4
                isRouteFullyDrawn = false;                                                    //5
                emit changeRouteDrawingDataInQml(howManyCoordinatesToDelete, listOfCoordinatesToAdd, stateForUndoButton, stateForRedoButton, isRouteFullyDrawn);
                return;
            }
            else {
                howManyCoordinatesToDelete += 1;                                              //1
                //listOfCoordinatesToAdd;                                                     //2
                stateForUndoButton = indexOfLastVisibleDplCoordOnDpl > 0;                     //3
                stateForRedoButton = true;                                                    //4
                isRouteFullyDrawn = false;                                                    //5
                emit changeRouteDrawingDataInQml(howManyCoordinatesToDelete, listOfCoordinatesToAdd, stateForUndoButton, stateForRedoButton, isRouteFullyDrawn);
                return;
            }
        }
        else {
            howManyCoordinatesToDelete +=1;
        }
    }

    QList<int>::const_iterator it_indOfApl;
    if(detailedPolyLine.size() / 2 > indexOfLastVisibleDplCoordOnDpl) {
        for(it_indOfApl = listOfIndexesOnDplMeaningAbbrevPolyLine.constBegin(); it_indOfApl != listOfIndexesOnDplMeaningAbbrevPolyLine.constEnd() && *it_indOfApl <= indexOfLastVisibleDplCoordOnDpl; ++it_indOfApl) {}
        --it_indOfApl;
    }
    else {
        for(it_indOfApl = --listOfIndexesOnDplMeaningAbbrevPolyLine.constEnd(); *it_indOfApl > indexOfLastVisibleDplCoordOnDpl; --it_indOfApl) {}
    }

    bool isAplBeingProcessed = false;
    QGeoCoordinate prevCoord;
    while(true) {
        if(it_dpl == detailedPolyLine.constBegin()) {
            break;
        }
        if(indexOfLastVisibleDplCoordOnDpl == *it_indOfApl) {
            isAplBeingProcessed = true;
            --it_indOfApl;
            howManyCoordinatesToDelete += 1;
        }
        prevCoord = *it_dpl;
        --indexOfLastVisibleDplCoordOnDpl;
        --it_dpl;
        if(movingNeededDitance(prevCoord, *it_dpl, distanceNeededToGoBack)) {
            if(isAplBeingProcessed) {
                for(int i = indexOfLastVisibleDplCoordOnDpl; i != *it_indOfApl; --i, --it_dpl) {
                    listOfCoordinatesToAdd.prepend(*it_dpl);
                }
            }
            else {
                howManyCoordinatesToDelete += 1;
            }
            if(isAdditCoordOnDplExist) {
                //howManyCoordinatesToDelete;                                                 //1
                listOfCoordinatesToAdd.append(additCoordOnDpl);                               //2
                stateForUndoButton = true;                                                    //3
                stateForRedoButton = true;                                                    //4
                isRouteFullyDrawn = false;                                                    //5
                emit changeRouteDrawingDataInQml(howManyCoordinatesToDelete, listOfCoordinatesToAdd, stateForUndoButton, stateForRedoButton, isRouteFullyDrawn);
                return;
            }
            else {
                //howManyCoordinatesToDelete;                                                 //1
                //listOfCoordinatesToAdd;                                                     //2
                stateForUndoButton = indexOfLastVisibleDplCoordOnDpl > 0;                     //3
                stateForRedoButton = true;                                                    //4
                isRouteFullyDrawn = false;                                                    //5
                emit changeRouteDrawingDataInQml(howManyCoordinatesToDelete, listOfCoordinatesToAdd, stateForUndoButton, stateForRedoButton, isRouteFullyDrawn);
                return;
            }
        }
        else {
            if(!isAplBeingProcessed) {
                howManyCoordinatesToDelete +=1;
            }
        }
    }
    //howManyCoordinatesToDelete;                                                 //1
    //listOfCoordinatesToAdd;                                                     //2
    stateForUndoButton = false;                                                   //3
    stateForRedoButton = true;                                                    //4
    isRouteFullyDrawn = false;                                                    //5
    emit changeRouteDrawingDataInQml(howManyCoordinatesToDelete, listOfCoordinatesToAdd, stateForUndoButton, stateForRedoButton, isRouteFullyDrawn);
}

void RouteDrawing::redoButtonPressed(double zoomLevel, int averageMapAreaLength, double latitudeWhereYouAre)
{
    int howManyCoordinatesToDelete = 0;
    QList<QGeoCoordinate> listOfCoordinatesToAdd;
    bool stateForUndoButton;
    bool stateForRedoButton;
    bool isRouteFullyDrawn;

    double avrgMapAreaLengthInMeters = Functions::distanceFromPointsAndZoomlevel(averageMapAreaLength, zoomLevel, latitudeWhereYouAre);
    double distanceNeededToGoAhead = 0.15 * avrgMapAreaLengthInMeters;

    if(isAdditCoordOnDplExist) {
        ++indexOfLastVisibleDplCoordOnDpl;
    }

    QList<QGeoCoordinate>::const_iterator it_dpl;
    if(detailedPolyLine.size() / 2 > indexOfLastVisibleDplCoordOnDpl)
        it_dpl = detailedPolyLine.constBegin() + indexOfLastVisibleDplCoordOnDpl;
    else
        it_dpl = detailedPolyLine.constEnd() - (detailedPolyLine.size() - indexOfLastVisibleDplCoordOnDpl);

    if(isAdditCoordOnDplExist) {
        if(movingNeededDitance(additCoordOnDpl, *it_dpl, distanceNeededToGoAhead)) {
            if(isAdditCoordOnDplExist) {
                --indexOfLastVisibleDplCoordOnDpl;
                stateForUndoButton = true;                                                    //3
                stateForRedoButton = true;                                                    //4
                isRouteFullyDrawn = false;                                                    //5
                emit changeRouteDrawingDataInQml(howManyCoordinatesToDelete, listOfCoordinatesToAdd, stateForUndoButton, stateForRedoButton, isRouteFullyDrawn);
                getPathForQmlPolyline();
                return;
            }
            else {
                stateForUndoButton = true;                                                    //3
                stateForRedoButton = indexOfLastVisibleDplCoordOnDpl != detailedPolyLine.size() - 1; //4
                isRouteFullyDrawn = !stateForRedoButton && isLastCoordOnDplIsCoordOfMarkerB;  //5
                emit changeRouteDrawingDataInQml(howManyCoordinatesToDelete, listOfCoordinatesToAdd, stateForUndoButton, stateForRedoButton, isRouteFullyDrawn);
                getPathForQmlPolyline();
                return;
            }
        }
    }

    QGeoCoordinate prevCoord;
    while(indexOfLastVisibleDplCoordOnDpl != detailedPolyLine.size() - 1) {
        prevCoord = *it_dpl;
        ++indexOfLastVisibleDplCoordOnDpl;
        ++it_dpl;
        if(movingNeededDitance(prevCoord, *it_dpl, distanceNeededToGoAhead)) {
            if(isAdditCoordOnDplExist) {
                --indexOfLastVisibleDplCoordOnDpl;
                stateForUndoButton = true;                                                    //3
                stateForRedoButton = true;                                                    //4
                isRouteFullyDrawn = false;                                                    //5
                emit changeRouteDrawingDataInQml(howManyCoordinatesToDelete, listOfCoordinatesToAdd, stateForUndoButton, stateForRedoButton, isRouteFullyDrawn);
                getPathForQmlPolyline();
                return;
            }
            else {
                stateForUndoButton = true;                                                    //3
                stateForRedoButton = indexOfLastVisibleDplCoordOnDpl != detailedPolyLine.size() - 1; //4
                isRouteFullyDrawn = !stateForRedoButton && isLastCoordOnDplIsCoordOfMarkerB;  //5
                emit changeRouteDrawingDataInQml(howManyCoordinatesToDelete, listOfCoordinatesToAdd, stateForUndoButton, stateForRedoButton, isRouteFullyDrawn);
                getPathForQmlPolyline();
                return;
            }
        }
    }
    stateForUndoButton = true;                                                    //3
    stateForRedoButton = false;                                                   //4
    isRouteFullyDrawn = isLastCoordOnDplIsCoordOfMarkerB;                         //5
    emit changeRouteDrawingDataInQml(howManyCoordinatesToDelete, listOfCoordinatesToAdd, stateForUndoButton, stateForRedoButton, isRouteFullyDrawn);
    getPathForQmlPolyline();
}

void RouteDrawing::prepareRouteDrawing(const QGeoCoordinate &firstCoord) {
    detailedPolyLine.clear();
    detailedPolyLine.append(firstCoord);
    listOfIndexesOnDplMeaningAbbrevPolyLine.clear();
    listOfIndexesOnDplMeaningAbbrevPolyLine.append(0);
    indexOfLastVisibleDplCoordOnDpl = 0;
    isAdditCoordOnDplExist = false;
    isLastCoordOnDplIsCoordOfMarkerB = false;
}

void RouteDrawing::getPathForQmlPolyline() {
    QList<QGeoCoordinate> pathForQmlPolyline;
    QList<int>::const_iterator indIt = listOfIndexesOnDplMeaningAbbrevPolyLine.constBegin();
    QList<QGeoCoordinate>::const_iterator coordIt(detailedPolyLine.constBegin() + *indIt);
    int prevInd;
    while(true) {
        pathForQmlPolyline.append(*coordIt);
        prevInd = *indIt;
        if(++indIt == listOfIndexesOnDplMeaningAbbrevPolyLine.constEnd())
            break;
        if(*indIt > indexOfLastVisibleDplCoordOnDpl)
            break;
        coordIt += *indIt - prevInd;
    }
    int i = *--indIt + 1;
    ++coordIt;
    while(i <= indexOfLastVisibleDplCoordOnDpl) {
        pathForQmlPolyline.append(*coordIt);
        ++i;
        ++coordIt;
    }
    if(isAdditCoordOnDplExist) {
        pathForQmlPolyline.append(additCoordOnDpl);
    }
    emit updatePathOfQmlPolyline(pathForQmlPolyline);
}

//calculates the distance between points on the screen. answer in points
int RouteDrawing::distBetwTwoPoints(int x1, int x2, int y1, int y2) {
    return sqrt(pow(abs(x1 - x2), 2) + pow(abs(y1 - y2), 2));
}

int RouteDrawing::distBetwTwoCoordInPoints(const QGeoCoordinate &coord1, const QGeoCoordinate &coord2, double zoomLevel) {
    return Functions::pointsFromDistanceAndZoomlevel(Functions::distBetwTwoCoordInMeters(coord1, coord2), zoomLevel, (coord1.latitude() + coord2.latitude()) / 2.0);
}

bool RouteDrawing::movingNeededDitance(const QGeoCoordinate &beginCoord, const QGeoCoordinate &endCoord, double &distanceNeededToGo)
{
    double consideredDistance = Functions::distBetwTwoCoordInMeters(beginCoord, endCoord);
    if(consideredDistance + 0.01 > distanceNeededToGo) {
        if(consideredDistance - distanceNeededToGo < 0.01) {
            isAdditCoordOnDplExist = false;
            return true;
        }
        else {
            isAdditCoordOnDplExist = true;
            additCoordOnDpl.setLatitude(beginCoord.latitude() + distanceNeededToGo / consideredDistance * (endCoord.latitude() - beginCoord.latitude()));
            additCoordOnDpl.setLongitude(beginCoord.longitude() + distanceNeededToGo / consideredDistance * (endCoord.longitude() - beginCoord.longitude()));
            return true;
        }
    }
    else {
        isAdditCoordOnDplExist = false;
        distanceNeededToGo -= consideredDistance;
        return false;
    }
}
