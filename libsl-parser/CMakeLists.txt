# cmake_minimum_required(VERSION 3.24)
# project(libsl-parser)
# set(LIBSL-PARSER_SOURCE_DIR ${CMAKE_SOURCE_DIR}/libsl-parser)

# add_library(libsl-parser SHARED LibSL.cpp)

cmake_minimum_required(VERSION 3.24)
project(libsl-parser LANGUAGES CXX)

if(CMAKE_CXX_COMPILER_ID MATCHES "Clang" AND WIN32)
    message(STATUS "Using Clang on Windows")
    add_compile_options(-stdlib=libstdc++)
    add_link_options(-stdlib=libstdc++)
endif()



# Настройка ANTLR
set(GRAMMAR_DIR ${CMAKE_CURRENT_SOURCE_DIR}/grammar) # Папка с файлами грамматии
set(RUNTIME_DIR ${CMAKE_CURRENT_SOURCE_DIR}/runtime) # Папка runtime
set(ANTLR_JAR ${CMAKE_CURRENT_SOURCE_DIR}/../libs/antlr-4.13.2-complete.jar)
# Настройка JAVa, необходимая для работы ANTLR_JAR
set(JAVA_EXECUTABLE "C:/Program Files/Java/jdk-17/bin/java.exe")

# Проверки
if(NOT EXISTS "${JAVA_EXECUTABLE}")
    message(FATAL_ERROR "Java not found at: ${JAVA_EXECUTABLE}")
endif()

if(NOT EXISTS "${ANTLR_JAR}")
    message(FATAL_ERROR "ANTLR JAR not found at: ${ANTLR_JAR}")
endif()




# Создание папки для генерации
file(MAKE_DIRECTORY "${GENERATED_DIR}")
set(GENERATED_DIR ${CMAKE_CURRENT_BINARY_DIR}/generated)


# Указываем исходные грамматики
set(GRAMMAR_FILES
        ${GRAMMAR_DIR}/LibSLLexer.g4
        ${GRAMMAR_DIR}/LibSLParser.g4
        )

# Список ожидаемых файлов
set(GENERATED_SOURCES
        ${GENERATED_DIR}/LibSLLexer.cpp
        ${GENERATED_DIR}/LibSLParser.cpp
        ${GENERATED_DIR}/LibSLParserBaseVisitor.cpp
        ${GENERATED_DIR}/LibSLParserVisitor.cpp
        ${GENERATED_DIR}/LibSLParserBaseListener.cpp
        ${GENERATED_DIR}/LibSLParserListener.cpp
        ${GENERATED_DIR}/LibSLLexer.h
        ${GENERATED_DIR}/LibSLParser.h
        )

# Генерация ANTLR
add_custom_command(
        OUTPUT ${GENERATED_SOURCES}
        COMMAND ${JAVA_EXECUTABLE} -jar ${ANTLR_JAR}
        -Werror
        -Dlanguage=Cpp
        -listener -visitor
        -o "${GENERATED_DIR}"
        ${GRAMMAR_FILES}
        DEPENDS ${GRAMMAR_FILES}
        COMMENT "Generating ANTLR parser files"
        VERBATIM
)


# Цель генерации
add_custom_target(GenerateParser DEPENDS ${GENERATED_SOURCES})

# ANTLR runtime
add_subdirectory(${RUNTIME_DIR})
include_directories(${RUNTIME_DIR}/runtime/src)

# Основные файлы
file(GLOB LIBSL_SRC CONFIGURE_DEPENDS
        ${CMAKE_CURRENT_SOURCE_DIR}/LibSL.cpp
        )

add_library(libsl-parser STATIC ${LIBSL_SRC} ${GENERATED_SOURCES})
add_dependencies(libsl-parser GenerateParser)

# Подключаем директории
target_include_directories(libsl-parser PUBLIC
        ${CMAKE_CURRENT_SOURCE_DIR}/include
        ${GENERATED_DIR}
        )

target_link_libraries(libsl-parser PUBLIC antlr4_static)

target_compile_features(libsl-parser PRIVATE cxx_std_20)

if(MSVC)
    target_compile_options(libsl-parser PRIVATE /bigobj /MP /wd4251)
else()
    target_compile_options(libsl-parser PRIVATE -Wno-overloaded-virtual)
endif()
