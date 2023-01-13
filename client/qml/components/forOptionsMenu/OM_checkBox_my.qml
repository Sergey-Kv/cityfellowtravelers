import QtQuick 2.15
import "../forWholeProject"

Item {
    property bool checked: false
    property alias opaci: rectForCheckBox.opacity
    width: 22
    height: width
    Rectangle {
        id: rectForCheckBox
        anchors.fill: parent
        color: checked ? sectionDescriptionElementClr : "white"
        border.width: 2
        border.color: sectionDescriptionElementClr
    }
    Canvas {
        visible: checked
        property double pt: parent.width / 10
        anchors.fill: parent
        onPaint: {
            var ctx = getContext("2d");
            ctx.reset();
            ctx.fillStyle = "white";
            ctx.beginPath();
            ctx.moveTo(8*pt, 2*pt);
            ctx.lineTo(9*pt, 3*pt);
            ctx.lineTo(4*pt, 8*pt);
            ctx.lineTo(1*pt, 5*pt);
            ctx.lineTo(2*pt, 4*pt);
            ctx.lineTo(4*pt, 6*pt);
            ctx.closePath();
            ctx.fill();
        }
    }
    MouAreaWSCH {
        anchors.fill: parent
        anchors.margins: -9
        leftProcessing: true
        distFromLeftEdge: 30 - (20 - 9)
        onClicked: {
            checked = !checked
            forceActiveFocus()
            hideAllMenus()
        }
    }
}
