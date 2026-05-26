#pragma once

#include <sstream>
#include "Installable.hpp"
#include "utils.hpp"

// --- Installation Engine --
class InstallationEngine {
private:
    vector<Installable*> allComponents;
    SystemLogger logger;
    Installable* getComponent(const string& id);
    void handleAdd(const string& args);
    void handleAttach(const string& args);
    void handleMockFail(const string& args);
    void handleResolveFail(const string& args);
    void handleInstall(const string& args);
    void handleUninstall(const string& args);
public:
    InstallationEngine();
    ~InstallationEngine();
    void processCommand(const string& line);
};