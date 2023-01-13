import QtQuick 2.15
import "../forWholeProject"

Item {
    height: infoText.height > 45 ? 20 + infoText.height : 65
    anchors.left: parent.left
    anchors.leftMargin: 10
    anchors.right: parent.right
    anchors.rightMargin: 10
    Rectangle {
        anchors.fill: parent
        anchors.topMargin: 5
        anchors.bottomMargin: 5
        color: loaderOfPage5.item.myTripsView.currentIndex == index ? "lemonchiffon" : "white"
    }
    Text_standard_my {
        id: infoText
        anchors.top: parent.top
        anchors.topMargin: 10
        anchors.left: parent.left
        anchors.leftMargin: 5
        anchors.right: parent.right
        anchors.rightMargin: 5
        text: model.text
        font_pointSize_my: 20
        color: "#737373"
        wrapMode: Text_standard_my.Wrap
    }
    MouAreaWSCH {
        id: mouAreaForMyTripsViewElement
        anchors.fill: parent
        leftProcessing: true
        distFromLeftEdge: 30 - 10
        rightProcessing: true
        distFromRightEdge: 30 - 10
        onClicked: {
            if(pr.isDriverMode)
                fn.showTextWindow(model.text + tmn.getTextWithCommentForThisIndexForMyTrips(index), qsTr("Back"), tmn.getContactsTextForThisIndexForMyTrips(index), index) //"Назад"
            else
                fn.showTextWindow(model.text + tmn.getTextWithCommentForThisIndexForFoundTrips(index), qsTr("OK"), tmn.getContactsTextForThisIndexForFoundTrips(index)) //"ОК"
        }
    }
}
