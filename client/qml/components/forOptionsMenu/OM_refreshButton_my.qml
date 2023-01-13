import QtQuick 2.15

Item {
    width: children[1].x + children[1].width
    height: pr.sectionDescriptionElementHeight
    Image {
        width: height
        height: parent.height / 3 * 2
        anchors.verticalCenter: parent.verticalCenter
        source: "qrc:/img/forOptionsMenu/page02_field3_refreshButton.png"
    }
    OM_text_my {
        x: parent.children[0].width + 4
        text: qsTr("refresh") //"обновить"
        color: "#01abb9"
    }
    MouseArea {
        anchors.fill: parent
        onClicked: {
            fn2.downloadRoutes()
            hideAllMenus()
        }
    }
}
