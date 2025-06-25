#include "LibSL.h"
#include "LibSLParser.h"
#include "LibSLLexer.h"
#include "antlr4-runtime.h"
#include <fstream>
#include <memory>

using namespace antlr4;

namespace {
    std::unique_ptr<ANTLRInputStream> input;
    std::unique_ptr<LibSLLexer> lexer;
    std::unique_ptr<CommonTokenStream> tokens;
    std::unique_ptr<LibSLParser> parser;
    LibSLParser::FileContext* parseTree = nullptr;
}

bool LibSL::parseFromFile(const std::string& filePath) {
    cleanup(); // Сначала очищаем предыдущий парсер

    std::ifstream file(filePath);
    if (!file) return false;

    std::string content((std::istreambuf_iterator<char>(file)),
                        std::istreambuf_iterator<char>());

    try {
        input = std::make_unique<ANTLRInputStream>(content);
        lexer = std::make_unique<LibSLLexer>(input.get());
        tokens = std::make_unique<CommonTokenStream>(lexer.get());
        parser = std::make_unique<LibSLParser>(tokens.get());

        tokens->fill();
        parseTree = parser->file();
        return true;
    } catch (...) {
        cleanup();
        return false;
    }
}

void LibSL::cleanup() {
    if (parseTree) {
        delete parseTree;
        parseTree = nullptr;
    }
    parser.reset();
    tokens.reset();
    lexer.reset();
    input.reset();
}