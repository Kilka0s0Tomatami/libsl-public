#include "LibSL.h"
#include <iostream>
#include <fstream>

int main() {
    const std::string filePath = "D:/PROjects/libsl-project/examples/badExample.lsl";

    if (LibSL::parseFromFile(filePath)) {
        std::cout << "File parsed successfully!" << std::endl;

        std::cout << "\n=== Parse Tree ===\n";
        std::cout << LibSL::getParseTree() << std::endl;

        std::ofstream outFile("parse_tree.txt");
        if (outFile) {
            outFile << LibSL::getParseTree();
            std::cout << "Parse tree written to parse_tree.txt" << std::endl;
        } else {
            std::cerr << "Failed to open output file" << std::endl;
        }

        return 0;
    } else {
        std::cerr << "Failed to parse file!" << std::endl;
        return 1;
    }
}