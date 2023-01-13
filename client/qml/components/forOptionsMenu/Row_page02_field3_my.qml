import QtQuick 2.15
import QtLocation 5.15

Row {
    property color sectionDescriptionElementClr: pr.page2_fieldsTextClr
    spacing: 12
    OM_comboBox_my {
        visible: pr.page2_activeField == 3
        z: 5
        activeMenuPoint: pr.page2_field3_comboBox_activeMenuPoint
        howMuchFreeSpaceOnTheLeft: x
        isThisPage2Field3: true
        comboBoxModel: ListModel {
            ListElement { imgSource: "qrc:/img/forOptionsMenu/page02_field3_comboBox_networkIcon.png"; menuText: qsTr("download") } //"загрузить"
            ListElement { imgSource: "qrc:/img/forOptionsMenu/page02_field3_comboBox_pencilIcon.png"; menuText: qsTr("draw") } //"нарисовать"
        }
        Image { anchors.verticalCenter: parent.verticalCenter; x: parent.paddings; width: height; height: parent.height - parent.paddings * 2; source: parent.comboBoxModel.get(parent.activeMenuPoint).imgSource }
    }
    OM_busyIndicator_my { visible: pr.page2_activeField == 3 && page2_field3_rect.children[0].children[0].activeMenuPoint == 0 && !pr.areRequiredRoutesLoaded && loaderOfMap_my.status === Loader.Ready && loaderOfMap_my.item.routeModel.status == RouteModel.Loading }
    OM_refreshButton_my { visible: pr.page2_activeField == 3 && page2_field3_rect.children[0].children[0].activeMenuPoint == 0 && !pr.areRequiredRoutesLoaded && loaderOfMap_my.status === Loader.Ready && loaderOfMap_my.item.routeModel.status != RouteModel.Loading }
    OM_routeSwitcher_my { visible: pr.page2_activeField == 3 && page2_field3_rect.children[0].children[0].activeMenuPoint == 0 && pr.areRequiredRoutesLoaded && loaderOfMap_my.status === Loader.Ready && loaderOfMap_my.item.routeModel.savedPathsCount > 1 }
    OM_undoOrRedoButton_my { visible: pr.page2_activeField == 3 && page2_field3_rect.children[0].children[0].activeMenuPoint == 1; undoOrRedo: true; isActive: true }
    OM_undoOrRedoButton_my { visible: pr.page2_activeField == 3 && page2_field3_rect.children[0].children[0].activeMenuPoint == 1 && !pr.isTheRouteFullyDrawn; undoOrRedo: false; isActive: false }
    OM_text_my {
        //id: page2_field3_text
        visible: pr.page2_activeField != 3 || (pr.page2_activeField == 3 && page2_field3_rect.children[0].children[0].activeMenuPoint == 0 && pr.areRequiredRoutesLoaded) || (pr.page2_activeField == 3 && page2_field3_rect.children[0].children[0].activeMenuPoint == 1 && pr.isTheRouteFullyDrawn)
        text: {
            if(pr.page2_activeField == 3 && page2_field3_rect.children[0].children[0].activeMenuPoint == 0 && pr.areRequiredRoutesLoaded) {
                if(loaderOfMap_my.status === Loader.Ready && loaderOfMap_my.item.routeModel.savedPathsCount == 0)
                    return qsTr("not found") //"не найдено"
                else {
                    if(parent.children[3].routeOneOrTwo)
                        return pr.informationAboutRoute1
                    else
                        return pr.informationAboutRoute2
                }
            }
            else if(pr.page2_activeField == 3 && page2_field3_rect.children[0].children[0].activeMenuPoint == 1 && pr.isTheRouteFullyDrawn) {
                return pr.informationAboutDrawnRoute
            }
            else {
                return qsTr("Route") //"Маршрут"
            }
        }
    }
    function hideAllMenus() {
        children[0].isDropdownMenuOpen = false
    }
}
