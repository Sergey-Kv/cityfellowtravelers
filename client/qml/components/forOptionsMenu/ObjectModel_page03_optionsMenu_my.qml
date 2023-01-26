import QtQuick 2.15
import QtQml.Models 2.15
import "../forWholeProject"

ObjectModel {
    property color sectionDescriptionElementClr: pr.page3_optionsMenuClr
    OM_section_my {
        z: 9
        sectionHeading.mainText: qsTr("Departure time") //"Время выезда"
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
        z: 8
        sectionHeading.mainText: qsTr("Empty seats") //"Свободных мест"
        OM_sectionDescription_my {
            OM_spinBox_my { z: 1; text: "4" }
        }
    }
    OM_section_my {
        z: 7
        sectionHeading.mainText: qsTr("Estimated price per trip") //"Ориентировочная цена за поездку"
        OM_sectionDescription_my {
            Row {
                z: 1; spacing: pr.sectionDescriptionElementsSpacing
                OM_textInput_my {
                    z: 2
                    textInput.width: Math.max(Math.min(textInput.contentWidth, parent.parent.width - paddings - parent.spacing - parent.children[1].width - paddings), (parent.children[1].currencyNumber ? 30 : 100))
                    textInput.clip: true
                    textInput.horizontalAlignment: parent.children[1].currencyNumber ? TextInput.AlignHCenter : TextInput.AlignLeft
                    textInput.validator: RegExpValidator { regExp: validatorMode == 1 ? /^[0-9]*$/ : validatorMode == 2 ? /^([0-9]*)|([0-9]+[.]?[0-9]{1,2})$/ : /^.*$/; property int validatorMode: page3_optionsMenu.model.get(2).children[1].children[0].children[1].validatorMode }
                    textInput.inputMethodHints: parent.children[1].currencyNumber ? Qt.ImhDigitsOnly : Qt.ImhNoPredictiveText
                    textInput.maximumLength: parent.children[1].currencyNumber ? 6 : 17
                }
                OM_comboBox_my {
                    z: 1; activeMenuPoint: 0; howMuchFreeSpaceOnTheLeft: x + parent.x
                    comboBoxModel: pr.systemLanguage === "ru" ? model_om_currencies_ru : model_om_currencies_default
                    property int currencyNumber: comboBoxModel.get(activeMenuPoint).currencyNumber
                    property int validatorMode: comboBoxModel.get(activeMenuPoint).validatorMode
                    onValidatorModeChanged: if(validatorMode) if(parseInt(parent.children[0].text)) parent.children[0].text = parseInt(parent.children[0].text); else parent.children[0].text = ""
                    Text_standard_my { anchors.verticalCenter: parent.verticalCenter; x: parent.paddings; text: parent.comboBoxModel.get(parent.activeMenuPoint).mainText; color: sectionDescriptionElementClr; font_pointSize_my: 22 }
                    ListModel {
                        id: model_om_currencies_ru
                        ListElement { currencyNumber: 643; mainText: qsTr("RUB", "mainText"); menuText: qsTr("RUB", "menuText"); validatorMode: 1 } //"руб." //"рубль"
                        ListElement { currencyNumber: 933; mainText: qsTr("BYN", "mainText"); menuText: qsTr("BYN", "menuText"); validatorMode: 2 } //"бел. руб." //"бел. руб."
                        ListElement { currencyNumber: 980; mainText: qsTr("UAH", "mainText"); menuText: qsTr("UAH", "menuText"); validatorMode: 1 } //"грн." //"гривна"
                        ListElement { currencyNumber: 398; mainText: qsTr("KZT", "mainText"); menuText: qsTr("KZT", "menuText"); validatorMode: 1 } //"тенге" //"тенге"
                        ListElement { currencyNumber: 840; mainText: qsTr("$"); menuText: qsTr("dollar"); validatorMode: 2 } // //"доллар"
                        ListElement { currencyNumber: 978; mainText: qsTr("€"); menuText: qsTr("euro"); validatorMode: 2 } // //"евро"
                        ListElement { currencyNumber: 0; mainText: " "; menuText: qsTr("other currency"); validatorMode: 0 } //"другая валюта"
                    }
                    ListModel {
                        id: model_om_currencies_default
                        ListElement { currencyNumber: 840; mainText: qsTr("$"); menuText: qsTr("dollar"); validatorMode: 2 } // //"доллар"
                        ListElement { currencyNumber: 978; mainText: qsTr("€"); menuText: qsTr("euro"); validatorMode: 2 } // //"евро"
                        ListElement { currencyNumber: 643; mainText: qsTr("RUB", "mainText"); menuText: qsTr("RUB", "menuText"); validatorMode: 1 } //"руб." //"рубль"
                        ListElement { currencyNumber: 933; mainText: qsTr("BYN", "mainText"); menuText: qsTr("BYN", "menuText"); validatorMode: 2 } //"бел. руб." //"бел. руб."
                        ListElement { currencyNumber: 980; mainText: qsTr("UAH", "mainText"); menuText: qsTr("UAH", "menuText"); validatorMode: 1 } //"грн." //"гривна"
                        ListElement { currencyNumber: 398; mainText: qsTr("KZT", "mainText"); menuText: qsTr("KZT", "menuText"); validatorMode: 1 } //"тенге" //"тенге"
                        ListElement { currencyNumber: 0; mainText: " "; menuText: qsTr("other currency"); validatorMode: 0 } //"другая валюта"
                    }
                }
            }
        }
    }
    OM_section_my {
        z: 6
        sectionHeading.mainText: qsTr("Comment") //"Комментарий"
        sectionHeading.additionalText: qsTr("not necessary") //"не обязательно"
        OM_sectionDescription_my {
            OM_textEdit_my { z: 1 }
        }
    }
    OM_section_my {
        z: 5
        sectionHeading.mainText: qsTr("Name") //"Имя"
        OM_sectionDescription_my {
            OM_textInput_my { z: 1; textInput.width: Math.min(Math.max(200, textInput.contentWidth), parent.width - paddings*2); textInput.clip: true; textInput.horizontalAlignment: TextInput.AlignLeft; textInput.maximumLength: 25 }
        }
    }
    OM_section_my {
        z: 4
        sectionHeading.mainText: qsTr("Contacts") //"Контакты"
        OM_sectionDescription_my {
            OM_textEdit_my { z: 1; hintText: qsTr("For example:\n+44 73 7756-3482 whatsapp, telegram, call") } //"Например:\n+7 925 283-71-36 пишите в whatsapp, telegram, звоните"
        }
    }
    Item {
        z: 3
        width: page3_optionsMenu.width;
        height: {
            var res = 0;
            for(var i = 0; i < page3_optionsMenu.count; ++i) {
                if(i != page3_optionsMenu.count - 3)
                    res += page3_optionsMenu.itemAtIndex(i).height
            }
            return Math.max(page3_optionsMenu.height - res, 0)
        }
    }
    OM_acceptanceOfTerms_my { z: 2 }
    Item { z: 1; width: page3_optionsMenu.width; height: pr.sectionHeadingTopMargin }
    function hideAllMenus() {
        children[0].children[1].children[0].children[0].isDropdownMenuOpen = false
        children[0].children[1].children[0].children[1].isDropdownMenuOpen = false
        children[0].children[2].children[0].children[1].isDropdownMenuOpen = false
        children[0].children[1].children[1].isDropdownMenuOpen = false
        children[0].children[2].children[1].isDropdownMenuOpen = false
        children[2].children[1].children[0].children[1].isDropdownMenuOpen = false
    }
}
