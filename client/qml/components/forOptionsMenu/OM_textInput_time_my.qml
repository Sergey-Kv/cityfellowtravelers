import QtQuick 2.15
import "../forWholeProject"

Item {
    property double paddings: 7
    property double amPmComboBoxLeftPadding: 4
    property double rightReserve: is24HourFormat ? 7 : 5
    property bool is24HourFormat: true
    property alias activeMenuPoint: amPmComboBox.activeMenuPoint
    property alias isDropdownMenuOpen: amPmComboBox.isDropdownMenuOpen
    activeMenuPoint: 0
    property alias text: om_textInput_time.text
    property alias font: om_textInput_time.font
    width: paddings + om_textInput_time.width + paddings + (is24HourFormat ? 0 : amPmComboBoxLeftPadding + amPmComboBox.width) + rightReserve
    height: pr.sectionDescriptionElementHeight
    TextInput_standard_my {
        id: om_textInput_time
        z: 3
        anchors.verticalCenter: parent.verticalCenter
        x: paddings
        font.family: "Droid Sans Mono"
        font_pointSize_my: 22
        horizontalAlignment: TextInput.AlignHCenter
        inputMethodHints: Qt.ImhDigitsOnly
        inputMask: "00:00"
        validator: RegExpValidator { regExp: is24HourFormat ? /^([013-9 ][\d ]|[2 ][0-3 ]):[0-5 ][\d ]$/ : /^([02-9 ][\d ]|[1 ][0-1 ]):[0-5 ][\d ]$/ }
        color: sectionDescriptionElementClr
        opacity: pr.textInput_textOpacity

        property int prevCursorPosition
        onCursorPositionChanged: prevCursorPosition = cursorPosition
        onActiveFocusChanged: {
            if(activeFocus) {
                prevCursorPosition = cursorPosition
                hideAllMenus()
            }
            else {
                var part1
                var part2
                var i = text.charAt(0) == ":" ? 0 : (text.charAt(1) == ":" ? 1 : 2)
                if(i === 1) {
                    part1 = "0" + text.charAt(0)
                }
                else {
                    part1 = (i === 0 || parseInt(text.charAt(0)) > 2 ? "  " : text.charAt(0) + text.charAt(1))
                }
                if(text.length - i == 2) {
                    part2 = "0" + text.charAt(1+i)
                }
                else {
                    part2 = (text.length - i == 1 ? "  " : text.charAt(1+i) + text.charAt(2+i))
                }
                text = part1 + ":" + part2
            }
        }
        onTextChanged: {
            if(cursorPosition == 1 && prevCursorPosition == 0 && text.charAt(0) > (is24HourFormat ? 2 : 1)) {
                var textTmp = "0" + text.charAt(0) + ":"
                var i = text.charAt(0) == ":" ? 0 : (text.charAt(1) == ":" ? 1 : 2)
                if(text.length - i == 2)
                    textTmp += " " + text.charAt(i+1)
                else
                    textTmp += text.charAt(i+1) + text.charAt(i+2)
                text = textTmp
                cursorPosition = 3
            }
            prevCursorPosition = cursorPosition
        }
    }
    Rectangle {
        z: 2
        anchors.top: om_textInput_time.bottom
        width: paddings + om_textInput_time.width + paddings
        height: 2
        color: sectionDescriptionElementClr
    }
    OM_comboBox_my {
        id: amPmComboBox
        visible: !is24HourFormat
        z: 1
        x: paddings + om_textInput_time.width + paddings + amPmComboBoxLeftPadding
        howMuchFreeSpaceOnTheLeft: x + parent.x + parent.parent.x
        comboBoxModel: ListModel {
            ListElement { mainText: qsTr("AM"); menuText: qsTr("AM") }
            ListElement { mainText: qsTr("PM"); menuText: qsTr("PM") }
        }
        Text_standard_my { anchors.verticalCenter: parent.verticalCenter; x: parent.paddings; text: parent.comboBoxModel.get(parent.activeMenuPoint).mainText; color: sectionDescriptionElementClr; font_pointSize_my: 22 }
    }
}
