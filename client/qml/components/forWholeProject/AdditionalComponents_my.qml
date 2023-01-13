import QtQuick 2.15
import QtQuick.Controls 2.15
import "../../windows"

Item {
    property alias loaderOfTerms_my: loaderOfTerms_my
    property alias componentOfTerms_my: componentOfTerms_my
    property alias textWindow: textWindow
    property alias toast: toast
    property alias fnAC: fnAC
    Loader {
        id: loaderOfTerms_my
        anchors.fill: parent
        asynchronous: true
        onLoaded: item.fnTM.loaded()
        Component {
            id: componentOfTerms_my
            Terms_my {}
        }
    }
    WindowWithText_my {
        id: textWindow
    }
    ToolTip {
        id: toast
        timeout: 2000
        x: (parent.width - width) / 2
        y: (parent.height - 56)
        contentItem: Text_standard_my {
            text: toast.text
            color: "#595959"
            font_pointSize_my: textToTakeWidthForToast.font_pointSize_my
            wrapMode: textToTakeWidthForToast.contentWidth > toast.parent.width * 0.9 ? Text.Wrap : Text.NoWrap
            horizontalAlignment: textToTakeWidthForToast.contentWidth > toast.parent.width * 0.9 ? Text.AlignHCenter : Text.AlignLeft
            topPadding: 5
            bottomPadding: 5
            leftPadding: 10
            rightPadding: 10
        }
        background: Rectangle {
            color: "#ebebeb"
            radius: parent.height / 2
            opacity: 0.93
            MouseArea {
                anchors.fill: parent
                onClicked: toast.hide()
            }
        }
        Text_standard_my {
            id: textToTakeWidthForToast
            visible: false
            text: toast.text
            font_pointSize_my: 17
        }
    }
    Connections {
        target: Qt.application
        function onStateChanged(newState) {
            if(newState === Qt.ApplicationInactive)
                fnAC.saveValuesToFile()
        }
    }
    Item {
        id: fnAC
        function saveValuesToFile() {
            forceActiveFocus()
            var depTimeAtOrFromTo
            var emptSeats
            var currNumb
            var name
            var comment
            if(loaderOfPage3.status === Loader.Ready) {
                depTimeAtOrFromTo = loaderOfPage3.item.page3_optionsMenu.model.get(0).children[1].children[0].children[0].activeMenuPoint == 0
                emptSeats = loaderOfPage3.item.page3_optionsMenu.model.get(1).children[1].children[0].text
                currNumb = loaderOfPage3.item.page3_optionsMenu.model.get(2).children[1].children[0].children[1].currencyNumber
                name = loaderOfPage3.item.page3_optionsMenu.model.get(4).children[1].children[0].text
                comment = loaderOfPage3.item.page3_optionsMenu.model.get(5).children[1].children[0].text
            }
            else {
                depTimeAtOrFromTo = pr.page3_departureTimeAtOrFromTo
                emptSeats = pr.page3_emptySeats
                currNumb = pr.page3_currencyNumber
                name = pr.page3_name
                comment = pr.page3_contacts
            }
            var needToDepAtOrFromTo
            var howManPeop
            var seaRad
            if(loaderOfPage4.status === Loader.Ready && loaderOfPage4.item.visible) {
                needToDepAtOrFromTo = loaderOfPage4.item.page4_optionsMenu.model.get(0).children[1].children[0].children[0].activeMenuPoint == 0
                howManPeop = loaderOfPage4.item.page4_optionsMenu.model.get(1).children[1].children[0].text
                seaRad = loaderOfPage4.item.page4_optionsMenu.model.get(2).children[1].children[0].globalValue
            }
            else {
                needToDepAtOrFromTo = pr.page4_needToDepartAtOrFromTo
                howManPeop = pr.page4_howManyPeople
                seaRad = pr.page4_searchRadius
            }
            vsr.saveValues(loaderOfPage2.status === Loader.Ready && loaderOfPage2.item.visible && pr.page2_activeField == 1 ? loaderOfMap_my.item.map.center : pr.savedLocationForMarkerA, loaderOfPage2.status === Loader.Ready && loaderOfPage2.item.visible && pr.page2_activeField != 3 ? loaderOfMap_my.item.map.zoomLevel : pr.savedZoomLevelForFields1And2, pr.page2_field3_comboBox_activeMenuPoint, depTimeAtOrFromTo, emptSeats, currNumb, name, comment, needToDepAtOrFromTo, howManPeop, seaRad, pr.page5_mapHKoef)
        }
    }
}
