import QtQuick 2.15

Rectangle {
    height: pr.upperAndLowerBlocksHeight
    property alias text: button_turquoise_my_text.text
    property bool active: true
    property bool loading: false
    color: active ? "#01abb9" : "#a9cacc"
    property alias leftProcessing: mouseAreaForButtonTurquoise.leftProcessing
    property alias distFromLeftEdge: mouseAreaForButtonTurquoise.distFromLeftEdge
    property alias rightProcessing: mouseAreaForButtonTurquoise.rightProcessing
    property alias distFromRightEdge: mouseAreaForButtonTurquoise.distFromRightEdge
    signal clicked()
    Text_standard_my {
        id: button_turquoise_my_text
        visible: !loading
        anchors.fill: parent
        anchors.leftMargin: 5
        anchors.rightMargin: 5
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        wrapMode: Text_standard_my.Wrap
        text: ""
        font_pointSize_my: 22
        color: "white"
    }
    Image {
        visible: loading
        anchors.centerIn: parent
        source: "qrc:/img/forWholeProject/busyIndicatorWhite.png"
        height: parent.height * 0.55
        width: height
        opacity: 0.7
        NumberAnimation on rotation {
            id: animForBusyForButton
            running: loading
            from: 0
            to: 360
            loops: Animation.Infinite
            duration: 1200
        }
    }
    MouAreaWSCH {
        id: mouseAreaForButtonTurquoise
        anchors.fill: parent
        onClicked: if(active && !loading) parent.clicked()
    }
}
