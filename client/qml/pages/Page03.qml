import QtQuick 2.15
import "../components/forWholeProject"
import "../components/forOptionsMenu"

Rectangle {
    //id: page3
    visible: loaderOfPage3.status === Loader.Ready
    property alias fn3: fn3
    property alias page3_backButton: page3_backButton
    property alias page3_optionsMenu: page3_optionsMenu
    color: "white"
    Rectangle {
        id: page3_topRect
        width: parent.width
        height: pr.upperAndLowerBlocksHeight
        color: pr.blueMainRectClr
        Text_standard_my {
            anchors.centerIn: parent
            text: qsTr("Extra options") //"Доп. параметры"
            font_pointSize_my: 22
            color: "white"
        }
    }
    ListView {
        id: page3_optionsMenu
        anchors.top: page3_topRect.bottom
        width: parent.width
        anchors.bottom: page3_backButton.top
        model: ObjectModel_page03_optionsMenu_my {}
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
        id: page3_backButton
        anchors.bottom: parent.bottom
        width: height
        leftProcessing: true
        onClicked: {
            forceActiveFocus()
            fn3.beforeLeaving()
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
        id: page3_planButton
        anchors.bottom: parent.bottom
        x: height + pr.standardClerancesSize
        width: parent.width - x
        text: qsTr("Plan") //"Запланировать"
        rightProcessing: true
        onClicked: {
            forceActiveFocus()
            fn3.beforeLeaving()
            page3_optionsMenu.model.hideAllMenus()
            loading = true
            var fromDepDateActMenuPoi = page3_optionsMenu.model.get(0).children[1].children[1].activeMenuPoint
            var toDepDateActMenuPoi = page3_optionsMenu.model.get(0).children[2].children[1].activeMenuPoint
            scm.planATripRequest(loaderOfMap_my.item.polyLine.path, //route
                                 page3_optionsMenu.model.get(0).children[1].children[0].children[1].text, //fromDepatrureTimeStr
                                 page3_optionsMenu.model.get(0).children[1].children[1].comboBoxModel.get(fromDepDateActMenuPoi).day, //fromDepDateDay
                                 page3_optionsMenu.model.get(0).children[1].children[1].comboBoxModel.get(fromDepDateActMenuPoi).month, //fromDepDateMonth
                                 page3_optionsMenu.model.get(0).children[1].children[1].comboBoxModel.get(fromDepDateActMenuPoi).year, //fromDepDateYear
                                 page3_optionsMenu.model.get(0).children[1].children[0].children[0].activeMenuPoint == 1, //withToDepT
                                 page3_optionsMenu.model.get(0).children[2].children[0].children[1].text, //toDepatrureTimeStr
                                 page3_optionsMenu.model.get(0).children[1].children[1].comboBoxModel.get(toDepDateActMenuPoi).day, //toDepDateDay
                                 page3_optionsMenu.model.get(0).children[1].children[1].comboBoxModel.get(toDepDateActMenuPoi).month, //toDepDateMonth
                                 page3_optionsMenu.model.get(0).children[1].children[1].comboBoxModel.get(toDepDateActMenuPoi).year, //toDepDateYear
                                 page3_optionsMenu.model.get(1).children[1].children[0].text, //emptySeatsStr
                                 page3_optionsMenu.model.get(2).children[1].children[0].children[1].currencyNumber, //currencyNumber
                                 page3_optionsMenu.model.get(2).children[1].children[0].children[0].text, //estimatedPrice
                                 page3_optionsMenu.model.get(3).children[1].children[0].text, //comment
                                 page3_optionsMenu.model.get(4).children[1].children[0].text, //name
                                 page3_optionsMenu.model.get(5).children[1].children[0].text, //contacts
                                 page3_optionsMenu.model.get(7).termsAccepted) //termsAcceped
        }
    }
    Connections {
        target: fnc
        function onUpdateDateAndTimeForExtraOpt(fromCheckOutTime_fq, toCheckOutTime_fq, day1_fq, day2_fq, day3_fq, day4_fq, month1_fq, month2_fq, month3_fq, month4_fq, year1_fq, year2_fq, year3_fq, year4_fq, datePlus2Days_fq, datePlus3Days_fq, withTransition_fq) {
            page3_optionsMenu.model.get(0).children[1].children[0].children[1].text = fromCheckOutTime_fq
            page3_optionsMenu.model.get(0).children[2].children[0].children[1].text = toCheckOutTime_fq
            page3_optionsMenu.model.get(0).children[1].children[1].comboBoxModel.get(0).day = day1_fq
            page3_optionsMenu.model.get(0).children[1].children[1].comboBoxModel.get(1).day = day2_fq
            page3_optionsMenu.model.get(0).children[1].children[1].comboBoxModel.get(2).day = day3_fq
            page3_optionsMenu.model.get(0).children[1].children[1].comboBoxModel.get(3).day = day4_fq
            page3_optionsMenu.model.get(0).children[1].children[1].comboBoxModel.get(0).month = month1_fq
            page3_optionsMenu.model.get(0).children[1].children[1].comboBoxModel.get(1).month = month2_fq
            page3_optionsMenu.model.get(0).children[1].children[1].comboBoxModel.get(2).month = month3_fq
            page3_optionsMenu.model.get(0).children[1].children[1].comboBoxModel.get(3).month = month4_fq
            page3_optionsMenu.model.get(0).children[1].children[1].comboBoxModel.get(0).year = year1_fq
            page3_optionsMenu.model.get(0).children[1].children[1].comboBoxModel.get(1).year = year2_fq
            page3_optionsMenu.model.get(0).children[1].children[1].comboBoxModel.get(2).year = year3_fq
            page3_optionsMenu.model.get(0).children[1].children[1].comboBoxModel.get(3).year = year4_fq
            page3_optionsMenu.model.get(0).children[1].children[1].comboBoxModel.get(2).mainText = datePlus2Days_fq
            page3_optionsMenu.model.get(0).children[1].children[1].comboBoxModel.get(2).menuText = datePlus2Days_fq
            page3_optionsMenu.model.get(0).children[1].children[1].comboBoxModel.get(3).mainText = datePlus3Days_fq
            page3_optionsMenu.model.get(0).children[1].children[1].comboBoxModel.get(3).menuText = datePlus3Days_fq
            page3_optionsMenu.model.get(0).children[2].children[1].comboBoxModel.get(2).mainText = datePlus2Days_fq
            page3_optionsMenu.model.get(0).children[2].children[1].comboBoxModel.get(2).menuText = datePlus2Days_fq
            page3_optionsMenu.model.get(0).children[2].children[1].comboBoxModel.get(3).mainText = datePlus3Days_fq
            page3_optionsMenu.model.get(0).children[2].children[1].comboBoxModel.get(3).menuText = datePlus3Days_fq
            if(withTransition_fq)
                page3_optionsMenu.model.get(0).children[2].children[1].activeMenuPoint = 1
        }
    }
    Connections {
        target: scm
        function onErrorSenderInQml(fromHereOrServer_fq, errorCode1_fq, errorCode2_fq) {
            if(page3_planButton.loading == false)
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
                else if(errorCode1_fq == 10) {
                    if(errorCode2_fq == 1)
                        fn.showToast(qsTr("you cannot schedule more than 20 trips")) //"нельзя запланировать больше 20 поездок"
                    else if(errorCode2_fq == 2)
                        fn.showToast(qsTr("time entered incorrectly")) //"некорректно введено время"
                    else if(errorCode2_fq == 3)
                        fn.showToast(qsTr("the entered time has already passed")) //"введённое время уже прошло"
                    else if(errorCode2_fq == 4)
                        fn.showToast(qsTr("time «from» must not be later than «to»")) //"время «с» не должно быть позже чем «до»"
                    else if(errorCode2_fq == 5)
                        fn.showToast(qsTr("departure time must be within four days")) //"время выезда должно быть в течении четырёх дней"
                    else if(errorCode2_fq == 6)
                        fn.showToast(qsTr("the number of empty seats must be between 1 and 200")) //"количество свободных мест должно быть от 1 до 200"
                    else if(errorCode2_fq == 7)
                        fn.showToast(qsTr("comment text size should not exceed 1000 characters")) //"размер текста комментария не должен превышать 1000 символов"
                    else if(errorCode2_fq == 8)
                        fn.showToast(qsTr("contact text size should not exceed 200 characters")) //"размер текста контактов не должен превышать 200 символов"
                    else if(errorCode2_fq == 9)
                        fn.showToast(qsTr("fill in the «Contacts» field")) //"заполните поле «Контакты»"
                    else if(errorCode2_fq == 10) {
                        fn.showToast(qsTr("terms of use and privacy policy not accepted")) //"не приняты условия использования и политика конфиденциальности"
                        page3_optionsMenu.positionViewAtEnd()
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
                if(errorCode1_fq == 10) {
                    if(errorCode2_fq == 2)
                        fn.showTextWindow(qsTr("The allowed number of trip planning requests per day from your IP address has been exceeded.")) //"Превышено допустимое количество запросов в день на планирование поездки с вашего IP адреса."
                    else if(errorCode2_fq == 3)
                        fn.showTextWindow(qsTr("An error occurred while processing data on the server.")) //"Возникла ошибка при обработке данных на сервере."
                    else if(errorCode2_fq == 4) {
                        fn.showTextWindow(qsTr("The trip has been created. An error occurred while saving data to the device memory. The next time you open the application, the trip will not be displayed, and it will not be possible to delete it. You can delete it now or it will be deleted after the expiration date.")) //"Поездка создана. Возникла ошибка при сохранении данных в память устройства. При следующем запуске приложения поездка не будет отображена, также её нельзя будет удалить. Вы можете удалить её сейчас или она удалится после истечения срока действия."
                        forceActiveFocus()
                        pr.page3_waitingForPage5ToLoad = true
                        pr.currentPage = 5
                    }
                    else if(errorCode2_fq == 5) {
                        forceActiveFocus()
                        pr.page3_waitingForPage5ToLoad = true
                        pr.currentPage = 5
                    }
                }
            }
            page3_planButton.loading = false
        }
        function onShowWindowWithText(textToShowWindow_en_fq, textForBackButton_en_fq, textToShowWindow_ru_fq, textForBackButton_ru_fq, showOnlyIfLoading_fq) {
            if(showOnlyIfLoading_fq && page3_planButton.loading == false)
                return
            if(pr.systemLanguage === "ru")
                fn.showTextWindow(textToShowWindow_ru_fq, textForBackButton_ru_fq)
            else
                fn.showTextWindow(textToShowWindow_en_fq, textForBackButton_en_fq)
            page3_planButton.loading = false
        }
    }
    Item {
        id: fn3
        function loaded() {
            page3_optionsMenu.model.get(0).children[1].children[0].children[0].activeMenuPoint = pr.page3_departureTimeAtOrFromTo ? 0 : 1
            fnc.getDateAndTimeForExtraOpt()
            page3_optionsMenu.model.get(1).children[1].children[0].text = pr.page3_emptySeats
            if(pr.systemLanguage === "ru") {
                if(pr.page3_currencyNumber == 643) { page3_optionsMenu.model.get(2).children[1].children[0].children[1].activeMenuPoint = 0 }
                else if(pr.page3_currencyNumber == 933) { page3_optionsMenu.model.get(2).children[1].children[0].children[1].activeMenuPoint = 1 }
                else if(pr.page3_currencyNumber == 980) { page3_optionsMenu.model.get(2).children[1].children[0].children[1].activeMenuPoint = 2 }
                else if(pr.page3_currencyNumber == 398) { page3_optionsMenu.model.get(2).children[1].children[0].children[1].activeMenuPoint = 3 }
                else if(pr.page3_currencyNumber == 840) { page3_optionsMenu.model.get(2).children[1].children[0].children[1].activeMenuPoint = 4 }
                else if(pr.page3_currencyNumber == 978) { page3_optionsMenu.model.get(2).children[1].children[0].children[1].activeMenuPoint = 5 }
                else if(pr.page3_currencyNumber == 0) { page3_optionsMenu.model.get(2).children[1].children[0].children[1].activeMenuPoint = 6 }
            }
            else {
                if(pr.page3_currencyNumber == 840) { page3_optionsMenu.model.get(2).children[1].children[0].children[1].activeMenuPoint = 0 }
                else if(pr.page3_currencyNumber == 978) { page3_optionsMenu.model.get(2).children[1].children[0].children[1].activeMenuPoint = 1 }
                else if(pr.page3_currencyNumber == 643) { page3_optionsMenu.model.get(2).children[1].children[0].children[1].activeMenuPoint = 2 }
                else if(pr.page3_currencyNumber == 933) { page3_optionsMenu.model.get(2).children[1].children[0].children[1].activeMenuPoint = 3 }
                else if(pr.page3_currencyNumber == 980) { page3_optionsMenu.model.get(2).children[1].children[0].children[1].activeMenuPoint = 4 }
                else if(pr.page3_currencyNumber == 398) { page3_optionsMenu.model.get(2).children[1].children[0].children[1].activeMenuPoint = 5 }
                else if(pr.page3_currencyNumber == 0) { page3_optionsMenu.model.get(2).children[1].children[0].children[1].activeMenuPoint = 6 }
            }
            page3_optionsMenu.model.get(4).children[1].children[0].text = pr.page3_name
            page3_optionsMenu.model.get(5).children[1].children[0].text = pr.page3_contacts
        }
        function beforeLeaving() {
            pr.page3_departureTimeAtOrFromTo = page3_optionsMenu.model.get(0).children[1].children[0].children[0].activeMenuPoint == 0
            pr.page3_emptySeats = page3_optionsMenu.model.get(1).children[1].children[0].text
            pr.page3_currencyNumber = page3_optionsMenu.model.get(2).children[1].children[0].children[1].currencyNumber
            pr.page3_name = page3_optionsMenu.model.get(4).children[1].children[0].text
            pr.page3_contacts = page3_optionsMenu.model.get(5).children[1].children[0].text
        }
    }
}
