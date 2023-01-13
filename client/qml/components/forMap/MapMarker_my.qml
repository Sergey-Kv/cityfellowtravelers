import QtQuick 2.15
import "../forWholeProject"

Canvas{
    property bool driversOrPassengers
    property bool aOrB
    property bool isSmall: false
    onDriversOrPassengersChanged: requestPaint()
    onIsSmallChanged: requestPaint()

    width: isSmall ? 25 : 30
    property double legHeight: width * 2/3
    property double legArcRoundingRadius: legHeight/2 + width*4/3

    height: width + legHeight
    onPaint: {
        var headRadius = width / 2;
        var side_a = headRadius + legArcRoundingRadius;
        var side_b = headRadius + legHeight;
        var side_c = legArcRoundingRadius;
        var gamma = Math.acos((Math.pow(side_a, 2) + Math.pow(side_b, 2) - Math.pow(side_c, 2)) / (2 * side_a * side_b))
        var betta = Math.acos((Math.pow(side_c, 2) + Math.pow(side_a, 2) - Math.pow(side_b, 2)) / (2 * side_c * side_a))

        var ctx = getContext("2d");
        ctx.reset();
        ctx.fillStyle = driversOrPassengers ? pr.blueMainRectClr : pr.greenMainRectClr;
        ctx.beginPath();
        ctx.arc(headRadius - side_a * Math.sin(gamma), headRadius + side_a * Math.cos(gamma), legArcRoundingRadius, Math.PI*3/2 + gamma + betta, Math.PI*3/2 + gamma, true);
        ctx.arc(headRadius, headRadius, headRadius, Math.PI/2 + gamma, Math.PI/2 - gamma, false);
        ctx.arc(headRadius + side_a * Math.sin(gamma), headRadius + side_a * Math.cos(gamma), legArcRoundingRadius, Math.PI*3/2 - gamma, Math.PI*3/2 - gamma - betta, true);
        ctx.closePath();
        ctx.fill();
    }
    Text_standard_my {
        width: parent.width
        height: parent.width
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        font_pointSize_my: isSmall ? 18 : 22
        //font.family: "Droid Sans Mono"
        text: aOrB ? qsTr("A") : qsTr("B") //"А" //"Б"
        color: "white"
    }
}
