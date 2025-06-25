#pragma once

#include <string>
#include <memory>

namespace LibSL {
    bool parseFromFile(const std::string& filePath);
    bool parseFromString(const std::string& input);
    std::string getParseTree();
    void cleanup();
}