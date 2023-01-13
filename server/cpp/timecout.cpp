#include "timecout.h"
#include <string>
#include <QDateTime>

static std::string intToTwoCharString(int number) {
    return number < 10 ? "0" + std::to_string(number) : std::to_string(number);
}

static std::string intToThreeCharString(int number) {
    return number < 100 ? number < 10 ? "00" + std::to_string(number) : "0" + std::to_string(number) : std::to_string(number);
}

static std::string getStringWithTime()
{
    QDateTime currDtUtc = QDateTime::currentDateTimeUtc();
    return std::to_string(currDtUtc.date().year()) + "." + intToTwoCharString(currDtUtc.date().month()) + "." + intToTwoCharString(currDtUtc.date().day()) + "_" + intToTwoCharString(currDtUtc.time().hour()) + ":" + intToTwoCharString(currDtUtc.time().minute()) + ":" + intToTwoCharString(currDtUtc.time().second()) + ":" + intToThreeCharString(currDtUtc.time().msec());
}

std::ostream &ticout() {
    return std::cout << getStringWithTime() << " ";
}

std::ostream &ticerr() {
    return std::cerr << getStringWithTime() << "_er ";
}
