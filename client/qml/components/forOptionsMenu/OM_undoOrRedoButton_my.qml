import QtQuick 2.15

Item {
    property bool undoOrRedo
    property bool isActive
    width: children[0].width
    height: pr.sectionDescriptionElementHeight
    Image {
        width: 28
        height: 10.8
        anchors.verticalCenter: parent.verticalCenter
        source: undoOrRedo ? (isActive ? "qrc:/img/forOptionsMenu/page02_field3_undo.png" : "qrc:/img/forOptionsMenu/page02_field3_undoNotAct.png") : (isActive ? "qrc:/img/forOptionsMenu/page02_field3_redo.png" : "qrc:/img/forOptionsMenu/page02_field3_redoNotAct.png")
    }
    MouseArea {
        anchors.fill: parent
        onClicked: {
            if(isActive) {
                if(undoOrRedo)
                    rdr.undoButtonPressed(loaderOfMap_my.item.map.zoomLevel, (loaderOfMap_my.item.map.width + loaderOfMap_my.item.map.height) / 2, loaderOfMap_my.item.map.center.latitude)
                else
                    rdr.redoButtonPressed(loaderOfMap_my.item.map.zoomLevel, (loaderOfMap_my.item.map.width + loaderOfMap_my.item.map.height) / 2, loaderOfMap_my.item.map.center.latitude)
                loaderOfMap_my.item.circleForRouteDrawingMode.coordinate = loaderOfMap_my.item.polyLine.path[loaderOfMap_my.item.polyLine.pathLength() - 1]
            }
            hideAllMenus()
        }
    }
}
