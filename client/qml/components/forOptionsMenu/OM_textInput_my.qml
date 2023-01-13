import QtQuick 2.15
import "../forWholeProject"

Item {
    property double minimumTextInputWidth
    property double paddings: 7
    property alias text: om_textInput.text
    property alias font: om_textInput.font
    property alias textInput: om_textInput
    width: paddings + om_textInput.width + paddings
    height: pr.sectionDescriptionElementHeight
    TextInput_standard_my {
        id: om_textInput
        anchors.verticalCenter: parent.verticalCenter
        x: paddings
        width: Math.max(minimumTextInputWidth, contentWidth)
        font_pointSize_my: 22
        horizontalAlignment: TextInput.AlignHCenter
        color: sectionDescriptionElementClr
        opacity: pr.textInput_textOpacity
        onActiveFocusChanged: { if(activeFocus) { hideAllMenus() } }
    }
    Rectangle {
        anchors.top: om_textInput.bottom
        width: parent.width
        height: 2
        color: sectionDescriptionElementClr
    }
}
