QT -= gui

CONFIG += c++17 console
CONFIG -= app_bundle

#INCLUDEPATH += 3rdparty/lualib_jit/include
#DEPENDPATH += 3rdparty/lualib_jit/include
#LIBS += -L"$$PWD\3rdparty\lualib_jit\lib" -llua51

INCLUDEPATH += 3rdparty/lualib/include
LIBS += -L"$$PWD\3rdparty\lualib\lib\Win64_mingw6" -llua5.1

INCLUDEPATH += 3rdparty/sol2/include

#LIBS += -L"$$PWD\3rdparty\lualib\lib\Win64_vc15" -llua5.1
#LIBS += -L"$$PWD\3rdparty\lualib\lib\Win32_vc15" -llua5.1
#LIBS += -L"$$PWD\3rdparty\lualib\lib\Win64_mingw6" -llua5.1
#LIBS += -L"$$PWD\3rdparty\lualib\lib\Win32_mingw6" -llua5.1


DEFINES += QT_DEPRECATED_WARNINGS

#DEFINES    += QT_NO_DEBUG_OUTPUT QT_NO_WARNING_OUTPUT QT_NO_DEBUG_STREAM
#CONFIG      += warn_off


#Copy Lua and XML Files-----------------------------------------------------------------
XML_SRC = $${_PRO_FILE_PWD_}/XMLData
XML_DEST1 = $${OUT_PWD}
XML_DEST2 = $${OUT_PWD}
LUA_SRC  = $${_PRO_FILE_PWD_}/LuaPortroyal/Rules
LUA_DEST1 = $${OUT_PWD}
LUA_DEST2 = $${OUT_PWD}

CONFIG(debug, debug|release) {
    LUA_DEST1 = $${LUA_DEST1}/debug
    XML_DEST1 = $${XML_DEST1}/debug
} else {
    LUA_DEST1 = $${LUA_DEST1}/release
    XML_DEST1 = $${XML_DEST1}/release
}
XML_DEST1  = $${XML_DEST1}/XMLData
XML_DEST2  = $${XML_DEST2}/XMLData
LUA_DEST1  = $${LUA_DEST1}/lua
LUA_DEST2  = $${LUA_DEST2}/lua
XML_SRC   ~= s,/,\\\,g # fix slashes
XML_DEST1 ~= s,/,\\\,g #
XML_DEST2 ~= s,/,\\\,g #
LUA_SRC   ~= s,/,\\\,g #
LUA_DEST1 ~= s,/,\\\,g #
LUA_DEST2 ~= s,/,\\\,g #
QMAKE_POST_LINK += $$QMAKE_COPY_DIR $$XML_SRC $$XML_DEST1 $$escape_expand(\\n\\t)
QMAKE_POST_LINK += $$QMAKE_COPY_DIR $$XML_SRC $$XML_DEST2 $$escape_expand(\\n\\t)
message("[INFO] Will copy $${XML_SRC} to $${XML_DEST1}")
message("[INFO] Will copy $${XML_SRC} to $${XML_DEST2}")
QMAKE_POST_LINK += $$QMAKE_COPY_DIR $$LUA_SRC $$LUA_DEST1 $$escape_expand(\\n\\t)
QMAKE_POST_LINK += $$QMAKE_COPY_DIR $$LUA_SRC $$LUA_DEST2 $$escape_expand(\\n\\t)
message("[INFO] Will copy $${LUA_SRC} to $${LUA_DEST1}")
message("[INFO] Will copy $${LUA_SRC} to $${LUA_DEST2}")
#---------------------------------------------------------------------------------------


