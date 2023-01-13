import QtQuick 2.15
import "../forWholeProject"

Item {
    width: parent.width
    height: 100
    property alias hintText: hint.text
    property alias text: edit.text
    Rectangle {
        anchors.fill: parent
        color: sectionDescriptionElementClr
        opacity: 0.5
    }
    Rectangle {
        anchors.fill: parent
        anchors.margins: 2
        color: "white"
        Flickable {
             id: flick
             anchors.fill: parent
             contentWidth: edit.contentWidth
             contentHeight: edit.contentHeight
             boundsBehavior: Flickable.StopAtBounds
             clip: true
             function ensureVisible(r)
             {
                 if (contentX >= r.x)
                     contentX = r.x;
                 else if (contentX+width <= r.x+r.width)
                     contentX = r.x+r.width-width;
                 if (contentY >= r.y)
                     contentY = r.y;
                 else if (contentY+height <= r.y+r.height)
                     contentY = r.y+r.height-height;
             }
             TextEdit {
                 id: edit
                 width: flick.width
                 height: Math.max(flick.height, contentHeight)
                 focus: true
                 wrapMode: TextEdit.Wrap
                 onCursorRectangleChanged: flick.ensureVisible(cursorRectangle)

                 property double font_pointSize_my
                 font.family: "Roboto"
                 font.weight: Font.Normal
                 font.pointSize: font_pointSize_my * pr.cnvt

                 font_pointSize_my: 22
                 color: sectionDescriptionElementClr
                 opacity: pr.textInput_textOpacity
                 onActiveFocusChanged: { if(activeFocus) { hideAllMenus() } }
                 Text_standard_my {
                     id: hint
                     width: parent.width
                     visible: !parent.text && !parent.activeFocus
                     font_pointSize_my: 22
                     color: "#bfbfbf"
                     wrapMode: Text_standard_my.Wrap
                 }
             }
        }
    }
}
