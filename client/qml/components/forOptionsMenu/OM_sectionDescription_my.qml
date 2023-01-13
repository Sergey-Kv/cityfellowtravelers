import QtQuick 2.15

Flow {
    anchors.top: parent.sectionHeading.bottom
    anchors.topMargin: pr.sectionDescriptionTopMargin
    x: 20
    width: parent.width - x*2
    spacing: pr.sectionDescriptionElementsSpacing
}
