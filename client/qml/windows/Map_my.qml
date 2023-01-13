import QtQuick 2.15
import QtLocation 5.15
import QtPositioning 5.15
import "../components/forWholeProject"
import "../components/forMap"

Item {
    //id: map_my
    visible: (loaderOfPage2.status === Loader.Ready && loaderOfPage2.item.visible) || (loaderOfPage5.status === Loader.Ready && loaderOfPage5.item.visible && loaderOfPage5.item.myTripsModel.count != 0)
    property alias map: map
    property alias routeQuery: routeQuery
    property alias routeModel: routeModel
    property alias polyLine: polyLine
    property alias circleForRouteDrawingMode: circleForRouteDrawingMode
    property alias itemForRouteDrawingMode: itemForRouteDrawingMode
    property alias drivMarkerA: drivMarkerA
    property alias passMarkerA: passMarkerA
    property alias drivMarkerB: drivMarkerB
    property alias passMarkerB: passMarkerB
    property alias drivMarkerA_img: drivMarkerA_img
    property alias markerAAndBBeforePutting: markerAAndBBeforePutting
    property alias animForMapCenter: animForMapCenter
    property alias animForMapZoomLevel: animForMapZoomLevel
    property alias prMM: prMM
    property alias fnMM: fnMM
    Item {
        id: prMM
        property bool areMapElementsSmall: pr.currentPage == 5
    }
    Map {
        id: map
        height: loaderOfPage2.status === Loader.Ready && loaderOfPage2.item.visible ? (parent.height - (((pr.isDriverMode ? 4 : 3) * pr.upperAndLowerBlocksHeight) - pr.standardClerancesSize)) : loaderOfPage5.status === Loader.Ready && loaderOfPage5.item.visible ? loaderOfPage5.item.mapHeight : 300
        width: parent.width
        y: pr.upperAndLowerBlocksHeight
        plugin: Plugin {
            id: osmPlugin
            name: "osm"
            PluginParameter { name: "osm.mapping.cache.disk.size"; value: 200000000 }
            PluginParameter { name: "osm.mapping.cache.memory.size"; value: 12000000 }
            PluginParameter { name: "osm.mapping.cache.texture.size"; value: 24000000 }

            PluginParameter { name: "osm.mapping.custom.host"; value: "http://tile.osmand.net/hd/" }  // should be https
            //PluginParameter { name: "osm.mapping.custom.host"; value: "http://tile.openstreetmap.org/" }  // should be https

            PluginParameter { name: "osm.useragent"; value: "cityfellowtravelers" }
        }
        activeMapType: supportedMapTypes[supportedMapTypes.length-1]
        copyrightsVisible: false
        gesture.enabled: !mouAreaForRouteDrawingMode.isTheTargetHit
        gesture.acceptedGestures: MapGestureArea.PinchGesture | MapGestureArea.PanGesture | MapGestureArea.FlickGesture
        onMapReadyChanged: if(mapReady) fnMM.mapReady()
        RouteQuery {
            id: routeQuery
            maneuverDetail: RouteQuery.NoManeuvers
            segmentDetail: RouteQuery.NoSegmentData
            numberAlternativeRoutes: 1
        }
        RouteModel {
            id: routeModel
            property var savedPaths
            property int savedPathsCount
            property var temporaryStorageForPath
            plugin: osmPlugin
            query: routeQuery
            autoUpdate: false
            onStatusChanged: {
                if(status == RouteModel.Ready) {
                    if(loaderOfPage2.status === Loader.Ready && loaderOfPage2.item.visible) {
                        savedPathsCount = Math.min(count, 2)
                        var paths = []
                        for(var i = 0; i < savedPathsCount; ++i) {
                            fnc.compressRouteFromInternet(drivMarkerA.coordinate, drivMarkerB.coordinate, get(i).path)
                            paths[i] = temporaryStorageForPath
                            var timeInSeconds = get(i).travelTime
                            var infoAboutTime
                            if(timeInSeconds < 3600)
                                infoAboutTime = parseInt(timeInSeconds / 60) + qsTr(" min") //" мин"
                            else if(timeInSeconds % 3600 < 60)
                                infoAboutTime = parseInt(timeInSeconds / 3600) + qsTr(" h") //" ч"
                            else
                                infoAboutTime = parseInt(timeInSeconds / 3600) + qsTr(" h  ") + parseInt((timeInSeconds % 3600) / 60) + qsTr(" min") //" ч  " //" мин"
                            var dist = fnc.polylineLengthInMeters(paths[i])
                            var infoAboutDist
                            if(dist < 1000)
                                infoAboutDist = parseInt(dist) + qsTr(" m") //" м"
                            else if(dist < 100000)
                                infoAboutDist = parseInt(dist / 100) / 10 + qsTr(" km") //" км"
                            else
                                infoAboutDist = parseInt(dist / 1000) + qsTr(" km") //" км"
                            if(i == 0)
                                pr.informationAboutRoute1 = infoAboutTime + qsTr(",  ") + infoAboutDist
                            else
                                pr.informationAboutRoute2 = infoAboutTime + qsTr(",  ") + infoAboutDist
                        }
                        if(savedPathsCount > 0)
                            savedPaths = paths
                        pr.areRequiredRoutesLoaded = true
                        if(pr.page2_activeField != 3 || (pr.page2_activeField == 3 && loaderOfPage2.item.page2_field3_rect.children[0].children[0].activeMenuPoint == 0)) {
                            loaderOfPage2.item.fn2.reinstallThePolyline()
                        }
                        if(pr.page2_activeField == 3 && loaderOfPage2.item.page2_field3_rect.children[0].children[0].activeMenuPoint == 0)
                            loaderOfPage2.item.fn2.positionTheMap()
                    }
                }
                else if(status == RouteModel.Error) {
                    if(loaderOfPage2.status === Loader.Ready && loaderOfPage2.item.visible && pr.page2_activeField == 3 && loaderOfPage2.item.page2_field3_rect.children[0].children[0].activeMenuPoint == 0) {
                        if(error == RouteModel.CommunicationError)
                            fn.showToast(qsTr("no connection")) //"нет соединения"
                        else
                            fn.showToast(qsTr("failed to load route")) //"не удалось загрузить маршрут"
                    }
                }
            }
        }
        Timer {
            interval: 10000
            running: routeModel.status === RouteModel.Loading
            onTriggered: {
                routeModel.reset()
                if(loaderOfPage2.status === Loader.Ready && loaderOfPage2.item.visible && pr.page2_activeField == 3 && loaderOfPage2.item.page2_field3_rect.children[0].children[0].activeMenuPoint == 0)
                    fn.showToast(qsTr("failed to load route")) //"не удалось загрузить маршрут"
            }
        }
        MapPolyline {
            id: polyLine
            visible: (loaderOfPage2.status === Loader.Ready && loaderOfPage2.item.visible && pr.page2_activeField == 3) || (loaderOfPage5.status === Loader.Ready && loaderOfPage5.item.visible)
            autoFadeIn: false
            line.width: prMM.areMapElementsSmall ? 2.5 : 3
            line.color: "purple"
            z: 1
        }
        MapQuickItem {
            id: circleForRouteDrawingMode
            autoFadeIn: false
            anchorPoint.x: itemForRouteDrawingMode.width / 2
            anchorPoint.y: rectForRouteDrawingMode.width / 2
            z: 2
            sourceItem: Item {
                id: itemForRouteDrawingMode
                opacity: children[2].enabled ? 1 : 0
                property double rectCenToImgCenDist: 43
                width: imgForRouteDrawingMode.width
                height: rectForRouteDrawingMode.width / 2 + rectCenToImgCenDist + imgForRouteDrawingMode.height / 2
                Rectangle {
                    id: rectForRouteDrawingMode
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: polyLine.line.width * 1.5
                    height: width
                    radius: width / 2
                    color: polyLine.line.color
                }
                Image {
                    id: imgForRouteDrawingMode
                    anchors.bottom: parent.bottom
                    width: 45
                    height: width
                    source: "qrc:/img/forPage2/circleForRouteDrawingMode.png"
                    opacity: 0.75
                }
                MouseArea {
                    id: mouAreaForRouteDrawingMode
                    enabled: pr.isDriverMode && pr.currentPage == 2 && pr.page2_activeField == 3 && loaderOfPage2.item.page2_field3_rect.children[0].children[0].activeMenuPoint == 1 && !pr.isTheRouteFullyDrawn
                    anchors.fill: imgForRouteDrawingMode
                    property bool distanceToBIsSmall: false
                    property bool isTheTargetHit: false
                    property bool wasThereAMove
                    property double horizOffset
                    property double vertOffset
                    property int previousX
                    property int previousY
                    onPressed: {
                        var mapMouseX = circleForRouteDrawingMode.x + mouseX
                        var mapMouseY = circleForRouteDrawingMode.y + (parent.height - height) + mouseY
                        wasThereAMove = false
                        if(map.fromCoordinate(circleForRouteDrawingMode.coordinate).x > 0 && map.fromCoordinate(circleForRouteDrawingMode.coordinate).y > 0 && map.fromCoordinate(circleForRouteDrawingMode.coordinate).y + parent.rectCenToImgCenDist < map.height && rdr.distBetwTwoCoordInPoints(map.toCoordinate(Qt.point(mapMouseX, mapMouseY)), map.toCoordinate(Qt.point(map.fromCoordinate(circleForRouteDrawingMode.coordinate).x, map.fromCoordinate(circleForRouteDrawingMode.coordinate).y + parent.rectCenToImgCenDist)), map.zoomLevel) < imgForRouteDrawingMode.width / 2) {
                            isTheTargetHit = true
                            horizOffset = map.fromCoordinate(circleForRouteDrawingMode.coordinate).x - mapMouseX
                            vertOffset = map.fromCoordinate(circleForRouteDrawingMode.coordinate).y - mapMouseY
                            previousX = mapMouseX
                            previousY = mapMouseY
                            distanceToBIsSmall = rdr.distBetwTwoCoordInPoints(circleForRouteDrawingMode.coordinate, drivMarkerB.coordinate, map.zoomLevel) < 20
                        }
                    }
                    onPositionChanged: {
                        var mapMouseX = circleForRouteDrawingMode.x + mouseX
                        var mapMouseY = circleForRouteDrawingMode.y + (parent.height - height) + mouseY
                        if(isTheTargetHit && mapMouseX + horizOffset > 0 && mapMouseX + horizOffset < map.width && mapMouseY + vertOffset > 0 && mapMouseY + vertOffset + parent.rectCenToImgCenDist < map.height) {
                            wasThereAMove = true
                            circleForRouteDrawingMode.coordinate = map.toCoordinate(Qt.point(mapMouseX + horizOffset, mapMouseY + vertOffset))
                            if(rdr.distBetwTwoPoints(previousX, mapMouseX, previousY, mapMouseY) > 1) {
                                rdr.newCoordArrived(circleForRouteDrawingMode.coordinate, map.zoomLevel)
                                previousX = mapMouseX
                                previousY = mapMouseY
                                distanceToBIsSmall = rdr.distBetwTwoCoordInPoints(circleForRouteDrawingMode.coordinate, drivMarkerB.coordinate, map.zoomLevel) < 20
                            }
                        }
                    }
                    onReleased: onReleaCancAndEtc()
                    onCanceled: onReleaCancAndEtc()
                    function onReleaCancAndEtc() {
                        if(isTheTargetHit) {
                            if(wasThereAMove)
                                rdr.newCoordArrived(circleForRouteDrawingMode.coordinate, map.zoomLevel)
                            if(distanceToBIsSmall) {
                                rdr.newCoordArrived(drivMarkerB.coordinate, map.zoomLevel, true)
                                pr.savedZoomLevelForRouteDrawing = map.zoomLevel
                                timerToShowDrawnRoute.running = true
                                loaderOfPage2.item.fn2.updateInformationAboutDrawnRoute()
                            }
                        }
                        isTheTargetHit = false
                    }
                }
                Timer {
                    id: timerToShowDrawnRoute
                    interval: 150
                    onTriggered: loaderOfPage2.item.fn2.positionTheMap()
                }
            }
        }
        MapQuickItem {
            id: drivMarkerA
            visible: {
                if(pr.currentPage != 5) {
                    if(pr.isDriverMode) {
                        if(pr.page2_activeField == 1 && !animForMapCenter.running)
                            return false
                        else
                            return true
                    }
                    else
                        return false
                }
                else
                    return true
            }
            autoFadeIn: false
            anchorPoint.x: drivMarkerA_img.width / 2
            anchorPoint.y: drivMarkerA_img.height
            z: 3 + (coordinate.latitude < passMarkerA.coordinate.latitude ? 1 : 0) + (coordinate.latitude < drivMarkerB.coordinate.latitude ? 1 : 0) + (coordinate.latitude < passMarkerB.coordinate.latitude ? 1 : 0)
            sourceItem: MapMarker_my {
                id: drivMarkerA_img
                driversOrPassengers: true
                aOrB: true
                isSmall: prMM.areMapElementsSmall
            }
        }
        MapQuickItem {
            id: passMarkerA
            visible: {
                if(pr.currentPage != 5) {
                    if(pr.isDriverMode)
                        return false
                    else {
                        if(pr.page2_activeField == 1 && !animForMapCenter.running)
                            return false
                        else
                            return true
                    }
                }
                else {
                    if(pr.isDriverMode)
                        return false
                    else
                        return true
                }
            }
            autoFadeIn: false
            anchorPoint.x: passMarkerA_img.width / 2
            anchorPoint.y: passMarkerA_img.height
            z: 3 + (coordinate.latitude < drivMarkerA.coordinate.latitude ? 1 : 0) + (coordinate.latitude < drivMarkerB.coordinate.latitude ? 1 : 0) + (coordinate.latitude < passMarkerB.coordinate.latitude ? 1 : 0)
            sourceItem: MapMarker_my {
                id: passMarkerA_img
                driversOrPassengers: false
                aOrB: true
                isSmall: prMM.areMapElementsSmall
            }
        }
        MapQuickItem {
            id: drivMarkerB
            visible: {
                if(pr.currentPage != 5) {
                    if(pr.isDriverMode) {
                        if(pr.page2_isMarkerBSet) {
                            if(pr.page2_activeField != 2)
                                return true
                            else {
                                if(animForMapCenter.running) {
                                    if(pr.page2_isMarkerBCanBeViewedAfterSetting)
                                        return true
                                    else
                                        return false
                                }
                                else
                                    return false
                            }
                        }
                        else
                            return false
                    }
                    else
                        return false
                }
                else
                    return true
            }
            autoFadeIn: false
            anchorPoint.x: drivMarkerB_img.width / 2
            anchorPoint.y: drivMarkerB_img.height
            z: 3 + (coordinate.latitude < drivMarkerA.coordinate.latitude ? 1 : 0) + (coordinate.latitude < passMarkerA.coordinate.latitude ? 1 : 0) + (coordinate.latitude < passMarkerB.coordinate.latitude ? 1 : 0)
            sourceItem: MapMarker_my {
                id: drivMarkerB_img
                driversOrPassengers: true
                aOrB: false
                isSmall: prMM.areMapElementsSmall
                opacity: pr.isDriverMode && pr.currentPage == 2 && pr.page2_activeField == 3 && loaderOfPage2.item.page2_field3_rect.children[0].children[0].activeMenuPoint == 1 && !pr.isTheRouteFullyDrawn && (!mouAreaForRouteDrawingMode.distanceToBIsSmall || (mouAreaForRouteDrawingMode.distanceToBIsSmall && !mouAreaForRouteDrawingMode.isTheTargetHit)) ? 0.6 : 1.0
            }
        }
        MapQuickItem {
            id: passMarkerB
            visible: {
                if(pr.currentPage != 5) {
                    if(pr.isDriverMode)
                        return false
                    else {
                        if(pr.page2_isMarkerBSet) {
                            if(pr.page2_activeField != 2)
                                return true
                            else {
                                if(animForMapCenter.running) {
                                    if(pr.page2_isMarkerBCanBeViewedAfterSetting)
                                        return true
                                    else
                                        return false
                                }
                                else
                                    return false
                            }
                        }
                        else
                            return false
                    }
                }
                else {
                    if(pr.isDriverMode)
                        return false
                    else
                        return true
                }
            }
            autoFadeIn: false
            anchorPoint.x: passMarkerB_img.width / 2
            anchorPoint.y: passMarkerB_img.height
            z: 3 + (coordinate.latitude < drivMarkerA.coordinate.latitude ? 1 : 0) + (coordinate.latitude < passMarkerA.coordinate.latitude ? 1 : 0) + (coordinate.latitude < drivMarkerB.coordinate.latitude ? 1 : 0)
            sourceItem: MapMarker_my {
                id: passMarkerB_img
                driversOrPassengers: false
                aOrB: false
                isSmall: prMM.areMapElementsSmall
            }
        }
        MapMarker_my {
            id: markerAAndBBeforePutting
            visible: {
                if(pr.currentPage != 5) {
                    if(pr.page2_activeField != 3) {
                        if(animForMapCenter.running) {
                            if(pr.page2_activeField != 2)
                                return false
                            else {
                                if(pr.page2_isMarkerBCanBeViewedAfterSetting)
                                    return false
                                else
                                    return true
                            }
                        }
                        else
                            return true
                    }
                    else
                        return false
                }
                else
                    return false
            }
            x: parent.width / 2 - this.width / 2
            y: parent.height / 2 - this.height
            z: 7
            driversOrPassengers: pr.isDriverMode
            aOrB: pr.page2_activeField == 1
        }
        Text_standard_my {
            id: mapProviderInformation
            visible: !prMM.areMapElementsSmall
            anchors.left: parent.left
            anchors.leftMargin: 9
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 3
            text: qsTr("©") + " <font color=\"#00bdad\"><u><a href=\"http://www.openstreetmap.org/\">OpenStreetMap</a></u></font>, <font color=\"#00bdad\"><u><a href=\"http://www.osmand.net/\">OsmAnd</a></u></font>" + qsTr(" contributors") //"© Участники" //" "
            onLinkActivated: Qt.openUrlExternally(link)
            color: "#666666"
            font_pointSize_my: 10
            opacity: 0.75
            z: 8
            Rectangle {
                anchors.fill: parent
                anchors.topMargin: -1
                anchors.leftMargin: -6
                anchors.rightMargin: -6
                anchors.bottomMargin: -1
                z: -1
                radius: height / 2
                color: "white"
                opacity: 0.87
            }
        }
        Item {
            id: plusMinusButtonsForMap
            visible: !prMM.areMapElementsSmall
            anchors.right: parent.right
            anchors.rightMargin: 9
            anchors.bottom: parent.bottom
            anchors.bottomMargin: (parent.height - height) / 20
            z: 9
            width: 40
            height: 80
            Rectangle {
                anchors.fill: parent
                radius: 4
                color: "white"
                opacity: 0.75
                Rectangle {
                    anchors.verticalCenter: parent.verticalCenter
                    width: parent.width
                    height: 1
                    color: "#dedede"
                }
            }

            Text_standard_my {
                anchors.centerIn: parent
                anchors.verticalCenterOffset: -parent.height / 4
                text: "+"
                color: "#666666"
                font_pointSize_my: 32
                opacity: mouAreaForPlusMinusButtonsForMap.pressed && mouAreaForPlusMinusButtonsForMap.mouseY <= mouAreaForPlusMinusButtonsForMap.height / 2 ? 0.55 : 0.75
            }
            Text_standard_my {
                anchors.centerIn: parent
                anchors.verticalCenterOffset: parent.height / 4
                text: "−"
                color: "#666666"
                font_pointSize_my: 32
                opacity: mouAreaForPlusMinusButtonsForMap.pressed && mouAreaForPlusMinusButtonsForMap.mouseY > mouAreaForPlusMinusButtonsForMap.height / 2 ? 0.55 : 0.75
            }
            MouAreaWSCH {
                id: mouAreaForPlusMinusButtonsForMap
                anchors.fill: parent
                anchors.margins: -5
                rightProcessing: true
                distFromRightEdge: 30 - (9 - 5)
                onClicked: {
                    if(mouseY <= height / 2) {
                        if(animForMapZoomLevel.running)
                            fnMM.changeMapZoomLevel(true, Math.min(animForMapZoomLevel.to + 1, 19), 300, 1)
                        else
                            fnMM.changeMapZoomLevel(true, Math.min(map.zoomLevel + 1, 19), 350, 0)
                    }
                    else {
                        if(animForMapZoomLevel.running)
                            fnMM.changeMapZoomLevel(true, Math.max(animForMapZoomLevel.to - 1, 0), 300, 1)
                        else
                            fnMM.changeMapZoomLevel(true, Math.max(map.zoomLevel - 1, 0), 350, 0)
                    }
                }
            }
        }
        CoordinateAnimation {
            id: animForMapCenter
            target: map
            properties: "center"
            from: map.center
        }
        NumberAnimation {
            id: animForMapZoomLevel
            target: map
            properties: "zoomLevel"
            from: map.zoomLevel
        }
    }
    Connections {
        target: rdr
        function onChangeRouteDrawingDataInQml(howManyCoordinatesToDelete_fq, listOfCoordinatesToAdd_fq, stateForUndoButton_fq, stateForRedoButton_fq, isRouteFullyDrawn_fq) {
            var lastIndex = polyLine.pathLength() - 1
            for(var i = 0; i < howManyCoordinatesToDelete_fq; ++i, --lastIndex) {
                polyLine.removeCoordinate(lastIndex)
            }
            for(i = 0; i < listOfCoordinatesToAdd_fq.length; ++i) {
                polyLine.addCoordinate(listOfCoordinatesToAdd_fq[i])
            }
            loaderOfPage2.item.page2_field3_rect.children[0].children[4].isActive = stateForUndoButton_fq
            loaderOfPage2.item.page2_field3_rect.children[0].children[5].isActive = stateForRedoButton_fq
            pr.isTheRouteFullyDrawn = isRouteFullyDrawn_fq
        }
        function onUpdatePathOfQmlPolyline(path_fq) {
            polyLine.path = path_fq
        }
    }
    Connections {
        target: fnc
        function onChangeMapPosition(mapCenter_fq, mapZoomLevel_fq) {
            fnMM.changeMapZoomLevel(pr.currentPage != 5, Math.min(mapZoomLevel_fq, 17), 600, animForMapCenter.running ? 1 : 0)
            fnMM.changeMapCenter(pr.currentPage != 5, QtPositioning.coordinate(mapCenter_fq.latitude, mapCenter_fq.longitude), 600, animForMapCenter.running ? 1 : 0)
        }
        function onPutTheRouteInTemporaryStorage(route_fq) {
            routeModel.temporaryStorageForPath = route_fq
        }
    }
    Item {
        id: fnMM
        function loaded() { if(map.mapReady) mapReadyAndLoaded() }
        function mapReady() { if(loaderOfMap_my.status === Loader.Ready) mapReadyAndLoaded() }
        function mapReadyAndLoaded() {
            pr.mapPrepared = true
        }
        function changeMapCenter(withAnim, afterCoord, duration = 300, easingType = 0) {
            if(animForMapCenter.running)
                animForMapCenter.stop()
            if(withAnim) {
                animForMapCenter.to = afterCoord
                animForMapCenter.duration = duration
                if(easingType === 0)
                    animForMapCenter.easing.type = Easing.InOutQuad
                else if(easingType === 1)
                    animForMapCenter.easing.type = Easing.OutQuad
                animForMapCenter.running = true
            }
            else
                map.center = afterCoord
        }
        function changeMapZoomLevel(withAnim, afterZl, duration = 300, easingType = 0) {
            if(animForMapZoomLevel.running)
                animForMapZoomLevel.stop()
            if(withAnim) {
                animForMapZoomLevel.to = afterZl
                animForMapZoomLevel.duration = duration
                if(easingType === 0)
                    animForMapZoomLevel.easing.type = Easing.InOutQuad
                else if(easingType === 1)
                    animForMapZoomLevel.easing.type = Easing.OutQuad
                animForMapZoomLevel.running = true
            }
            else
                map.zoomLevel = afterZl
        }
        function updateElementsOnTheMap() {
            if(!animForMapZoomLevel.running) {
                var temp = map.zoomLevel
                map.zoomLevel = temp - 0.001
                map.zoomLevel = temp
            }
        }
    }
}
