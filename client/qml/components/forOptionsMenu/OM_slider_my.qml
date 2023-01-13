import QtQuick 2.15

Item {
    property int globalValue
    property int currentValue
    property int minValue
    property int maxValue
    property double actLineHeight: 2
    property double notActLineHeight: 2
    property double circleDiameter: 16
    property color actLineColor: sectionDescriptionElementClr
    property color notActLineColor: pr.sliderNotActLineClr
    property color circleColor: sectionDescriptionElementClr
    property double offset: (width - circleDiameter) * (currentValue - minValue) / (maxValue - minValue)
    width: parent.width
    height: pr.sectionDescriptionElementHeight
    Rectangle {
        //id: notActLine
        width: parent.width - x * 2
        height: notActLineHeight
        x: (circleDiameter - height) / 2
        anchors.verticalCenter: parent.verticalCenter
        color: notActLineColor
        radius: height / 2
    }
    Rectangle {
        //id: actLine
        width: offset + height
        height: actLineHeight
        x: (circleDiameter - height) / 2
        anchors.verticalCenter: parent.verticalCenter
        color: actLineColor
        radius: height / 2
    }
    Rectangle {
        //id: circleForSlider
        width: circleDiameter
        height: width
        x: offset
        anchors.verticalCenter: parent.verticalCenter
        color: "white"
        radius: height / 2
        Rectangle { anchors.fill: parent; radius: parent.radius; color: circleColor; opacity: 0.9 }
    }
    MouseArea {
        anchors.fill: parent
        onPressed: { calculateCurrentValue(mouseX); hideAllMenus() }
        onPositionChanged: calculateCurrentValue(mouseX)
        function calculateCurrentValue(mouseX) {
            globalValue = Math.max(minValue, Math.min(maxValue, ((mouseX - parent.circleDiameter / 2) * (maxValue - minValue) / (parent.width - parent.circleDiameter)) + minValue))
        }
    }
}
