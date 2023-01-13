import QtQuick 2.15
import QtLocation 5.15
import "../forWholeProject"

Item {
    property bool isDropdownMenuOpen: false
    property int activeMenuPoint
    property double howMuchFreeSpaceOnTheLeft
    property double paddings: 7
    property ListModel comboBoxModel
    property bool isThisPage2Field3: false
    property alias arrowForComboBox: arrowForComboBox
    width: paddings + children[3].width + paddings + children[1].width + paddings
    height: pr.sectionDescriptionElementHeight
    Rectangle {
        anchors.fill: parent
        color: sectionDescriptionElementClr
        opacity: 0.15
        MouseArea {
            anchors.fill: parent
            onClicked: {
                if(isDropdownMenuOpen) {
                    isDropdownMenuOpen = false
                }
                else {
                    hideAllMenus()
                    isDropdownMenuOpen = true
                    forceActiveFocus()
                }
            }
        }
    }
    Canvas {
        id: arrowForComboBox
        anchors.verticalCenter: parent.verticalCenter
        anchors.right: parent.right
        anchors.rightMargin: paddings
        width: 8
        height: width / 2
        onPaint: {
            var ctx = getContext("2d");
            ctx.reset();
            ctx.fillStyle = sectionDescriptionElementClr
            ctx.beginPath();
            ctx.moveTo(0, 0);
            ctx.lineTo(width, 0);
            ctx.lineTo(width / 2, height);
            ctx.closePath();
            ctx.fill();
        }
    }
    Item {
        visible: isDropdownMenuOpen
        anchors.top: parent.bottom
        anchors.right: parent.right
        anchors.rightMargin: howMuchFreeSpaceOnTheLeft + parent.width > width ? 0 : howMuchFreeSpaceOnTheLeft + parent.width - width
        width: pr.comboBoxMenuBorderWidth + paddings + comboBoxView.maxMenuTextWidth + paddings + pr.comboBoxMenuBorderWidth
        height: pr.comboBoxMenuBorderWidth + pr.sectionDescriptionElementHeight*Math.min(comboBoxView.count, 5.5) + pr.comboBoxMenuBorderWidth
        Rectangle {
            anchors.fill: parent
            color: "white"
            Rectangle {
                anchors.fill: parent
                color: sectionDescriptionElementClr
                opacity: 0.3
            }
        }
        ListView {
            id: comboBoxView
            property double maxMenuTextWidth: 0
            anchors.fill: parent
            anchors.margins: pr.comboBoxMenuBorderWidth
            model: comboBoxModel
            boundsBehavior: ListView.StopAtBounds
            clip: true
            delegate: Item {
                width: parent.width
                height: pr.sectionDescriptionElementHeight
                Rectangle {
                    anchors.fill: parent
                    color: "white"
                    opacity: activeMenuPoint == index ? 0.65 : 1.0
                }
                Text_standard_my {
                    id: om_comboBox_menuText
                    x: paddings
                    anchors.verticalCenter: parent.verticalCenter
                    text: menuText
                    color: sectionDescriptionElementClr
                    font_pointSize_my: 22
                    Component.onCompleted: {
                        if(width > comboBoxView.maxMenuTextWidth)
                            comboBoxView.maxMenuTextWidth = width
                    }
                    onTextChanged: {
                        if(width > comboBoxView.maxMenuTextWidth)
                            comboBoxView.maxMenuTextWidth = width
                    }
                }
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        activeMenuPoint = index
                        isDropdownMenuOpen = false
                        if(isThisPage2Field3) {
                            fn2.reinstallThePolyline()
                            fn2.positionTheMap()
                            if(activeMenuPoint == 0 && !pr.areRequiredRoutesLoaded && loaderOfMap_my.item.routeModel.status !== RouteModel.Loading)
                                fn2.downloadRoutes()
                            pr.page2_field3_comboBox_activeMenuPoint = activeMenuPoint
                        }
                    }
                }
            }
        }
    }
}
