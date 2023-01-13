import QtQuick 2.15
import "../forWholeProject"

Item {
    property bool isThisTermsOrPolicy
    property bool isOpen: isThisTermsOrPolicy ? pr.touOrPpOpened : !pr.touOrPpOpened
    onIsOpenChanged: arrowForTermsElement.requestPaint()
    width: application.width
    height: header.height + (isOpen ? description.height : 0)
    MouAreaWSCH {
        id: header
        width: parent.width
        height: 10 + children[0].height + 10
        leftProcessing: true
        rightProcessing: true
        onClicked: isOpen = !isOpen
        Text_standard_my {
            anchors.centerIn: parent
            width: parent.width - (arrowForTermsElement.anchors.rightMargin + arrowForTermsElement.width + 10) * 2
            text: loaderOfAdditComp_my.item.loaderOfTerms_my.item.listViewForTerms.model.get(0).children[0].engOrRus ? (isThisTermsOrPolicy ? loaderOfAdditComp_my.item.loaderOfTerms_my.item.touHeader_en : loaderOfAdditComp_my.item.loaderOfTerms_my.item.ppHeader_en) : (isThisTermsOrPolicy ? loaderOfAdditComp_my.item.loaderOfTerms_my.item.touHeader_ru : loaderOfAdditComp_my.item.loaderOfTerms_my.item.ppHeader_ru)
            font_pointSize_my: 22
            color: "#383838"
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text_standard_my.Wrap
        }
        Canvas {
            id: arrowForTermsElement
            anchors.verticalCenter: parent.verticalCenter
            anchors.right: parent.right
            anchors.rightMargin: 10
            width: 16
            height: width / 2
            onPaint: {
                var ctx = getContext("2d");
                ctx.reset();
                ctx.fillStyle = pr.page2_fieldsTextClr;
                ctx.beginPath();
                if(isOpen) {
                    ctx.moveTo(width / 2, 0);
                    ctx.lineTo(width, height);
                    ctx.lineTo(0, height);
                }
                else {
                    ctx.moveTo(0, 0);
                    ctx.lineTo(width, 0);
                    ctx.lineTo(width / 2, height);
                }
                ctx.closePath();
                ctx.fill();
            }
        }
    }
    Item {
        id: description
        visible: isOpen
        anchors.top: header.bottom
        width: parent.width
        height: children[0].y + children[0].height + children[0].y
        Text_standard_my {
            x: 10
            y: 10
            width: parent.width - x * 2
            text: loaderOfAdditComp_my.item.loaderOfTerms_my.item.listViewForTerms.model.get(0).children[0].engOrRus ? (isThisTermsOrPolicy ? loaderOfAdditComp_my.item.loaderOfTerms_my.item.touText_en : loaderOfAdditComp_my.item.loaderOfTerms_my.item.ppText_en) : (isThisTermsOrPolicy ? loaderOfAdditComp_my.item.loaderOfTerms_my.item.touText_ru : loaderOfAdditComp_my.item.loaderOfTerms_my.item.ppText_ru)
            font_pointSize_my: 17
            color: "#383838"
            wrapMode: Text_standard_my.Wrap
        }
    }
}
