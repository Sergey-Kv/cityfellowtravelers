import QtQuick 2.15
import "../components/forWholeProject"
import "../components/forMap"

Item {
    visible: pr.currentPage == 1 || (pr.currentPage == 2 && (loaderOfPage2.status !== Loader.Ready || !loaderOfPage2.item.visible)) || (pr.isDriverMode && pr.currentPage == 5 && (loaderOfPage5.status !== Loader.Ready || !loaderOfPage5.item.visible))
    anchors.fill: parent
    Item {
        id: pr1
        property double page1_bigRects_margin: 20
        property double page1_bigRects_buttons_margin: 10
        property double page1_bigRects_text_x_margin: 17
        property double page1_bigRects_text_y_margin: 17
    }
    Image {
        anchors.centerIn: parent
        width: parent.width * 16 > parent.height * 9 ? parent.width : parent.height * 9 / 16
        height: width * 16 / 9
        source: "qrc:/img/forPage1/road.jpg"
    }
    Rectangle {
        anchors.fill: parent
        color: "black"
        opacity: 0.25
    }
    Item {
        id: page1_drivBigRect
        x: pr1.page1_bigRects_margin
        y: pr1.page1_bigRects_margin
        width: parent.width - (x * 2)
        height: {
            if(parent.height < pr1.page1_bigRects_margin * 3 + pr1.page1_bigRects_buttons_margin * 3 + page1_drivBigRect_button1.height * 3 + page1_drivBigRect_text.height * 2 + pr1.page1_bigRects_text_y_margin * 4)
                return (parent.height - (pr1.page1_bigRects_margin * 3)) / 2 + ((pr1.page1_bigRects_buttons_margin + page1_drivBigRect_button1.height) / 2)
            return Math.max(pr1.page1_bigRects_buttons_margin * 2 + page1_drivBigRect_button1.height * 2 + page1_drivBigRect_text.height + pr1.page1_bigRects_text_y_margin * 2, (parent.height - (pr1.page1_bigRects_margin * 3)) / 2)
        }
        Rectangle {
            anchors.fill: parent
            color: pr.blueMainRectClr
            opacity: 0.9
        }
        Text_standard_my {
            id: page1_drivBigRect_text
            x: pr1.page1_bigRects_text_x_margin
            y: {
                var space = page1_drivBigRect.height - pr1.page1_bigRects_buttons_margin * 2 - page1_drivBigRect_button2.height * 2
                if(space > pr1.page1_bigRects_text_y_margin * 2 + height)
                    return pr1.page1_bigRects_text_y_margin
                else
                    return (space - height) / 2
            }
            text: qsTr("For drivers") //"Для водителей"
            font_pointSize_my: 22
            color: "white"
        }
        Button_turquoise_my {
            id: page1_drivBigRect_button1
            x: pr1.page1_bigRects_buttons_margin
            y: page1_drivBigRect_button2.y - (height + pr1.page1_bigRects_buttons_margin)
            width: parent.width - (x * 2)
            text: qsTr("Plan a trip") //"Запланировать поездку"
            onClicked: {
                pr.isDriverMode = true
                pr.currentPage = 2
            }
        }
        Button_turquoise_my {
            id: page1_drivBigRect_button2
            x: pr1.page1_bigRects_buttons_margin
            y: parent.height - (height + pr1.page1_bigRects_buttons_margin)
            width: page1_drivBigRect_button1.width
            text: qsTr("My trips") //"Мои поездки"
            onClicked: {
                pr.isDriverMode = true
                pr.currentPage = 5
            }
        }
    }
    Item {
        id: page1_passBigRect
        x: page1_drivBigRect.x
        y: page1_drivBigRect.y * 2 + page1_drivBigRect.height
        width: page1_drivBigRect.width
        height: parent.height - (pr1.page1_bigRects_margin * 3) - page1_drivBigRect.height
        Rectangle {
            anchors.fill: parent
            color: pr.greenMainRectClr
            opacity: 0.9
        }
        Text_standard_my {
            id: page1_passBigRect_text
            x: page1_drivBigRect_text.x
            y: page1_drivBigRect_text.y
            text: qsTr("For passengers") //"Для пассажиров"
            font_pointSize_my: 22
            color: "white"
        }
        Button_turquoise_my {
            id: page1_passBigRect_button1
            x: pr1.page1_bigRects_buttons_margin
            y: parent.height - (height + pr1.page1_bigRects_buttons_margin)
            width: page1_drivBigRect_button2.width
            text: qsTr("Search for a driver") //"Искать водителя"
            onClicked: {
                pr.isDriverMode = false
                pr.currentPage = 2
            }
        }
    }
}
