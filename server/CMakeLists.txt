cmake_minimum_required(VERSION 3.14)

project(city_fellow_travelers_server LANGUAGES CXX)

set(CMAKE_AUTOUIC ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(QT NAMES Qt6 Qt5 REQUIRED COMPONENTS Core Network Sql)
find_package(Qt${QT_VERSION_MAJOR} REQUIRED COMPONENTS Core Network Sql)

add_executable(city_fellow_travelers_server
  cpp/main.cpp
  cpp/datahandler.h cpp/datahandler.cpp
  cpp/networkconnector.h cpp/networkconnector.cpp
  cpp/requestcounttracker.h cpp/requestcounttracker.cpp
  cpp/squaremanager.h cpp/squaremanager.cpp
  cpp/timecout.h cpp/timecout.cpp
  cpp/commonDataStructures.h cpp/commonDataStructures.cpp
)
add_subdirectory(lib/Qt-Secret)
configure_file(bin/termsOfUseAndPrivacyPolicy.bin bin/termsOfUseAndPrivacyPolicy.bin COPYONLY)
configure_file(bin/privateKey.bin bin/privateKey.bin COPYONLY)
configure_file(bin/adminPassword.bin bin/adminPassword.bin COPYONLY)
target_link_libraries(city_fellow_travelers_server Qt${QT_VERSION_MAJOR}::Core Qt${QT_VERSION_MAJOR}::Network Qt${QT_VERSION_MAJOR}::Sql Qt-Secret)

install(TARGETS city_fellow_travelers_server
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR})
