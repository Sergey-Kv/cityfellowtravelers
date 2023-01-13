import QtQuick 2.15
import "../forWholeProject"

Item {
    property bool engOrRus: pr.systemLanguage !== "ru"
    property double lrPadding: 7
    property double tbPadding: 6
    width: children[0].width + children[1].width
    height: pr.sectionDescriptionElementHeight
    Item {
        width: lrPadding + children[1].contentWidth + lrPadding
        height: parent.height
        Rectangle {
            visible: engOrRus
            anchors.fill: parent
            color: pr.page2_fieldsTextClr
            opacity: 0.15
        }
        Text_standard_my {
            anchors.fill: parent
            verticalAlignment: Text_standard_my.AlignVCenter
            horizontalAlignment: Text_standard_my.AlignHCenter
            text: qsTr("eng") //"англ"
            font_pointSize_my: height - tbPadding * 2
            color: pr.page2_fieldsTextClr
        }
        MouseArea {
            anchors.fill: parent
            onClicked: { if(!engOrRus) { engOrRus = true } }
        }
    }
    Item {
        width: lrPadding + children[1].contentWidth + lrPadding
        x: parent.children[0].width
        height: parent.height
        Rectangle {
            visible: !engOrRus
            anchors.fill: parent
            color: pr.page2_fieldsTextClr
            opacity: 0.15
        }
        Text_standard_my {
            anchors.fill: parent
            verticalAlignment: Text_standard_my.AlignVCenter
            horizontalAlignment: Text_standard_my.AlignHCenter
            text: qsTr("rus") //"рус"
            font_pointSize_my: height - tbPadding * 2
            color: pr.page2_fieldsTextClr
        }
        MouseArea {
            anchors.fill: parent
            onClicked: { if(engOrRus) { engOrRus = false } }
        }
    }
}
