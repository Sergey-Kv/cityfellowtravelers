import QtQuick 2.15
import "../forWholeProject"

Item {
    property bool routeOneOrTwo: true
    property double paddings: 7
    width: children[0].width + children[1].width
    height: pr.sectionDescriptionElementHeight
    Item {
        width: paddings + children[1].contentWidth + paddings
        height: parent.height
        Rectangle {
            visible: routeOneOrTwo
            anchors.fill: parent
            color: sectionDescriptionElementClr
            opacity: 0.15
        }
        Text_standard_my {
            anchors.fill: parent
            verticalAlignment: Text_standard_my.AlignVCenter
            horizontalAlignment: Text_standard_my.AlignHCenter
            text: qsTr("1") //
            font_pointSize_my: height - paddings * 2
            color: sectionDescriptionElementClr
        }
        MouseArea {
            anchors.fill: parent
            onClicked: {
                if(!routeOneOrTwo) {
                    routeOneOrTwo = true
                    fn2.reinstallThePolyline()
                }
                hideAllMenus()
            }
        }
    }
    Item {
        width: paddings + children[1].contentWidth + paddings
        x: parent.children[0].width
        height: parent.height
        Rectangle {
            visible: !routeOneOrTwo
            anchors.fill: parent
            color: sectionDescriptionElementClr
            opacity: 0.15
        }
        Text_standard_my {
            anchors.fill: parent
            verticalAlignment: Text_standard_my.AlignVCenter
            horizontalAlignment: Text_standard_my.AlignHCenter
            text: qsTr("2") //
            font_pointSize_my: height - paddings * 2
            color: sectionDescriptionElementClr
        }
        MouseArea {
            anchors.fill: parent
            onClicked: {
                if(routeOneOrTwo) {
                    routeOneOrTwo = false
                    fn2.reinstallThePolyline()
                }
                hideAllMenus()
            }
        }
    }
}