SOURCES += \
    LuaPortroyal/host_func_def.cpp \
    LuaPortroyal/lua_portrayal_api.cpp \
    LuaPortroyal/LuaRuleMashine.cpp \
    ObjectDictCatalogue/Builder/xmlbuilder.cpp \
    ObjectDictCatalogue/Controllers/featurecataloguecontroller.cpp \
    ObjectDictCatalogue/Entities/cd_attributevaluetype.cpp \
    ObjectDictCatalogue/Entities/cd_featureusetype.cpp \
    ObjectDictCatalogue/Entities/enumtype.cpp \
    ObjectDictCatalogue/Entities/fc_attributebinding.cpp \
    ObjectDictCatalogue/Entities/fc_complexattribute.cpp \
    ObjectDictCatalogue/Entities/fc_featureassociation.cpp \
    ObjectDictCatalogue/Entities/fc_featurebinding.cpp \
    ObjectDictCatalogue/Entities/fc_featuretype.cpp \
    ObjectDictCatalogue/Entities/fc_informationassociation.cpp \
    ObjectDictCatalogue/Entities/fc_informationbinding.cpp \
    ObjectDictCatalogue/Entities/fc_informationtype.cpp \
    ObjectDictCatalogue/Entities/fc_item.cpp \
    ObjectDictCatalogue/Entities/fc_listedvalue.cpp \
    ObjectDictCatalogue/Entities/fc_role.cpp \
    ObjectDictCatalogue/Entities/fc_roletype.cpp \
    ObjectDictCatalogue/Entities/fc_simpleattribute.cpp \
    ObjectDictCatalogue/Entities/fc_spatialprimitivetype.cpp \
    ObjectMapCatalogue/Builder/xmlparser.cpp \
    ObjectMapCatalogue/Controllers/featurescontroller.cpp \
    ObjectMapCatalogue/Entries/feature.cpp \
    ObjectMapCatalogue/Entries/information.cpp \
    contextparameter.cpp \
    drawing_instructions_controller.cpp \
    main.cpp \
    Geometry/gm_point.cpp \
    Geometry/gm_multipoint.cpp \
    Geometry/gm_curvesegment.cpp \
    Geometry/gm_curve.cpp \
    Geometry/gm_compositecurve.cpp \
    Geometry/gm_surface.cpp \
    Geometry/gm_object.cpp \
    profiler.cpp


HEADERS += \
    LuaPortroyal/host_func_def.h \
    LuaPortroyal/lua_portrayal_api.h \
    LuaPortroyal/LuaRuleMashine.h \
    ObjectDictCatalogue/Builder/xmlbuilder.h \
    ObjectDictCatalogue/Controllers/entitycontroller.h \
    ObjectDictCatalogue/Controllers/featurecataloguecontroller.h \
    ObjectDictCatalogue/DataTypes/datatypes.h \
    ObjectDictCatalogue/Entities/cd_attributevaluetype.h \
    ObjectDictCatalogue/Entities/cd_featureusetype.h \
    ObjectDictCatalogue/Entities/enumtype.h \
    ObjectDictCatalogue/Entities/fc_attribute.h \
    ObjectDictCatalogue/Entities/fc_attributebinding.h \
    ObjectDictCatalogue/Entities/fc_complexattribute.h \
    ObjectDictCatalogue/Entities/fc_featureassociation.h \
    ObjectDictCatalogue/Entities/fc_featurebinding.h \
    ObjectDictCatalogue/Entities/fc_featuretype.h \
    ObjectDictCatalogue/Entities/fc_informationassociation.h \
    ObjectDictCatalogue/Entities/fc_informationbinding.h \
    ObjectDictCatalogue/Entities/fc_informationtype.h \
    ObjectDictCatalogue/Entities/fc_item.h \
    ObjectDictCatalogue/Entities/fc_listedvalue.h \
    ObjectDictCatalogue/Entities/fc_role.h \
    ObjectDictCatalogue/Entities/fc_roletype.h \
    ObjectDictCatalogue/Entities/fc_simpleattribute.h \
    ObjectDictCatalogue/Entities/fc_spatialprimitivetype.h \
    ObjectMapCatalogue/Builder/xmlparser.h \
    ObjectMapCatalogue/Controllers/featurescontroller.h \
    ObjectMapCatalogue/Entries/feature.h \
    ObjectMapCatalogue/Entries/information.h \
    contextparameter.h \
    drawing_instructions_controller.h \
    Geometry/gm_curve.h \
    Geometry/gm_point.h \
    Geometry/gm_multipoint.h \
    Geometry/gm_curvesegment.h \
    Geometry/gm_compositecurve.h \
    Geometry/gm_surface.h \
    Geometry/gm_object.h \
    init.h \
    profiler.h
