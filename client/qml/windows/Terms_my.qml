import QtQuick 2.15
import QtQml.Models 2.15
import "../components/forTerms"
import "../components/forWholeProject"

Rectangle {
    visible: loaderOfAdditComp_my.item.loaderOfTerms_my.status === Loader.Ready
    property bool termsLoaded: false
    property string touHeader_en
    property string touText_en
    property string ppHeader_en
    property string ppText_en
    property string touHeader_ru
    property string touText_ru
    property string ppHeader_ru
    property string ppText_ru
    property alias listViewForTerms: listViewForTerms
    property alias fnTM: fnTM
    property alias terms_backButton: terms_backButton
    color: "white"
    MouseArea {
        anchors.fill: parent
    }
    Image {
        id: busyIndicatorForTerms
        visible: !termsLoaded
        anchors.centerIn: parent
        width: 50
        height: width
        anchors.verticalCenter: parent.verticalCenter
        source: "qrc:/img/forTerms/busyIndicator.png"
        opacity: 0.4
        NumberAnimation on rotation {
            running: busyIndicatorForTerms.visible
            from: 0
            to: 360
            loops: Animation.Infinite
            duration: 1200
        }
    }
    ListView {
        id: listViewForTerms
        visible: termsLoaded
        anchors.fill: parent
        model: ObjectModel {
            Item {
                width: application.width
                height: children[0].y + children[0].height + children[0].y
                LanguageSwitcher_my {
                    x: 10
                    y: 10
                }
            }
            Rectangle {
                width: application.width
                height: pr.standardClerancesSize
                color: "#d1d1d1"
            }
            TermsElement_my { isThisTermsOrPolicy: true }
            Rectangle {
                width: application.width
                height: pr.standardClerancesSize
                color: "#d1d1d1"
            }
            TermsElement_my { isThisTermsOrPolicy: false }
            Rectangle {
                width: application.width
                height: pr.standardClerancesSize
                color: "#d1d1d1"
            }
            Item {
                width: application.width
                height: pr.upperAndLowerBlocksHeight
            }
        }
        boundsBehavior: ListView.StopAtBounds
    }
    Button_turquoise_my {
        id: terms_backButton
        anchors.bottom: parent.bottom
        width: height
        leftProcessing: true
        onClicked: { loaderOfAdditComp_my.item.loaderOfTerms_my.sourceComponent = undefined }
        Image {
            anchors.centerIn: parent
            width: 22
            height: 22
            source: "qrc:/img/forWholeProject/backArrow.png"
        }
    }
    Connections {
        target: scm
        function onErrorSenderInQml(fromHereOrServer_fq, errorCode1_fq, errorCode2_fq) {
            if(termsLoaded)
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
            }
            loaderOfAdditComp_my.item.loaderOfTerms_my.sourceComponent = undefined
        }
        function onShowWindowWithText(textToShowWindow_en_fq, textForBackButton_en_fq, textToShowWindow_ru_fq, textForBackButton_ru_fq, showOnlyIfLoading_fq) {
            if(showOnlyIfLoading_fq && termsLoaded)
                return
            if(pr.systemLanguage === "ru")
                fn.showTextWindow(textToShowWindow_ru_fq, textForBackButton_ru_fq)
            else
                fn.showTextWindow(textToShowWindow_en_fq, textForBackButton_en_fq)
            loaderOfAdditComp_my.item.loaderOfTerms_my.sourceComponent = undefined
        }
    }
    Connections {
        target: tpp
        function onInstallTouAndPp(touHeader_en_fq, touText_en_fq, ppHeader_en_fq, ppText_en_fq, touHeader_ru_fq, touText_ru_fq, ppHeader_ru_fq, ppText_ru_fq) {
            touHeader_en = touHeader_en_fq
            touText_en = touText_en_fq
            ppHeader_en = ppHeader_en_fq
            ppText_en = ppText_en_fq
            touHeader_ru = touHeader_ru_fq
            touText_ru = touText_ru_fq
            ppHeader_ru = ppHeader_ru_fq
            ppText_ru = ppText_ru_fq
            termsLoaded = true
        }
    }
    Item {
        id: fnTM
        function loaded() {
            scm.checkTheAcceptanceVersion()
        }
    }
}
