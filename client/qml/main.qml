import QtQuick 2.15
import QtQuick.Window 2.15
import QtPositioning 5.15
import "components/forWholeProject"
import "pages"
import "windows"

Window {
    width: 360
    height: 640
    visible: true
    title: qsTr("City fellow travelers") //"Попутчики по городу"
    Component.onCompleted: fn.completed()
    Item {
        id: application
        anchors.fill: parent
        focus: true
        Keys.onReturnPressed: fn.returnPressed()
        Keys.onBackPressed: fn.backPressed()
        Item {
            id: pr

            //stored values:
            property var savedLocationForMarkerA
            property double savedZoomLevelForFields1And2
            property int page2_field3_comboBox_activeMenuPoint
            property bool page3_departureTimeAtOrFromTo
            property string page3_emptySeats
            property int page3_currencyNumber
            property string page3_name
            property string page3_contacts
            property bool page4_needToDepartAtOrFromTo
            property string page4_howManyPeople
            property int page4_searchRadius
            property double page5_mapHKoef

            property int currentPage: 1
            property bool isDriverMode
            property double cnvt: Qt.platform.os == "android" ? 1 : 0.7
            property string systemLanguage: Qt.locale().name.substring(0, 2)
            property color blueMainRectClr: "#2536cf"
            property color greenMainRectClr: "#28ca19"
            property double upperAndLowerBlocksHeight: 54
            property double standardClerancesSize: 2

            //for Page2:
            property color page2_fieldsTextClr: "#6b6b6b"
            property int page2_activeField
            property bool page2_isMarkerBSet
            property bool page2_isMarkerBCanBeViewedAfterSetting
            property var savedLocationsForMarkersAAndBOfField3
            property bool areRequiredRoutesLoaded
            property bool isTheRouteFullyDrawn
            property double savedZoomLevelForRouteDrawing: 15
            property string informationAboutRoute1: ""
            property string informationAboutRoute2: ""
            property string informationAboutDrawnRoute: ""
            property double savedMapZoomLevelToReturnFromPage5
            property var savedMapMarkABLocToRetFromP5AndForSeaForADrReq: []

            //for Page3, Page4:
            property color page3_optionsMenuClr: "#0077be"
            property color page4_optionsMenuClr: "#00b056"
            property double sectionHeadingTopMargin: 17
            property double sectionDescriptionTopMargin: 7
            property double sectionDescriptionElementHeight: 30
            property double sectionDescriptionElementsSpacing: sectionDescriptionTopMargin
            property bool page3_waitingForPage5ToLoad: false

            //for Terms_my
            property bool touOrPpOpened

            //for Map_my
            property bool mapPrepared: false

            //for OM_comboBox_my:
            property double comboBoxMenuBorderWidth: standardClerancesSize

            //for OM_textInput_my, OM_textInput_time_my:
            property double textInput_textOpacity: 0.8

            //for OM_spinBox_my:
            property color spinBoxNotActRectClr: "#949494"

            //for OM_slider_my:
            property color sliderNotActLineClr: "#d9d9d9"
        }
        Page01 { id: page1 }
        Loader {
            id: loaderOfPage2
            anchors.fill: parent
            asynchronous: true
            sourceComponent: (pr.currentPage == 2 || pr.currentPage == 3 || pr.currentPage == 4 || (!pr.isDriverMode && pr.currentPage == 5)) && pr.mapPrepared ? componentOfPage2 : undefined
            onLoaded: item.fn2.loaded()
            Component {
                id: componentOfPage2
                Page02 {}
            }
        }
        Loader {
            id: loaderOfPage3
            anchors.fill: parent
            asynchronous: true
            sourceComponent: pr.currentPage == 3 || (pr.currentPage == 5 && pr.page3_waitingForPage5ToLoad) ? componentOfPage3 : undefined
            onLoaded: item.fn3.loaded()
            Component {
                id: componentOfPage3
                Page03 {}
            }
        }
        Loader {
            id: loaderOfPage4
            anchors.fill: parent
            asynchronous: true
            sourceComponent: pr.currentPage == 4 || (pr.currentPage == 5 && !pr.isDriverMode) ? componentOfPage4 : undefined
            onLoaded: item.fn4.loaded()
            Component {
                id: componentOfPage4
                Page04 {}
            }
        }
        Loader {
            id: loaderOfPage5
            anchors.fill: parent
            asynchronous: true
            sourceComponent: pr.currentPage == 5 && pr.mapPrepared ? componentOfPage5 : undefined
            onLoaded: item.fn5.loaded()
            Component {
                id: componentOfPage5
                Page05 {}
            }
        }
        Loader {
            id: loaderOfMap_my
            anchors.fill: parent
            asynchronous: true
            onLoaded: item.fnMM.loaded()
            Component {
                id: componentOfMap_my
                Map_my {}
            }
        }
        Loader {
            id: loaderOfAdditComp_my
            anchors.fill: parent
            asynchronous: true
            Component {
                id: componentOfAdditComp_my
                AdditionalComponents_my {}
            }
        }
        Connections {
            target: vsr
            function onInstallSavedValues(savedLocationForMarkerA_fq, savedZoomLevelForFields1And2_fq, page2_field3_comboBox_activeMenuPoint_fq, page3_departureTimeAtOrFromTo_fq, page3_emptySeats_fq, page3_currencyNumber_fq, page3_name_fq, page3_contacts_fq, page4_needToDepartAtOrFromTo_fq, page4_howManyPeople_fq, page4_searchRadius_fq, page5_mapHKoef_fq) {
                pr.savedLocationForMarkerA = savedLocationForMarkerA_fq
                pr.savedZoomLevelForFields1And2 = savedZoomLevelForFields1And2_fq
                pr.page2_field3_comboBox_activeMenuPoint = page2_field3_comboBox_activeMenuPoint_fq
                pr.page3_departureTimeAtOrFromTo = page3_departureTimeAtOrFromTo_fq
                pr.page3_emptySeats = page3_emptySeats_fq
                pr.page3_currencyNumber = page3_currencyNumber_fq
                pr.page3_name = page3_name_fq
                pr.page3_contacts = page3_contacts_fq
                pr.page4_needToDepartAtOrFromTo = page4_needToDepartAtOrFromTo_fq
                pr.page4_howManyPeople = page4_howManyPeople_fq
                pr.page4_searchRadius = page4_searchRadius_fq
                pr.page5_mapHKoef = page5_mapHKoef_fq
            }
        }
        Item {
            id: fn
            function completed() {
                pr.savedLocationsForMarkersAAndBOfField3 = [0.0, 0.0, 0.0, 0.0]
                vsr.extractStoredValues()
                loaderOfMap_my.sourceComponent = componentOfMap_my
                loaderOfAdditComp_my.sourceComponent = componentOfAdditComp_my
                tmn.loadMyTripsFromFiles()
            }
            function returnPressed() {
                forceActiveFocus()
            }
            function backPressed() {
                if(loaderOfAdditComp_my.status !== Loader.Ready)
                    return
                if(loaderOfAdditComp_my.item.textWindow.visible)
                    loaderOfAdditComp_my.item.textWindow.backButton.click()
                else if(loaderOfAdditComp_my.item.loaderOfTerms_my.status === Loader.Ready)
                    loaderOfAdditComp_my.item.loaderOfTerms_my.item.terms_backButton.clicked()
                else if(loaderOfPage5.status === Loader.Ready && loaderOfPage5.item.visible == true)
                    loaderOfPage5.item.page5_backButton.clicked()
                else if(loaderOfPage4.status === Loader.Ready && loaderOfPage4.item.visible == true)
                    loaderOfPage4.item.page4_backButton.clicked()
                else if(loaderOfPage3.status === Loader.Ready && loaderOfPage3.item.visible == true)
                    loaderOfPage3.item.page3_backButton.clicked()
                else if(loaderOfPage2.status === Loader.Ready && loaderOfPage2.item.visible == true)
                    loaderOfPage2.item.page2_backButton.clicked()
                else if(page1.visible) {
                    loaderOfAdditComp_my.item.fnAC.saveValuesToFile()
                    Qt.quit()
                }
            }
            function showToast(textForShowToast) {
                if(loaderOfAdditComp_my.status === Loader.Ready) {
                    if(loaderOfAdditComp_my.item.toast.visible) {
                        loaderOfAdditComp_my.item.toast.hide()
                        loaderOfAdditComp_my.item.toast.delay = 50
                    }
                    else {
                        loaderOfAdditComp_my.item.toast.delay = 0
                    }
                    loaderOfAdditComp_my.item.toast.show(textForShowToast)
                }
            }
            function showTextWindow(textForShowTextWindow, textForBackButton = "", textForContacts = "", indexForDelButton = -1) {
                if(loaderOfAdditComp_my.status === Loader.Ready) {
                    forceActiveFocus()
                    loaderOfAdditComp_my.item.textWindow.visible = false
                    loaderOfAdditComp_my.item.textWindow.text = textForShowTextWindow
                    loaderOfAdditComp_my.item.textWindow.contactsText = textForContacts
                    loaderOfAdditComp_my.item.textWindow.backButtonText = textForBackButton === "" ? qsTr("OK") : textForBackButton //"ОК"
                    loaderOfAdditComp_my.item.textWindow.indexForDelButton = indexForDelButton
                    loaderOfAdditComp_my.item.textWindow.loading = false
                    loaderOfAdditComp_my.item.textWindow.visible = true
                }
            }
        }
    }
}
