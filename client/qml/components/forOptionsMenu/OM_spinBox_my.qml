import QtQuick 2.15
import "../forWholeProject"

Item {
    property double spacing: 7
    property int value: 1
    property alias text: om_textInput.text
    width: om_spinBox_minusRect.width + spacing + om_textInput.width + spacing + om_spinBox_plusRect.width
    height: pr.sectionDescriptionElementHeight
    Item {
        id: om_spinBox_minusRect
        width: height
        height: parent.height
        Rectangle {
            anchors.fill: parent
            color: value > 1 ? sectionDescriptionElementClr : pr.spinBoxNotActRectClr
            opacity: 0.15
        }
        Text_standard_my {
            anchors.fill: parent
            verticalAlignment: Text_standard_my.AlignVCenter
            horizontalAlignment: Text_standard_my.AlignHCenter
            text: qsTr("−") //
            font_pointSize_my: 22
            color: value > 1 ? sectionDescriptionElementClr : pr.spinBoxNotActRectClr
        }
        MouseArea {
            anchors.fill: parent
            onClicked: {
                if(value > 1) {
                    value -= 1
                    om_textInput.textInput.text = value
                }
                forceActiveFocus()
                hideAllMenus()
            }
        }
    }
    OM_textInput_my {
        id: om_textInput
        anchors.left: om_spinBox_minusRect.right
        anchors.leftMargin: spacing
        minimumTextInputWidth: 20
        textInput.inputMethodHints: Qt.ImhDigitsOnly
        textInput.validator: RegExpValidator { regExp: /^([1-9]|[1-9]\d|([1]\d\d|[2][0][0]))$/ }
        textInput.onActiveFocusChanged: {
            if(!activeFocus && text == "") { text = "1" }
        }
        textInput.onTextChanged: {
            if(parseInt(text) > 0 && parseInt(text) < 201) {
                value = parseInt(text)
            }
            else if(text == ""){
                value = 1
            }
        }
    }
    Item {
        id: om_spinBox_plusRect
        anchors.left: om_textInput.right
        anchors.leftMargin: spacing
        width: height
        height: parent.height
        Rectangle {
            anchors.fill: parent
            color: value < 200 ? sectionDescriptionElementClr : pr.spinBoxNotActRectClr
            opacity: 0.15
        }
        Text_standard_my {
            anchors.fill: parent
            verticalAlignment: Text_standard_my.AlignVCenter
            horizontalAlignment: Text_standard_my.AlignHCenter
            text: qsTr("+") //
            font_pointSize_my: 22
            color: value < 200 ? sectionDescriptionElementClr : pr.spinBoxNotActRectClr
        }
        MouseArea {
            anchors.fill: parent
            onClicked: {
                if(value < 200) {
                    value += 1
                    om_textInput.textInput.text = value
                }
                forceActiveFocus()
                hideAllMenus()
            }
        }
    }
}
