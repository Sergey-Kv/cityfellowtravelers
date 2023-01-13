#include <QCoreApplication>
#include "networkconnector.h"

int main(int argc, char *argv[])
{
    QCoreApplication a(argc, argv);
    NetworkConnector cnctr;
    return a.exec();
}
