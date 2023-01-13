import QtQuick 2.15

Text {
    property double font_pointSize_my
    font.family: "Roboto"
    font.weight: Font.Normal
    font.pointSize: font_pointSize_my * pr.cnvt
}
