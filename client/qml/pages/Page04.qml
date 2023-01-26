import QtQuick 2.15
import QtPositioning 5.15
import "../components/forWholeProject"
import "../components/forOptionsMenu"

Rectangle {
    //id: page4
    visible: (pr.currentPage == 4 && loaderOfPage4.status === Loader.Ready) || (!pr.isDriverMode && pr.currentPage == 5 && (loaderOfPage5.status !== Loader.Ready || !loaderOfPage5.item.visible))
    property alias fn4: fn4
    property alias page4_backButton: page4_backButton
    property alias page4_optionsMenu: page4_optionsMenu
    color: "white"
    Rectangle {
        id: page4_topRect
        width: parent.width
        height: pr.upperAndLowerBlocksHeight
        color: pr.greenMainRectClr
        Text_standard_my {
            anchors.centerIn: parent
            text: qsTr("Extra options") //"Доп. параметры"
            font_pointSize_my: 22
            color: "white"
        }
    }
    ListView {
        id: page4_optionsMenu
        anchors.top: page4_topRect.bottom
        width: parent.width
        anchors.bottom: page4_backButton.top
        model: ObjectModel_page04_optionsMenu_my {}
        boundsBehavior: ListView.StopAtBounds
        cacheBuffer: 10000
        clip: true
        MouAreaWSCH {
            z: -1
            anchors.fill: parent
            leftProcessing: true
            rightProcessing: true
            onClicked: { forceActiveFocus(); parent.model.hideAllMenus() }
        }
    }
    Button_turquoise_my {
        id: page4_backButton
        anchors.bottom: parent.bottom
        width: height
        leftProcessing: true
        onClicked: {
            forceActiveFocus()
            fn4.beforeLeaving()
            pr.currentPage = 2
        }
        Image {
            anchors.centerIn: parent
            width: 22
            height: 22
            source: "qrc:/img/forWholeProject/backArrow.png"
        }
    }
    Button_turquoise_my {
        id: page4_searchButton
        anchors.bottom: parent.bottom
        x: height + pr.standardClerancesSize
        width: parent.width - x
        text: qsTr("Search") //"Искать"
        rightProcessing: true
        onClicked: {
            forceActiveFocus()
            fn4.beforeLeaving()
            page4_optionsMenu.model.hideAllMenus()
            loading = true
            var fromDepDateActMenuPoi = page4_optionsMenu.model.get(0).children[1].children[1].activeMenuPoint
            var toDepDateActMenuPoi = page4_optionsMenu.model.get(0).children[2].children[1].activeMenuPoint
            scm.searchForADriverRequest(QtPositioning.coordinate(pr.savedMapMarkABLocToRetFromP5AndForSeaForADrReq[0], pr.savedMapMarkABLocToRetFromP5AndForSeaForADrReq[1]), //markerA
                        QtPositioning.coordinate(pr.savedMapMarkABLocToRetFromP5AndForSeaForADrReq[2], pr.savedMapMarkABLocToRetFromP5AndForSeaForADrReq[3]), //markerB
                        page4_optionsMenu.model.get(0).children[1].children[0].children[1].text, //fromDepatrureTimeStr
                        page4_optionsMenu.model.get(0).children[1].children[0].children[1].activeMenuPoint == 0, //isFromTimeAmOrPm
                        page4_optionsMenu.model.get(0).children[1].children[1].comboBoxModel.get(fromDepDateActMenuPoi).day, //fromDepDateDay
                        page4_optionsMenu.model.get(0).children[1].children[1].comboBoxModel.get(fromDepDateActMenuPoi).month, //fromDepDateMonth
                        page4_optionsMenu.model.get(0).children[1].children[1].comboBoxModel.get(fromDepDateActMenuPoi).year, //fromDepDateYear
                        page4_optionsMenu.model.get(0).children[1].children[0].children[0].activeMenuPoint == 1, //withToDepT
                        page4_optionsMenu.model.get(0).children[2].children[0].children[1].text, //toDepatrureTimeStr
                        page4_optionsMenu.model.get(0).children[2].children[0].children[1].activeMenuPoint == 0, //isToTimeAmOrPm
                        page4_optionsMenu.model.get(0).children[1].children[1].comboBoxModel.get(toDepDateActMenuPoi).day, //toDepDateDay
                        page4_optionsMenu.model.get(0).children[1].children[1].comboBoxModel.get(toDepDateActMenuPoi).month, //toDepDateMonth
                        page4_optionsMenu.model.get(0).children[1].children[1].comboBoxModel.get(toDepDateActMenuPoi).year, //toDepDateYear
                        page4_optionsMenu.model.get(1).children[1].children[0].text, //numberOfPeopleStr
                        page4_optionsMenu.model.get(2).children[1].children[0].globalValue, //searchRadius
                        page4_optionsMenu.model.get(4).termsAccepted) //termsAcceped
        }
    }
    Connections {
        target: fnc
        function onUpdateDateAndTimeForExtraOpt(is24HourFormat_fq, fromCheckOutTime_fq, isFromTimeAmOrPm_fq, toCheckOutTime_fq, isToTimeAmOrPm_fq, day1_fq, day2_fq, day3_fq, day4_fq, month1_fq, month2_fq, month3_fq, month4_fq, year1_fq, year2_fq, year3_fq, year4_fq, datePlus2Days_fq, datePlus3Days_fq, withTransition_fq) {
            if(!is24HourFormat_fq) {
                page4_optionsMenu.model.get(0).children[1].children[0].children[1].activeMenuPoint = isFromTimeAmOrPm_fq ? 0 : 1
                page4_optionsMenu.model.get(0).children[2].children[0].children[1].activeMenuPoint = isToTimeAmOrPm_fq ? 0 : 1
                page4_optionsMenu.model.get(0).children[1].children[0].children[1].is24HourFormat = false
                page4_optionsMenu.model.get(0).children[2].children[0].children[1].is24HourFormat = false
            }
            page4_optionsMenu.model.get(0).children[1].children[0].children[1].text = fromCheckOutTime_fq
            page4_optionsMenu.model.get(0).children[2].children[0].children[1].text = toCheckOutTime_fq
            page4_optionsMenu.model.get(0).children[1].children[1].comboBoxModel.get(0).day = day1_fq
            page4_optionsMenu.model.get(0).children[1].children[1].comboBoxModel.get(1).day = day2_fq
            page4_optionsMenu.model.get(0).children[1].children[1].comboBoxModel.get(2).day = day3_fq
            page4_optionsMenu.model.get(0).children[1].children[1].comboBoxModel.get(3).day = day4_fq
            page4_optionsMenu.model.get(0).children[1].children[1].comboBoxModel.get(0).month = month1_fq
            page4_optionsMenu.model.get(0).children[1].children[1].comboBoxModel.get(1).month = month2_fq
            page4_optionsMenu.model.get(0).children[1].children[1].comboBoxModel.get(2).month = month3_fq
            page4_optionsMenu.model.get(0).children[1].children[1].comboBoxModel.get(3).month = month4_fq
            page4_optionsMenu.model.get(0).children[1].children[1].comboBoxModel.get(0).year = year1_fq
            page4_optionsMenu.model.get(0).children[1].children[1].comboBoxModel.get(1).year = year2_fq
            page4_optionsMenu.model.get(0).children[1].children[1].comboBoxModel.get(2).year = year3_fq
            page4_optionsMenu.model.get(0).children[1].children[1].comboBoxModel.get(3).year = year4_fq
            page4_optionsMenu.model.get(0).children[1].children[1].comboBoxModel.get(2).mainText = datePlus2Days_fq
            page4_optionsMenu.model.get(0).children[1].children[1].comboBoxModel.get(2).menuText = datePlus2Days_fq
            page4_optionsMenu.model.get(0).children[1].children[1].comboBoxModel.get(3).mainText = datePlus3Days_fq
            page4_optionsMenu.model.get(0).children[1].children[1].comboBoxModel.get(3).menuText = datePlus3Days_fq
            page4_optionsMenu.model.get(0).children[2].children[1].comboBoxModel.get(2).mainText = datePlus2Days_fq
            page4_optionsMenu.model.get(0).children[2].children[1].comboBoxModel.get(2).menuText = datePlus2Days_fq
            page4_optionsMenu.model.get(0).children[2].children[1].comboBoxModel.get(3).mainText = datePlus3Days_fq
            page4_optionsMenu.model.get(0).children[2].children[1].comboBoxModel.get(3).menuText = datePlus3Days_fq
            if(withTransition_fq)
                page4_optionsMenu.model.get(0).children[2].children[1].activeMenuPoint = 1
        }
    }
    Connections {
        target: scm
        function onErrorSenderInQml(fromHereOrServer_fq, errorCode1_fq, errorCode2_fq) {
            if(page4_searchButton.loading == false)
                return
            if(fromHereOrServer_fq) {
                if(errorCode1_fq == 1) {
                    if(errorCode2_fq == 1 || errorCode2_fq == 2)
                        fn.showTextWindow(qsTr("Failed to establish a connection to the server.")) //"Не удалось установить соединение с сервером."
                    else if(errorCode2_fq == 3)
                        fn.showTextWindow(qsTr("An error has occurred in the application.")) //"Возникла ошибка в приложении."
                    else if(errorCode2_fq == 4)
                        fn.showTextWindow(qsTr("An error occurred while sending data (large data size).")) //"Возникла ошибка при отправке данных (большой размер данных)."
                }
                else if(errorCode1_fq == 11) {
                    if(errorCode2_fq == 1 || errorCode2_fq == 2)
                        fn.showToast(qsTr("time entered incorrectly")) //"некорректно введено время"
                    else if(errorCode2_fq == 3)
                        fn.showToast(qsTr("the entered time has already passed")) //"введённое время уже прошло"
                    else if(errorCode2_fq == 4)
                        fn.showToast(qsTr("time «from» must not be later than «to»")) //"время «с» не должно быть позже чем «до»"
                    else if(errorCode2_fq == 5)
                        fn.showToast(qsTr("departure time must be within four days")) //"время выезда должно быть в течении четырёх дней"
                    else if(errorCode2_fq == 6)
                        fn.showToast(qsTr("the number of people must be from 1 to 200")) //"количество человек должно быть от 1 до 200"
                    else if(errorCode2_fq == 7)
                        fn.showToast(qsTr("search radius should be from 10 to 1000 meters")) //"радиус поиска должен быть от 10 до 1000 метров"
                    else if(errorCode2_fq == 8) {
                        fn.showToast(qsTr("terms of use and privacy policy not accepted")) //"не приняты условия использования и политика конфиденциальности"
                        page4_optionsMenu.positionViewAtEnd()
                    }
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
                if(errorCode1_fq == 11) {
                    if(errorCode2_fq == 2)
                        fn.showTextWindow(qsTr("The allowed number of driver search requests per day from your IP address has been exceeded.")) //"Превышено допустимое количество запросов в день на поиск водителей с вашего IP адреса."
                    else if(errorCode2_fq == 3) {
                        forceActiveFocus()
                        pr.currentPage = 5
                    }
                }
            }
            page4_searchButton.loading = false
        }
        function onShowWindowWithText(textToShowWindow_en_fq, textForBackButton_en_fq, textToShowWindow_ru_fq, textForBackButton_ru_fq, showOnlyIfLoading_fq) {
            if(showOnlyIfLoading_fq && page4_searchButton.loading == false)
                return
            if(pr.systemLanguage === "ru")
                fn.showTextWindow(textToShowWindow_ru_fq, textForBackButton_ru_fq)
            else
                fn.showTextWindow(textToShowWindow_en_fq, textForBackButton_en_fq)
            page4_searchButton.loading = false
        }
    }
    Item {
        id: fn4
        function loaded() {
            page4_optionsMenu.model.get(0).children[1].children[0].children[0].activeMenuPoint = pr.page4_needToDepartAtOrFromTo ? 0 : 1
            fnc.getDateAndTimeForExtraOpt()
            page4_optionsMenu.model.get(1).children[1].children[0].text = pr.page4_howManyPeople
        }
        function beforeLeaving() {
            pr.page4_needToDepartAtOrFromTo = page4_optionsMenu.model.get(0).children[1].children[0].children[0].activeMenuPoint == 0
            pr.page4_howManyPeople = page4_optionsMenu.model.get(1).children[1].children[0].text
            pr.page4_searchRadius = page4_optionsMenu.model.get(2).children[1].children[0].globalValue
        }
    }
}
