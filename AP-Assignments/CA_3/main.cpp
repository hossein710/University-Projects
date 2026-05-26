/*
* ========== Naming Convention Guideline ==========
* Class names: PascalCase
* Function names : camelCase
* Variable names : camelCase
* Constant names : UPPER_SNAKE_CASE
* =================================================
*/


#include <iostream>
#include <string>

#include "InstallationEngine.hpp"

int main() {
    InstallationEngine engine;
    std::string line;

    while (std::getline(std::cin, line)) {
        if (line == "END") {
            break;
        }
        engine.processCommand(line);
    }
    
    return 0;
}