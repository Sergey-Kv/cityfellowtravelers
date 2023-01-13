import QtQuick 2.15
import "../forWholeProject"

Item {
    property alias termsAccepted: checkBoxForAcceptanceOfTerms.checked
    width: application.width - x * 2
    height: textForAcceptanceOfTerms.y + textForAcceptanceOfTerms.height
    x: 20
    OM_checkBox_my {
        id: checkBoxForAcceptanceOfTerms
        anchors.verticalCenter: textForAcceptanceOfTerms.verticalCenter
        opaci: pr.isDriverMode ? (checked ? 0.8 : 0.8) : (checked ? 0.9 : 0.9)
    }
    Text_standard_my {
        id: textForAcceptanceOfTerms
        property string text_ru: "Я принимаю <font color=\"#00bdad\"><u><a href=\"tou\">Условия использования</a></u></font> и <font color=\"#00bdad\"><u><a href=\"pp\">Политику конфиденциальности</a></u></font>"
        property string text_other: "I accept the <font color=\"#00bdad\"><u><a href=\"tou\">Terms of Use</a></u></font> and <font color=\"#00bdad\"><u><a href=\"pp\">Privacy Policy</a></u></font>"
        x: checkBoxForAcceptanceOfTerms.width + 10
        y: pr.isDriverMode ? 20 : 30
        width: parent.width - x
        text: pr.systemLanguage === "ru" ? text_ru : text_other
        onLinkActivated: {
            if(link == "tou")
                pr.touOrPpOpened = true
            else if(link == "pp")
                pr.touOrPpOpened = false
            forceActiveFocus()
            loaderOfAdditComp_my.item.loaderOfTerms_my.sourceComponent = loaderOfAdditComp_my.item.componentOfTerms_my
            hideAllMenus()
        }
        font_pointSize_my: 16
        color: "#4d4d4d"
        wrapMode: Text_standard_my.Wrap
    }
}
