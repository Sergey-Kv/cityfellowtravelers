import QtQuick 2.15

Item {
    width: application.width
    property double sectionDescriptionsFullHeight: children[1].anchors.topMargin + children[1].height
    height: sectionHeading.anchors.topMargin + sectionHeading.height + sectionDescriptionsFullHeight
    property alias sectionHeading: sectionHeading
    OM_sectionHeading_my { id: sectionHeading }
}
