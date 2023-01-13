import QtQuick 2.15

Item {
    property bool leftProcessing: false
    property int distFromLeftEdge: 30
    property bool rightProcessing: false
    property int distFromRightEdge: 30
    property alias mouseY: mouseAreaForMouAreaWSCH.mouseY
    signal clicked()
    MouseArea {
        id: mouseAreaForMouAreaWSCH
        anchors.fill: parent
        property int prevMouX
        onPressed: prevMouX = mouseX
        onClicked: {
            if(rightProcessing && parent.width - prevMouX < distFromRightEdge && mouseX < prevMouX - 3)
                return
            if(leftProcessing && prevMouX < distFromLeftEdge && mouseX > prevMouX + 3)
                return
            parent.clicked()
        }
    }
}
