import QtQuick 2.15
import QtQml.Models 2.15
import "../forWholeProject"

ObjectModel {
    property color sectionDescriptionElementClr: pr.page4_optionsMenuClr
    OM_section_my {
        z: 6
        sectionHeading.mainText: qsTr("When do you need to depart") //"Когда нужно выезжать"
        sectionDescriptionsFullHeight: children[1].anchors.topMargin + children[1].height + (children[1].children[0].children[0].activeMenuPoint == 1 ? children[2].anchors.topMargin + children[2].height : 0)
        OM_sectionDescription_my {
            z: 2
            Row {
                z: 2; spacing: pr.sectionDescriptionElementsSpacing
                OM_comboBox_my {
                    z: 2; activeMenuPoint: 0; howMuchFreeSpaceOnTheLeft: x + parent.x; comboBoxModel: ListModel {
                        ListElement { mainText: qsTr("at"); menuText: qsTr("at___") } //"в" //"в___"
                        ListElement { mainText: qsTr("from"); menuText: qsTr("from___ to___") } //"с" //"с___ до___"
                    }
                    Text_standard_my { anchors.verticalCenter: parent.verticalCenter; x: parent.paddings; text: parent.comboBoxModel.get(parent.activeMenuPoint).mainText; color: sectionDescriptionElementClr; font_pointSize_my: 22 }
                }
                OM_textInput_time_my { z: 1 }
            }
            OM_comboBox_my {
                z: 1; activeMenuPoint: 0; howMuchFreeSpaceOnTheLeft: x; comboBoxModel: ListModel {
                    ListElement { mainText: qsTr("today"); menuText: qsTr("today"); day: 0; month: 0; year: 0 } //"сегодня" //"сегодня"
                    ListElement { mainText: qsTr("tomorrow"); menuText: qsTr("tomorrow") } //"завтра" //"завтра"
                    ListElement {}
                    ListElement {}
                }
                Text_standard_my { anchors.verticalCenter: parent.verticalCenter; x: parent.paddings; text: parent.comboBoxModel.get(parent.activeMenuPoint).mainText; color: sectionDescriptionElementClr; font_pointSize_my: 22 }
            }
        }
        OM_sectionDescription_my {
            z: 1
            visible: parent.children[1].children[0].children[0].activeMenuPoint == 1
            anchors.top: parent.children[1].bottom
            Row {
                z: 2; spacing: pr.sectionDescriptionElementsSpacing
                OM_text_my { z: 2; text: qsTr("to") } //"до"
                OM_textInput_time_my { z: 1 }
            }
            OM_comboBox_my {
                z: 1; activeMenuPoint: 0; howMuchFreeSpaceOnTheLeft: x; comboBoxModel: ListModel {
                    ListElement { mainText: qsTr("today"); menuText: qsTr("today") } //"сегодня" //"сегодня"
                    ListElement { mainText: qsTr("tomorrow"); menuText: qsTr("tomorrow") } //"завтра" //"завтра"
                    ListElement {}
                    ListElement {}
                }
                Text_standard_my { anchors.verticalCenter: parent.verticalCenter; x: parent.paddings; text: parent.comboBoxModel.get(parent.activeMenuPoint).mainText; color: sectionDescriptionElementClr; font_pointSize_my: 22 }
            }
        }
    }
    OM_section_my {
        z: 5
        sectionHeading.mainText: qsTr("How many people") //"Сколько человек"
        OM_sectionDescription_my {
            OM_spinBox_my { z: 1; text: "1" }
        }
    }
    OM_section_my {
        z: 4
        sectionHeading.mainText: qsTr("Search within radius") //"Искать в радиусе"
        OM_sectionDescription_my {
            OM_slider_my {
                z: 2
                currentValue: 500
                Component.onCompleted: { globalValue = pr.page4_searchRadius; currentValue = pr.page4_searchRadius }
                onGlobalValueChanged: {
                    currentValue = globalValue
                    parent.children[1].children[0].text = globalValue
                }
                minValue: 10
                maxValue: 1000
                width: Math.min(parent.width, circleDiameter + (maxValue - minValue) / 2)
            }
            Row {
                z: 1; spacing: pr.sectionDescriptionElementsSpacing
                OM_textInput_my {
                    z: 2
                    text: pr.page4_searchRadius
                    onTextChanged: {
                        if(parseInt(text)) {
                            parent.parent.children[0].currentValue = Math.max(parent.parent.children[0].minValue, Math.min(parent.parent.children[0].maxValue, parseInt(text)))
                        }
                        else {
                            parent.parent.children[0].currentValue = parent.parent.children[0].minValue
                        }
                    }
                    textInput.onActiveFocusChanged: {
                        if(!textInput.activeFocus) {
                            parent.parent.children[0].globalValue = parent.parent.children[0].currentValue
                            text = parent.parent.children[0].globalValue
                        }
                    }
                    minimumTextInputWidth: 20
                    textInput.validator: RegExpValidator { regExp: /^(1000)|([0-9][0-9]{1,2})$/ }
                    textInput.inputMethodHints: Qt.ImhDigitsOnly
                }
                OM_text_my { z: 1; text: qsTr("m.") } //"м."
            }
        }
    }
    Item {
        z: 3
        width: page4_optionsMenu.width;
        height: {
            var res = 0;
            for(var i = 0; i < page4_optionsMenu.count; ++i) {
                if(i != page4_optionsMenu.count - 3)
                    res += page4_optionsMenu.itemAtIndex(i).height
            }
            return Math.max(page4_optionsMenu.height - res, 0)
        }
    }
    OM_acceptanceOfTerms_my { z: 2 }
    Item { z: 1; width: page4_optionsMenu.width; height: pr.sectionHeadingTopMargin }
    function hideAllMenus() {
        children[0].children[1].children[0].children[0].isDropdownMenuOpen = false
        children[0].children[1].children[0].children[1].isDropdownMenuOpen = false
        children[0].children[2].children[0].children[1].isDropdownMenuOpen = false
        children[0].children[1].children[1].isDropdownMenuOpen = false
        children[0].children[2].children[1].isDropdownMenuOpen = false
    }
}
