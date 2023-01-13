import QtQuick 2.15
import "../forWholeProject"
Flow {
    property string mainText
    property string additionalText: ""
    anchors.top: parent.top
    anchors.topMargin: pr.sectionHeadingTopMargin
    x: 10
    width: parent.width - x*2
    spacing: -6
    Item {
        width: children[0].width - parent.spacing
        height: children[0].height
        Text_standard_my {
            text: parent.parent.mainText + "  "
            font_pointSize_my: 22
            width: additionalText === "" ? parent.parent.width : contentWidth
            wrapMode: Text_standard_my.Wrap
            color: "#4d4d4d"
        }
    }
    Item {
        width: children[0].width
        height: parent.children[0].height
        Text_standard_my {
            anchors.bottom: parent.bottom
            text: parent.parent.additionalText === "" ? "" : "(" + parent.parent.additionalText + ")"
            font_pointSize_my: 17
            color: "#bfbfbf"
        }
    }
}
