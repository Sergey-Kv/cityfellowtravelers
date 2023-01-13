import QtQuick 2.15
import QtGraphicalEffects 1.15
import "../components/forWholeProject"

Item {
    id: windWithText
    visible: false
    onVisibleChanged: { if(!visible) { contactsText.deselect(); loading = false } }
    property alias text: longText.text
    property alias backButtonText: textForBackButton.text
    property alias contactsText: contactsText.text
    property int indexForDelButton: -1
    property bool loading: false
    property alias backButton: backButton
    anchors.fill: parent
    Rectangle {
        anchors.fill: parent
        color: "black"
        opacity: 0.03
        MouAreaWSCH {
            anchors.fill: parent
            leftProcessing: true
            rightProcessing: true
            onClicked: windWithText.visible = false
        }
    }
    Rectangle {
        anchors.centerIn: parent
        width: Math.min(parent.width - 40, 500)
        height: Math.min(parent.height - 40, 15 + flickableForText.contentHeight + buttonSection.height)
        color: "white"
        layer.enabled: true
        layer.effect: DropShadow {
            color: "gray"
            radius: 6
            samples: 13
        }
        MouseArea {
            anchors.fill: parent
            onClicked: contactsText.deselect()
        }
        Flickable {
            id: flickableForText
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width - 30
            anchors.top: parent.top
            anchors.topMargin: 15
            height: parent.height - 15 - buttonSection.height
            contentHeight: longText.contentHeight + (contactsText.visible ? contactsText.contentHeight : 0)
            boundsBehavior: Flickable.StopAtBounds
            clip: true
            Text_standard_my {
                id: longText
                width: flickableForText.width
                font_pointSize_my: 22
                color: "#737373"
                wrapMode: TextEdit.Wrap
                MouseArea {
                    anchors.fill: parent
                    onClicked: contactsText.deselect()
                }
            }
            TextEdit {
                id: contactsText
                visible: text != ""
                anchors.top: longText.bottom
                width: flickableForText.width
                text: ""

                property double font_pointSize_my
                font.family: "Roboto"
                font.weight: Font.Normal
                font.pointSize: font_pointSize_my * pr.cnvt

                font_pointSize_my: 22
                color: "#737373"
                wrapMode: TextEdit.Wrap
                readOnly: true
                selectByKeyboard: true
                selectByMouse: true
            }
        }
        Item {
            id: buttonSection
            property bool besideOrUnder: (backButton.width + deleteButton.width < width) || (!deleteButton.visible)
            anchors.bottom: parent.bottom
            width: parent.width
            height: 10 + (besideOrUnder ? 0 : deleteButton.height) + backButton.height + 10
            MouseArea {
                id: backButton
                anchors.top: parent.besideOrUnder ? deleteButton.top : deleteButton.bottom
                anchors.right: parent.right
                width: textForBackButton.width + 60
                height: textForBackButton.height + 10
                signal click()
                onClick: windWithText.visible = false
                onClicked: click()
                Text_standard_my {
                    id: textForBackButton
                    anchors.centerIn: parent
                    font_pointSize_my: 22
                    color: "#01abb9"
                }
            }
            MouseArea {
                id: deleteButton
                visible: indexForDelButton != -1
                anchors.top: parent.top
                anchors.topMargin: 10
                anchors.right: parent.right
                anchors.rightMargin: parent.besideOrUnder ? parent.width - width : 0
                width: textForDeleteButton.width + 60
                height: textForDeleteButton.height + 10
                onClicked: {
                    if(!loading) {
                        loading = true
                        scm.deleteATripRequest(tmn.getTripIdOfMyTrip(indexForDelButton), tmn.getDeleteCodeOfMyTrip(indexForDelButton))
                    }
                }
                Text_standard_my {
                    id: textForDeleteButton
                    visible: !loading
                    anchors.centerIn: parent
                    text: qsTr("Delete") //"Удалить"
                    font_pointSize_my: 22
                    color: "#01abb9"
                }
                Image {
                    id: om_busyIndicator_img
                    visible: loading
                    width: height
                    height: parent.height / 3 * 2
                    anchors.centerIn: parent
                    source: "qrc:/img/forWindowWithText/busyIndicator.png"
                    opacity: 0.4
                    NumberAnimation on rotation {
                        running: om_busyIndicator_img.visible
                        from: 0
                        to: 360
                        loops: Animation.Infinite
                        duration: 1200
                    }
                }
            }
        }
    }
}
