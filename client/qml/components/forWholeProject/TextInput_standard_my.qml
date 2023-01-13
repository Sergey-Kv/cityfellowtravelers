import QtQuick 2.15

TextInput {
    property double font_pointSize_my
    font.family: "Roboto"
    font.weight: Font.Normal
    font.pointSize: font_pointSize_my * pr.cnvt
}
