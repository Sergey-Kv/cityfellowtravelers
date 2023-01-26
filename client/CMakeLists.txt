cmake_minimum_required(VERSION 3.14)

project(city_fellow_travelers VERSION 1.00 LANGUAGES CXX)

set(CMAKE_AUTOUIC ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(QT NAMES Qt6 Qt5 REQUIRED COMPONENTS Core Quick LinguistTools Network Positioning)
if(ANDROID)
    find_package(QT NAMES Qt6 Qt5 REQUIRED COMPONENTS AndroidExtras)
endif()
find_package(Qt${QT_VERSION_MAJOR} REQUIRED COMPONENTS Core Quick LinguistTools Network Positioning)
if(ANDROID)
    find_package(Qt${QT_VERSION_MAJOR} REQUIRED COMPONENTS AndroidExtras)
endif()

set(TS_FILES i18n/city_fellow_travelers_en.ts i18n/city_fellow_travelers_ru.ts)

set(PROJECT_SOURCES
    cpp/main.cpp
    cpp/functions.h cpp/functions.cpp
    cpp/routedrawing.h cpp/routedrawing.cpp
    cpp/servercommunicator.h cpp/servercommunicator.cpp
    cpp/tripsmanager.h cpp/tripsmanager.cpp
    cpp/touandppmanager.h cpp/touandppmanager.cpp
    cpp/valuesaver.h cpp/valuesaver.cpp
    cpp/commonDataStructures.h cpp/commonDataStructures.cpp
    qml.qrc
    android/AndroidManifest.xml
    ${TS_FILES}
)

#if(ANDROID)
#    include(/home/sergey/android/android_openssl/CMakeLists.txt)
#endif()

add_subdirectory(lib/Qt-Secret)

if(${QT_VERSION_MAJOR} GREATER_EQUAL 6)
    qt_add_executable(city_fellow_travelers
        MANUAL_FINALIZATION
        ${PROJECT_SOURCES}
    )
    set_property(TARGET city_fellow_travelers APPEND PROPERTY QT_ANDROID_PACKAGE_SOURCE_DIR
                 ${CMAKE_CURRENT_SOURCE_DIR}/android)
    qt_create_translation(QM_FILES ${CMAKE_SOURCE_DIR} ${TS_FILES})
else()
    if(ANDROID)
        add_library(city_fellow_travelers SHARED
            ${PROJECT_SOURCES}
        )
    set(ANDROID_PACKAGE_SOURCE_DIR ${PROJECT_SOURCE_DIR}/android CACHE INTERNAL "")
    else()
        add_executable(city_fellow_travelers
          ${PROJECT_SOURCES}
        )
    endif()

    qt5_create_translation(QM_FILES ${CMAKE_SOURCE_DIR} ${TS_FILES})
endif()

target_link_libraries(city_fellow_travelers
  PRIVATE Qt${QT_VERSION_MAJOR}::Core Qt${QT_VERSION_MAJOR}::Quick Qt${QT_VERSION_MAJOR}::Network Qt${QT_VERSION_MAJOR}::Positioning)
if(ANDROID)
    target_link_libraries(city_fellow_travelers PRIVATE Qt${QT_VERSION_MAJOR}::AndroidExtras)
endif()
target_link_libraries(city_fellow_travelers PUBLIC Qt-Secret)

set_target_properties(city_fellow_travelers PROPERTIES
    MACOSX_BUNDLE_GUI_IDENTIFIER my.example.com
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
)

install(TARGETS city_fellow_travelers
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR})

if(QT_VERSION_MAJOR EQUAL 6)
    qt_import_qml_plugins(city_fellow_travelers)
    qt_finalize_executable(city_fellow_travelers)
endif()
