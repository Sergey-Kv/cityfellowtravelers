import QtQuick 2.15
import "../forWholeProject"

Item {
    property alias text: om_text.text
    property alias font: om_text.font
    property alias font_pointSize_my: om_text.font_pointSize_my
    property alias color: om_text.color
    width: om_text.width
    height: pr.sectionDescriptionElementHeight
    Text_standard_my {
        id: om_text
        anchors.verticalCenter: parent.verticalCenter
        font_pointSize_my: 22
        color: sectionDescriptionElementClr
    }
}
