import QtQuick 2.15
import "../forWholeProject"

Item {
    property double paddings: 7
    property double rightReserve: 7
    property alias text: om_textInput_time.text
    property alias font: om_textInput_time.font
    width: paddings + om_textInput_time.width + paddings + rightReserve
    height: pr.sectionDescriptionElementHeight
    TextInput_standard_my {
        id: om_textInput_time
        anchors.verticalCenter: parent.verticalCenter
        x: paddings
        font.family: "Droid Sans Mono"
        font_pointSize_my: 22
        horizontalAlignment: TextInput.AlignHCenter
        inputMethodHints: Qt.ImhDigitsOnly
        inputMask: "00:00"
        validator: RegExpValidator { regExp: /^([013-9 ][\d ]|[2 ][0-3 ]):[0-5 ][\d ]$/ }
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
            if(cursorPosition == 1 && prevCursorPosition == 0 && text.charAt(0) > 2) {
                var textTmp = "0" + text.charAt(0) + ":"
                var i = text.charAt(0) == ":" ? 0 : (text.charAt(1) == ":" ? 1 : 2)
                if(text.length - i == 2)
                    textTmp += " " + text.charAt(i+1)
                else
                    textTmp += text.charAt(i+1) + text.charAt(i+2)
                text = textTmp
//                text = "0" + text.charAt(0) + ":" + (text.charAt(1) == ":" ? (text.charAt(2) < 6 ? text.charAt(2) + text.charAt(3) : " " + text.charAt(2)) : text.charAt(3) + text.charAt(4))
                cursorPosition = 3
            }
            prevCursorPosition = cursorPosition
        }
    }
    Rectangle {
        anchors.top: om_textInput_time.bottom
        width: parent.width - rightReserve
        height: 2
        color: sectionDescriptionElementClr
    }
}
