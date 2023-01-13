import QtQuick 2.15

Item {
    width: children[0].width
    height: pr.sectionDescriptionElementHeight
    Image {
        id: om_busyIndicator_img
        width: height
        height: parent.height / 3 * 2
        anchors.verticalCenter: parent.verticalCenter
        source: "qrc:/img/forOptionsMenu/page02_field3_busyIndicator.png"
        opacity: 0.4
        NumberAnimation on rotation {
            running: om_busyIndicator_img.visible
            from: 0
            to: 360
            loops: Animation.Infinite
            duration: 1200
        }
    }
}
