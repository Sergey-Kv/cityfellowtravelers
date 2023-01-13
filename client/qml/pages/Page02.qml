import QtQuick 2.15
import QtLocation 5.15
import QtPositioning 5.15
import "../components/forWholeProject"
import "../components/forOptionsMenu"

Rectangle {
    //id: page2
    visible: (pr.currentPage == 2 && isPrepared) || (pr.currentPage == 3 && loaderOfPage3.status !== Loader.Ready) || (pr.currentPage == 4 && loaderOfPage4.status !== Loader.Ready)
    property bool isPrepared: false
    property alias pr2: pr2
    property alias fn2: fn2
    property alias page2_backButton: page2_backButton
    property alias page2_field3_rect: page2_field3_rect
    property bool isCurrPage2: pr.currentPage == 2
    onIsCurrPage2Changed: {
        if(isCurrPage2 && !pr.isDriverMode && isPrepared) {
            fn2.returnedFromPage4()
        }
    }
    color: "white"
    Item {
        id: pr2
        property double page2_fields_text_x_margin: 15
        property color page2_actFieClr: "#f2f2f2"
    }
    Rectangle {
        width: parent.width
        height: pr.upperAndLowerBlocksHeight
        color: pr.isDriverMode ? pr.blueMainRectClr : pr.greenMainRectClr
        Text_standard_my {
            //id: page2_topRect_text
            anchors.centerIn: parent
            text: pr.page2_activeField == 1 ? qsTr("Indicate from where") : pr.page2_activeField == 2 ? qsTr("To where") : (page2_field3_rect.children[0].children[0].activeMenuPoint == 1 ? pr.isTheRouteFullyDrawn ? qsTr("Route ready") : qsTr("Draw the route") : qsTr("Route")) //"Укажите откуда" //"Куда" //"Маршрут готов" //"Нарисуйте маршрут" //"Маршрут"
            font_pointSize_my: 22
            color: "white"
        }
    }
    Rectangle {
        z: 2
        anchors.bottom: page2_nextButton.top
        width: parent.width
        height: ((pr.isDriverMode ? 2 : 1) * pr.upperAndLowerBlocksHeight) - pr.standardClerancesSize
        color: "#d1d1d1"
        Rectangle {
            id: page2_field1_rect
            width: (parent.width - pr.standardClerancesSize) / 2
            height: pr.upperAndLowerBlocksHeight - pr.standardClerancesSize
            color: pr.page2_activeField == 1 ? pr2.page2_actFieClr : "white"
            Text_standard_my {
                id: page2_field1_text
                x: pr2.page2_fields_text_x_margin
                anchors.verticalCenter: parent.verticalCenter
                text: qsTr("From") //"Откуда"
                font_pointSize_my: 22
                color: pr.page2_fieldsTextClr
            }
            MouAreaWSCH {
                anchors.fill: parent
                leftProcessing: true
                onClicked: fn2.comeToField1()
            }
        }
        Rectangle {
            id: page2_field2_rect
            anchors.right: parent.right
            width: page2_field1_rect.width
            height: page2_field1_rect.height
            color: pr.page2_activeField == 2 ? pr2.page2_actFieClr : "white"
            Text_standard_my {
                id: page2_field2_text
                x: pr2.page2_fields_text_x_margin
                anchors.verticalCenter: parent.verticalCenter
                text: qsTr("To") //"Куда"
                font_pointSize_my: page2_field1_text.font_pointSize_my
                color: pr.page2_fieldsTextClr
            }
            MouAreaWSCH {
                anchors.fill: parent
                rightProcessing: true
                onClicked: fn2.comeToField2()
            }
        }
        Rectangle {
            id: page2_field3_rect
            visible: pr.isDriverMode
            anchors.bottom: parent.bottom
            width: parent.width
            height: page2_field1_rect.height
            color: pr.page2_activeField == 3 ? pr2.page2_actFieClr : "white"
            Row_page02_field3_my {
                z: 2
                x: pr2.page2_fields_text_x_margin
                anchors.verticalCenter: parent.verticalCenter
            }
            MouAreaWSCH {
                anchors.fill: parent
                leftProcessing: true
                rightProcessing: true
                onClicked: fn2.comeToField3()
            }
        }
    }
    Button_turquoise_my {
        id: page2_backButton
        anchors.bottom: parent.bottom
        width: height
        leftProcessing: true
        onClicked: {
            fn2.beforeLeaving()
            pr.currentPage = 1
        }
        Image {
            anchors.centerIn: parent
            width: 22
            height: 22
            source: "qrc:/img/forWholeProject/backArrow.png"
        }
    }
    Button_turquoise_my {
        id: page2_nextButton
        anchors.bottom: parent.bottom
        x: height + pr.standardClerancesSize
        width: parent.width - x
        text: qsTr("Next") //"Далее"
        active: pr.isDriverMode ? pr.page2_activeField == 3 && (page2_field3_rect.children[0].children[0].activeMenuPoint == 0 ? pr.areRequiredRoutesLoaded && loaderOfMap_my.item.routeModel.savedPathsCount > 0 : pr.isTheRouteFullyDrawn) : pr.page2_isMarkerBSet
        rightProcessing: true
        onClicked: {
            fn2.beforeLeaving()
            if(pr.isDriverMode) {
                if(fnc.polylineLengthInMeters(loaderOfMap_my.item.polyLine.path) > 301000) {
                    fn.showToast(qsTr("route length should not exceed 300 km")) //"длинна маршрута не должна превышать 300 км"
                    return
                }
                pr.currentPage = 3
            }
            else {
                if(fnc.distBetwTwoCoordInMeters(pr.page2_activeField == 2 ? loaderOfMap_my.item.passMarkerA.coordinate : loaderOfMap_my.item.passMarkerB.coordinate, loaderOfMap_my.item.map.center) > 200000) {
                    fn.showToast(qsTr("distance between A and B must be less than 200 km")) //"расстояние между А и Б должно быть меньше 200 км"
                    return
                }
                pr.currentPage = 4
            }
        }
    }
    Item {
        id: fn2
        function loaded() {
            pr.page2_activeField = 1
            pr.page2_isMarkerBSet = false
            pr.page2_isMarkerBCanBeViewedAfterSetting = false
            pr.areRequiredRoutesLoaded = false
            loaderOfMap_my.item.fnMM.changeMapCenter(false, pr.savedLocationForMarkerA)
            loaderOfMap_my.item.fnMM.changeMapZoomLevel(false, pr.savedZoomLevelForFields1And2)
            loaderOfMap_my.item.polyLine.path = []
            loaderOfMap_my.item.routeModel.reset()
            isPrepared = true
        }
        function returnedFromPage4() {
            if(pr.page2_activeField == 1) {
                loaderOfMap_my.item.fnMM.changeMapCenter(false, QtPositioning.coordinate(pr.savedMapMarkABLocToRetFromP5AndForSeaForADrReq[0], pr.savedMapMarkABLocToRetFromP5AndForSeaForADrReq[1]))
                loaderOfMap_my.item.passMarkerB.coordinate.latitude = pr.savedMapMarkABLocToRetFromP5AndForSeaForADrReq[2]
                loaderOfMap_my.item.passMarkerB.coordinate.longitude = pr.savedMapMarkABLocToRetFromP5AndForSeaForADrReq[3]
            }
            else {
                loaderOfMap_my.item.passMarkerA.coordinate.latitude = pr.savedMapMarkABLocToRetFromP5AndForSeaForADrReq[0]
                loaderOfMap_my.item.passMarkerA.coordinate.longitude = pr.savedMapMarkABLocToRetFromP5AndForSeaForADrReq[1]
                loaderOfMap_my.item.fnMM.changeMapCenter(false, QtPositioning.coordinate(pr.savedMapMarkABLocToRetFromP5AndForSeaForADrReq[2], pr.savedMapMarkABLocToRetFromP5AndForSeaForADrReq[3]))
            }
            loaderOfMap_my.item.fnMM.changeMapZoomLevel(false, pr.savedMapZoomLevelToReturnFromPage5)
            var temp = loaderOfMap_my.item.map.zoomLevel
            loaderOfMap_my.item.map.zoomLevel = temp - 0.001
            loaderOfMap_my.item.map.zoomLevel = temp
        }
        function comeToField1() {
            if(pr.page2_activeField == 1)
                return
            leaveCurrentField()
            if(pr.page2_activeField == 3)
                loaderOfMap_my.item.fnMM.changeMapZoomLevel(true, pr.savedZoomLevelForFields1And2, 600, loaderOfMap_my.item.animForMapCenter.running ? 1 : 0)
            if(pr.isDriverMode)
                loaderOfMap_my.item.fnMM.changeMapCenter(true, loaderOfMap_my.item.drivMarkerA.coordinate, pr.page2_activeField == 3 ? 600 : 300, loaderOfMap_my.item.animForMapCenter.running ? 1 : 0)
            else
                loaderOfMap_my.item.fnMM.changeMapCenter(true, loaderOfMap_my.item.passMarkerA.coordinate, pr.page2_activeField == 3 ? 600 : 300, loaderOfMap_my.item.animForMapCenter.running ? 1 : 0)
            pr.page2_activeField = 1
        }
        function comeToField2() {
            if(pr.page2_activeField == 2)
                return
            leaveCurrentField()
            if(pr.page2_activeField == 3)
                loaderOfMap_my.item.fnMM.changeMapZoomLevel(true, pr.savedZoomLevelForFields1And2, 600, 0)
            if(pr.page2_isMarkerBSet) {
                pr.page2_isMarkerBCanBeViewedAfterSetting = true
                if(pr.isDriverMode)
                    loaderOfMap_my.item.fnMM.changeMapCenter(true, loaderOfMap_my.item.drivMarkerB.coordinate, pr.page2_activeField == 3 ? 600 : 300, loaderOfMap_my.item.animForMapCenter.running ? 1 : 0)
                else
                    loaderOfMap_my.item.fnMM.changeMapCenter(true, loaderOfMap_my.item.passMarkerB.coordinate, pr.page2_activeField == 3 ? 600 : 300, loaderOfMap_my.item.animForMapCenter.running ? 1 : 0)
            }
            else {
                var targetCoordinate = loaderOfMap_my.item.map.toCoordinate(Qt.point(loaderOfMap_my.item.map.width / 2 + 50, loaderOfMap_my.item.map.height / 2 + 25))
                if(pr.isDriverMode)
                    loaderOfMap_my.item.drivMarkerB.coordinate = targetCoordinate
                else
                    loaderOfMap_my.item.passMarkerB.coordinate = targetCoordinate
                loaderOfMap_my.item.fnMM.changeMapCenter(true, targetCoordinate, pr.page2_activeField == 3 ? 600 : 300, loaderOfMap_my.item.animForMapCenter.running ? 1 : 0)
            }
            pr.page2_isMarkerBSet = true
            pr.page2_activeField = 2
        }
        function comeToField3() {
            if(pr.page2_activeField == 3) {
                page2_field3_rect.children[0].hideAllMenus()
                return
            }
            if(!pr.page2_isMarkerBSet) {
                fn.showToast(qsTr("first indicate from where and to where")) //"сначала укажите откуда и куда"
                return
            }
            if(fnc.distBetwTwoCoordInMeters(pr.page2_activeField == 2 ? loaderOfMap_my.item.drivMarkerA.coordinate : loaderOfMap_my.item.drivMarkerB.coordinate, loaderOfMap_my.item.map.center) > 200000) {
                fn.showToast(qsTr("distance between A and B must be less than 200 km")) //"расстояние между А и Б должно быть меньше 200 км"
                return
            }
            leaveCurrentField()
            if(pr.savedLocationsForMarkersAAndBOfField3[0] !== loaderOfMap_my.item.drivMarkerA.coordinate.latitude || pr.savedLocationsForMarkersAAndBOfField3[1] !== loaderOfMap_my.item.drivMarkerA.coordinate.longitude || pr.savedLocationsForMarkersAAndBOfField3[2] !== loaderOfMap_my.item.drivMarkerB.coordinate.latitude || pr.savedLocationsForMarkersAAndBOfField3[3] !== loaderOfMap_my.item.drivMarkerB.coordinate.longitude) {
                fn2.prepareDownloadMode()
                fn2.prepareDrawingMode()
                fn2.reinstallThePolyline()
                fn2.positionTheMap()
                if(page2_field3_rect.children[0].children[0].activeMenuPoint == 0)
                    fn2.downloadRoutes()
            }
            else {
                if(page2_field3_rect.children[0].children[0].activeMenuPoint == 0 && !pr.areRequiredRoutesLoaded && loaderOfMap_my.item.routeModel.status !== RouteModel.Loading)
                    fn2.downloadRoutes()
                fn2.positionTheMap()
            }
            pr.page2_activeField = 3
            page2_field3_rect.children[0].children[0].arrowForComboBox.requestPaint()
        }
        function leaveCurrentField() {
            if(pr.page2_activeField == 1) {
                if(!loaderOfMap_my.item.animForMapCenter.running) {
                    pr.savedLocationForMarkerA = QtPositioning.coordinate(loaderOfMap_my.item.map.center.latitude, loaderOfMap_my.item.map.center.longitude)
                    if(pr.isDriverMode)
                        loaderOfMap_my.item.drivMarkerA.coordinate = loaderOfMap_my.item.map.center
                    else
                        loaderOfMap_my.item.passMarkerA.coordinate = loaderOfMap_my.item.map.center
                }
                pr.savedZoomLevelForFields1And2 = loaderOfMap_my.item.map.zoomLevel
            }
            else if(pr.page2_activeField == 2) {
                if(!loaderOfMap_my.item.animForMapCenter.running || (loaderOfMap_my.item.animForMapCenter.running && !pr.page2_isMarkerBCanBeViewedAfterSetting)) {
                    if(pr.isDriverMode)
                        loaderOfMap_my.item.drivMarkerB.coordinate = loaderOfMap_my.item.map.center
                    else
                        loaderOfMap_my.item.passMarkerB.coordinate = loaderOfMap_my.item.map.center
                }
                pr.savedZoomLevelForFields1And2 = loaderOfMap_my.item.map.zoomLevel
            }
            else if(pr.page2_activeField == 3) {
                if(page2_field3_rect.children[0].children[0].activeMenuPoint == 1 && !pr.isTheRouteFullyDrawn)
                    pr.savedZoomLevelForRouteDrawing = loaderOfMap_my.item.map.zoomLevel
                pr.savedLocationsForMarkersAAndBOfField3[0] = loaderOfMap_my.item.drivMarkerA.coordinate.latitude
                pr.savedLocationsForMarkersAAndBOfField3[1] = loaderOfMap_my.item.drivMarkerA.coordinate.longitude
                pr.savedLocationsForMarkersAAndBOfField3[2] = loaderOfMap_my.item.drivMarkerB.coordinate.latitude
                pr.savedLocationsForMarkersAAndBOfField3[3] = loaderOfMap_my.item.drivMarkerB.coordinate.longitude
                page2_field3_rect.children[0].hideAllMenus()
            }
        }
        function downloadRoutes() {
            loaderOfMap_my.item.routeModel.reset()
            loaderOfMap_my.item.routeQuery.clearWaypoints()
            loaderOfMap_my.item.routeQuery.addWaypoint(loaderOfMap_my.item.drivMarkerA.coordinate)
            loaderOfMap_my.item.routeQuery.addWaypoint(loaderOfMap_my.item.drivMarkerB.coordinate)
            loaderOfMap_my.item.routeModel.update()
        }
        function prepareDownloadMode() {
            loaderOfMap_my.item.routeModel.reset()
            pr.areRequiredRoutesLoaded = false
        }
        function prepareDrawingMode() {
            rdr.prepareRouteDrawing(loaderOfMap_my.item.drivMarkerA.coordinate)
            loaderOfMap_my.item.itemForRouteDrawingMode.children[2].distanceToBIsSmall = false
            loaderOfMap_my.item.polyLine.path = [loaderOfMap_my.item.drivMarkerA.coordinate]
            loaderOfMap_my.item.circleForRouteDrawingMode.coordinate = loaderOfMap_my.item.drivMarkerA.coordinate
            pr.isTheRouteFullyDrawn = false
            page2_field3_rect.children[0].children[4].isActive = false
            page2_field3_rect.children[0].children[5].isActive = false
        }
        function reinstallThePolyline() {
            if(page2_field3_rect.children[0].children[0].activeMenuPoint == 0) {
                if(pr.areRequiredRoutesLoaded) {
                    if(loaderOfMap_my.item.routeModel.savedPathsCount > 1) {
                        if(page2_field3_rect.children[0].children[3].routeOneOrTwo)
                            loaderOfMap_my.item.polyLine.path = loaderOfMap_my.item.routeModel.savedPaths[0]
                        else
                            loaderOfMap_my.item.polyLine.path = loaderOfMap_my.item.routeModel.savedPaths[1]
                    }
                    else if(loaderOfMap_my.item.routeModel.savedPathsCount == 1)
                        loaderOfMap_my.item.polyLine.path = loaderOfMap_my.item.routeModel.savedPaths[0]
                    else
                        loaderOfMap_my.item.polyLine.path = []
                }
                else
                    loaderOfMap_my.item.polyLine.path = []
            }
            else
                rdr.getPathForQmlPolyline()
        }
        function positionTheMap() {
            if(page2_field3_rect.children[0].children[0].activeMenuPoint == 0) {
                if(pr.areRequiredRoutesLoaded && loaderOfMap_my.item.routeModel.savedPathsCount > 0) {
                    if(loaderOfMap_my.item.routeModel.savedPathsCount == 1)
                        fnc.calculateMapPositionToShow1Route(loaderOfMap_my.item.routeModel.savedPaths[0], loaderOfMap_my.item.drivMarkerA.coordinate, loaderOfMap_my.item.drivMarkerB.coordinate, loaderOfMap_my.item.drivMarkerA_img.width, loaderOfMap_my.item.drivMarkerA_img.height, loaderOfMap_my.item.map.width, loaderOfMap_my.item.map.height, Math.min(loaderOfMap_my.item.map.width, loaderOfMap_my.item.map.height) * 0.05)
                    else
                        fnc.calculateMapPositionToShow2Route(loaderOfMap_my.item.routeModel.savedPaths[0], loaderOfMap_my.item.routeModel.savedPaths[1], loaderOfMap_my.item.drivMarkerA.coordinate, loaderOfMap_my.item.drivMarkerB.coordinate, loaderOfMap_my.item.drivMarkerA_img.width, loaderOfMap_my.item.drivMarkerA_img.height, loaderOfMap_my.item.map.width, loaderOfMap_my.item.map.height, Math.min(loaderOfMap_my.item.map.width, loaderOfMap_my.item.map.height) * 0.05)
                }
                else
                    fnc.calculateMapPositionToShow2Markers(loaderOfMap_my.item.drivMarkerA.coordinate, loaderOfMap_my.item.drivMarkerB.coordinate, loaderOfMap_my.item.drivMarkerA_img.width, loaderOfMap_my.item.drivMarkerA_img.height, loaderOfMap_my.item.map.width, loaderOfMap_my.item.map.height, Math.min(loaderOfMap_my.item.map.width, loaderOfMap_my.item.map.height) * 0.05)
            }
            else {
                if(pr.isTheRouteFullyDrawn)
                    fnc.calculateMapPositionToShow1Route(loaderOfMap_my.item.polyLine.path, loaderOfMap_my.item.drivMarkerA.coordinate, loaderOfMap_my.item.drivMarkerB.coordinate, loaderOfMap_my.item.drivMarkerA_img.width, loaderOfMap_my.item.drivMarkerA_img.height, loaderOfMap_my.item.map.width, loaderOfMap_my.item.map.height, Math.min(loaderOfMap_my.item.map.width, loaderOfMap_my.item.map.height) * 0.05)
                else {
                    loaderOfMap_my.item.fnMM.changeMapZoomLevel(true, pr.savedZoomLevelForRouteDrawing, 600, loaderOfMap_my.item.animForMapCenter.running ? 1 : 0)
                    loaderOfMap_my.item.fnMM.changeMapCenter(true, loaderOfMap_my.item.circleForRouteDrawingMode.coordinate, 600, loaderOfMap_my.item.animForMapCenter.running ? 1 : 0)
                }
            }
        }
        function updateInformationAboutDrawnRoute() {
            var dist = fnc.polylineLengthInMeters(loaderOfMap_my.item.polyLine.path)
            if(dist < 1000)
                pr.informationAboutDrawnRoute = parseInt(dist) + qsTr(" m") //" м"
            else if(dist < 100000)
                pr.informationAboutDrawnRoute = parseInt(dist / 100) / 10 + qsTr(" km") //" км"
            else
                pr.informationAboutDrawnRoute = parseInt(dist / 1000) + qsTr(" km") //" км"
        }
        function beforeLeaving() {
            if(pr.page2_activeField == 1) {
                pr.savedLocationForMarkerA = QtPositioning.coordinate(loaderOfMap_my.item.map.center.latitude, loaderOfMap_my.item.map.center.longitude)
                pr.savedZoomLevelForFields1And2 = loaderOfMap_my.item.map.zoomLevel
            }
            else if(pr.page2_activeField == 2)
                pr.savedZoomLevelForFields1And2 = loaderOfMap_my.item.map.zoomLevel
            else if(pr.page2_activeField == 3 && page2_field3_rect.children[0].children[0].activeMenuPoint == 1 && !pr.isTheRouteFullyDrawn) {
                pr.savedZoomLevelForRouteDrawing = loaderOfMap_my.item.map.zoomLevel
            }
            pr.savedLocationsForMarkersAAndBOfField3 = [0.0, 0.0, 0.0, 0.0]
            if(!pr.isDriverMode) {
                if(pr.page2_activeField == 1) {
                    pr.savedMapMarkABLocToRetFromP5AndForSeaForADrReq[0] = loaderOfMap_my.item.map.center.latitude
                    pr.savedMapMarkABLocToRetFromP5AndForSeaForADrReq[1] = loaderOfMap_my.item.map.center.longitude
                    pr.savedMapMarkABLocToRetFromP5AndForSeaForADrReq[2] = loaderOfMap_my.item.passMarkerB.coordinate.latitude
                    pr.savedMapMarkABLocToRetFromP5AndForSeaForADrReq[3] = loaderOfMap_my.item.passMarkerB.coordinate.longitude
                }
                else {
                    pr.savedMapMarkABLocToRetFromP5AndForSeaForADrReq[0] = loaderOfMap_my.item.passMarkerA.coordinate.latitude
                    pr.savedMapMarkABLocToRetFromP5AndForSeaForADrReq[1] = loaderOfMap_my.item.passMarkerA.coordinate.longitude
                    pr.savedMapMarkABLocToRetFromP5AndForSeaForADrReq[2] = loaderOfMap_my.item.map.center.latitude
                    pr.savedMapMarkABLocToRetFromP5AndForSeaForADrReq[3] = loaderOfMap_my.item.map.center.longitude
                }
                pr.savedMapZoomLevelToReturnFromPage5 = loaderOfMap_my.item.map.zoomLevel
            }
            page2_field3_rect.children[0].hideAllMenus()
        }
    }
}
