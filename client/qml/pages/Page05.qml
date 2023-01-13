import QtQuick 2.15
import "../components/forWholeProject"
import "../components/forPage5"

Rectangle {
    id: page5
    visible: isPrepared
    property bool isPrepared: false
    property alias myTripsView: myTripsView
    property alias myTripsModel: myTripsModel
    property double mapHeight: Math.max(100, Math.min(height - pr.upperAndLowerBlocksHeight - 100, (height - pr.upperAndLowerBlocksHeight) * pr.page5_mapHKoef))
    property alias fn5: fn5
    property alias page5_backButton: page5_backButton
    color: "white"
    Rectangle {
        id: page5_topRect
        width: parent.width
        height: pr.upperAndLowerBlocksHeight
        color: pr.isDriverMode ? pr.blueMainRectClr : pr.greenMainRectClr
        Text_standard_my {
            anchors.centerIn: parent
            text: pr.isDriverMode ? qsTr("My trips") : qsTr("Driver search") //"Мои поездки" //"Поиск водителей"
            font_pointSize_my: 22
            color: "white"
        }
    }
    Item {
        width: parent.width
        height: parent.height - pr.upperAndLowerBlocksHeight - (myTripsModel.count == 0 ? 0 : mapHeight + dividingLine.height)
        anchors.bottom: parent.bottom
        Rectangle {
            anchors.fill: parent
            color: pr.blueMainRectClr
            opacity: myTripsModel.count == 0 ? (pr.isDriverMode ? 0.1 : 0.06) : 0.13
        }
        Text_standard_my {
            visible: myTripsModel.count == 0
            anchors.top: parent.top
            anchors.topMargin: 20
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width - 30
            wrapMode: Text.Wrap
            text: pr.isDriverMode ? qsTr("You have no planned trips") : qsTr("Suitable drivers not found") //"У вас нет запланированных поездок" //"Подходящих водителей не найдено"
            horizontalAlignment: Text.AlignHCenter
            color: "#aaaaaa"
            font_pointSize_my: 20
        }
        ListView {
            id: myTripsView
            anchors.fill: parent
            boundsBehavior: ListView.StopAtBounds
            model: ListModel { id: myTripsModel }
            header: Item { height: 5 }
            delegate: MyTripsViewElement_my {}
            footer: Item { height: myTripsView.height - 80 }
            cacheBuffer: application.height * 4
            clip: true
            currentIndex: 0
            onCurrentIndexChanged: {
                if(pr.isDriverMode)
                    tmn.getRouteForThisIndexForMyTrips(currentIndex)
                else
                    tmn.getRouteForThisIndexForFoundTrips(currentIndex)
            }
            onContentYChanged: {
                if(currentIndex == indexAt(11, contentY + 60))
                    return
                var ind = indexAt(11, contentY + 60)
                if(ind >= 0 && ind < myTripsModel.count)
                    currentIndex = ind
            }
            remove: Transition {
                NumberAnimation { property: "opacity"; to: 0; duration: 300 }
            }
            removeDisplaced: Transition {
                NumberAnimation { properties: "x,y"; duration: 300; easing.type: Easing.InOutSine }
            }
            Canvas {
                visible: myTripsModel.count != 0
                width: 6
                anchors.right: parent.right
                height: width * 1.5
                y: 60 - height / 2
                z: -1
                onPaint: {
                    var ctx = getContext("2d");
                    ctx.reset();
                    ctx.fillStyle = "#d9d9d9";
                    ctx.beginPath();
                    ctx.moveTo(width, 0);
                    ctx.lineTo(0, height / 2);
                    ctx.lineTo(width, height);
                    ctx.closePath();
                    ctx.fill();
                }
            }
        }
    }
    Rectangle {
        id: dividingLine
        visible: myTripsModel.count != 0
        anchors.top: parent.top
        anchors.topMargin: pr.upperAndLowerBlocksHeight + mapHeight
        width: parent.width
        height: 12
        color: "#f7f7f7"
        MouseArea {
            width: parent.width
            height: parent.height + 16
            anchors.verticalCenter: parent.verticalCenter
            property double prevMouY
            onPressed: prevMouY = mouseY
            onPositionChanged: pr.page5_mapHKoef = (mapHeight + mouseY - prevMouY) / (parent.parent.height - pr.upperAndLowerBlocksHeight)
            onReleased: loaderOfMap_my.item.fnMM.updateElementsOnTheMap()
            Rectangle {
                anchors.centerIn: parent
                width: 60
                height: 3
                color: "#dcdcdc"
                radius: height / 2
            }
        }
    }
    Button_turquoise_my {
        id: page5_backButton
        anchors.bottom: parent.bottom
        width: height
        leftProcessing: true
        onClicked: {
            forceActiveFocus()
            //fn5.beforeLeaving()
            if(pr.isDriverMode)
                pr.currentPage = 1
            else {
                pr.currentPage = 4
            }
        }
        Image {
            anchors.centerIn: parent
            width: 22
            height: 22
            source: "qrc:/img/forWholeProject/backArrow.png"
        }
    }
    Connections {
        target: tmn
        function onInsertTrip(text_fq, beginOrEnd_fq) {
            if(beginOrEnd_fq)
                myTripsModel.insert(0, { text: text_fq })
            else
                myTripsModel.append({ text: text_fq })
            myTripsView.contentYChanged()
        }
        function onRemoveMyTrip(index_fq) {
            if(pr.isDriverMode) {
                if(loaderOfAdditComp_my.item.textWindow.visible && loaderOfAdditComp_my.item.textWindow.indexForDelButton == index_fq) {
                    loaderOfAdditComp_my.item.textWindow.loading = false
                    loaderOfAdditComp_my.item.textWindow.visible = false
                }
                var currInd = myTripsView.currentIndex
                var modelCount = myTripsModel.count
                myTripsModel.remove(index_fq)
                if(index_fq === currInd && index_fq !== modelCount - 1)
                    tmn.getRouteForThisIndexForMyTrips(index_fq)
            }
        }
        function onInstallRouteForMyTrip(route_fq, drivMarkerA_fq, drivMarkerB_fq) {
            fnc.calculateMapPositionToShow1Route(route_fq, drivMarkerA_fq, drivMarkerB_fq, loaderOfMap_my.item.drivMarkerA_img.width, loaderOfMap_my.item.drivMarkerA_img.height, loaderOfMap_my.item.map.width, mapHeight, Math.min(loaderOfMap_my.item.map.width, mapHeight) * 0.05)
            loaderOfMap_my.item.polyLine.path = route_fq
            loaderOfMap_my.item.drivMarkerA.coordinate = drivMarkerA_fq
            loaderOfMap_my.item.drivMarkerB.coordinate = drivMarkerB_fq
        }
        function onInstallRouteForFoundTrip(route_fq, drivMarkerA_fq, drivMarkerB_fq, passMarkerA_fq, passMarkerB_fq) {
            fnc.calculateMapPositionToShow1RouteAnd4Markers(route_fq, drivMarkerA_fq, drivMarkerB_fq, passMarkerA_fq, passMarkerB_fq, loaderOfMap_my.item.drivMarkerA_img.width, loaderOfMap_my.item.drivMarkerA_img.height, loaderOfMap_my.item.map.width, mapHeight, Math.min(loaderOfMap_my.item.map.width, mapHeight) * 0.05)
            loaderOfMap_my.item.polyLine.path = route_fq
            loaderOfMap_my.item.drivMarkerA.coordinate = drivMarkerA_fq
            loaderOfMap_my.item.drivMarkerB.coordinate = drivMarkerB_fq
            loaderOfMap_my.item.passMarkerA.coordinate = passMarkerA_fq
            loaderOfMap_my.item.passMarkerB.coordinate = passMarkerB_fq
        }
    }
    Connections {
        target: scm
        function onErrorSenderInQml(fromHereOrServer_fq, errorCode1_fq, errorCode2_fq) {
            if(loaderOfAdditComp_my.item.textWindow.loading == false)
                return
            loaderOfAdditComp_my.item.textWindow.loading = false
            if(fromHereOrServer_fq) {
                if(errorCode1_fq == 1) {
                    if(errorCode2_fq == 1 || errorCode2_fq == 2)
                        fn.showTextWindow(qsTr("Failed to establish a connection to the server.")) //"Не удалось установить соединение с сервером."
                    else if(errorCode2_fq == 3)
                        fn.showTextWindow(qsTr("An error has occurred in the application.")) //"Возникла ошибка в приложении."
                    else if(errorCode2_fq == 4)
                        fn.showTextWindow(qsTr("An error occurred while sending data (large data size).")) //"Возникла ошибка при отправке данных (большой размер данных)."
                }
            }
            else {
                if(errorCode1_fq == 1) {
                    if(errorCode2_fq == 1)
                        fn.showTextWindow(qsTr("An error occurred while connecting. Try again.")) //"Возникла ошибка при подключении. Попробуйте снова."
                    else if(errorCode2_fq == 2)
                        fn.showTextWindow(qsTr("An error occurred while connecting (the allowed number of requests per day from your IP address has been exceeded).")) //"Возникла ошибка при подключении (превышено допустимое количество запросов в день с вашего IP адреса)."
                    else if(errorCode2_fq == 3)
                        fn.showTextWindow(qsTr("Your version of the app is no longer supported, please update the app.")) //"Ваша версия приложения больше не поддерживается, пожалуйста обновите приложение."
                    else if(errorCode2_fq == 4 || errorCode2_fq == 6)
                        fn.showTextWindow(qsTr("An error occurred while processing data on the server.")) //"Возникла ошибка при обработке данных на сервере."
                }
                if(errorCode1_fq == 12) {
                    if(errorCode2_fq == 2)
                        fn.showTextWindow(qsTr("The allowed number of trip deletion requests per day from your IP address has been exceeded.")) //"Превышено допустимое количество запросов в день на удаление поездки с вашего IP адреса."
                }
            }
        }
        function onShowWindowWithText(textToShowWindow_en_fq, textForBackButton_en_fq, textToShowWindow_ru_fq, textForBackButton_ru_fq, showOnlyIfLoading_fq) {
            if(showOnlyIfLoading_fq && loaderOfAdditComp_my.item.textWindow.loading == false)
                return
            if(pr.systemLanguage === "ru")
                fn.showTextWindow(textToShowWindow_ru_fq, textForBackButton_ru_fq)
            else
                fn.showTextWindow(textToShowWindow_en_fq, textForBackButton_en_fq)
            loaderOfAdditComp_my.item.textWindow.loading = false
        }
    }
    Item {
        id: fn5
        function loaded() {
            if(pr.isDriverMode) {
                tmn.fillTheModelWithInformationAboutMyTrips()
                if(myTripsModel.count != 0)
                    tmn.getRouteForThisIndexForMyTrips(0)
            }
            else {
                tmn.fillTheModelWithInformationAboutFoundTrips()
                if(myTripsModel.count != 0)
                    tmn.getRouteForThisIndexForFoundTrips(0)
            }
            loaderOfMap_my.item.fnMM.updateElementsOnTheMap()
            isPrepared = true
            pr.page3_waitingForPage5ToLoad = false
        }
    }
}
