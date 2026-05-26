
#include "InstallationEngine.hpp"
#include "Module.hpp"
#include "Package.hpp"

#include <iostream>

Installable* InstallationEngine::getComponent(const string& id){
    for(int i = 0;i<allComponents.size();i++)
        if(allComponents[i]->getId() == id)
            return allComponents[i];

    return nullptr;
}

InstallationEngine::InstallationEngine(){}
InstallationEngine::~InstallationEngine() {
    for (Installable* comp : allComponents) {
        delete comp;
    }
}

void InstallationEngine::processCommand(const string& line) {
    string trimmed = trimLeading(line);
    if (trimmed.empty()) return;
    
    string cmd = getNextToken(trimmed);
    
    if (cmd == "ADD") {
        handleAdd(trimmed);
    } else if (cmd == "ATTACH") {
        handleAttach(trimmed);
    } else if (cmd == "MOCK_FAIL") {
        handleMockFail(trimmed);
    } else if (cmd == "RESOLVE_FAIL") {
        handleResolveFail(trimmed);
    } else if (cmd == "INSTALL") {
        handleInstall(trimmed);
    } else if (cmd == "UNINSTALL") {
        handleUninstall(trimmed);
    } else if (cmd == "END") {
        return;
    } else {
        cout << "ERROR: Invalid command" << endl;
    }
}



void InstallationEngine::handleAdd(const string& args) {
    string line = args;
    string type = getNextToken(line);
    string id = getNextToken(line);
    string title = trimLeading(line);
    
    if (type.empty() || id.empty()) {
        cout << "ERROR: Invalid command" << endl;
        return;
    }
    
    if (getComponent(id) != nullptr) {
        cout << "ERROR: Component with ID " << id << " already exists" << endl;
        return;
    }
    
    if (type == "MODULE") {
        Module* m = new Module(id, title);
        m->addObserver(&logger);
        allComponents.push_back(m);
    } else if (type == "PACKAGE") {
        Package* p = new Package(id, title);
        p->addObserver(&logger);
        allComponents.push_back(p);
    } else {
        cout << "ERROR: Invalid command" << endl;
    }
}

void InstallationEngine::handleAttach(const string& args) {
    string line = args;
    string parentId = getNextToken(line);
    string childId = getNextToken(line);
    
    if (parentId.empty() || childId.empty()) {
        cout << "ERROR: Invalid command" << endl;
        return;
    }
    
    Installable* parent = getComponent(parentId);
    if (!parent) {
        cout << "ERROR: Component " << parentId << " does not exist" << endl;
        return;
    }
    Installable* child = getComponent(childId);
    if (!child) {
        cout << "ERROR: Component " << childId << " does not exist" << endl;
        return;
    }
    
    if (!parent->isPackage()) {
        cout << "ERROR: Cannot attach to a module" << endl;
        return;
    }
    
    Package* pkg = dynamic_cast<Package*>(parent);
    if (pkg->getState() == ComponentState::INSTALLED) {
        cout << "ERROR: Cannot attach to an already installed package" << endl;
        return;
    }
    
    if (pkg->hasChild(childId)) {
        cout << "ERROR: Component " << childId << " is already attached to " << parentId << endl;
        return;
    }
    
    pkg->addChild(child);
}

void InstallationEngine::handleMockFail(const string& args) {
    string line = args;
    string id = getNextToken(line);
    if (id.empty()) {
        cout << "ERROR: Invalid command" << endl;
        return;
    }
    Installable* comp = getComponent(id);
    if (!comp) {
        cout << "ERROR: Component " << id << " does not exist" << endl;
        return;
    }

    if (comp->isMockFail()) {
        cout << "ERROR: Component " << id << " is already set to fail" << endl;
        return;
    }

    if (comp->getState() == ComponentState::INSTALLED) {
        cout << "ERROR: Component " << id << " is already installed" << endl;
        return;
    }
    comp->setMockFail(true);
}

void InstallationEngine::handleResolveFail(const string& args) {
    string line = args;
    string id = getNextToken(line);
    if (id.empty()) {
        cout << "ERROR: Invalid command" << endl;
        return;
    }
    Installable* comp = getComponent(id);
    if (!comp) {
        cout << "ERROR: Component " << id << " does not exist" << endl;
        return;
    }
    if (!comp->isMockFail()) {
        cout << "ERROR: Component " << id << " is not in a mock fail state" << endl;
        return;
    }
    comp->setMockFail(false);
}

void InstallationEngine::handleInstall(const string& args) {
    string line = args;
    string id = getNextToken(line);
    if (id.empty()) {
        cout << "ERROR: Invalid command" << endl;
        return;
    }
    Installable* comp = getComponent(id);
    if (!comp) {
        cout << "ERROR: Component " << id << " does not exist" << endl;
        return;
    }
    if (comp->getState() == ComponentState::INSTALLED) {
        cout << "ERROR: Component " << id << " is already installed" << endl;
        return;
    }
    
    comp->setExplicit(true);
    TransactionContext tx;
    comp->install(tx);
}

void InstallationEngine::handleUninstall(const string& args) {
    string line = args;
    string arg = getNextToken(line);
    if (arg.empty()) {
        cout << "ERROR: Invalid command" << endl;
        return;
    }
    
    if (arg == "-A") {
        bool anyInstalled = false;
        for (Installable* comp : allComponents) {
            if (comp->getState() != ComponentState::PENDING) {
                anyInstalled = true;
                break;
            }
        }
        if (!anyInstalled) {
            cout << "ERROR: No installed components to uninstall" << endl;
            return;
        }
        for (auto it = allComponents.rbegin(); it != allComponents.rend(); ++it) {
                (*it)->forcePending();
        }
    } else {
        string id = arg;
        Installable* comp = getComponent(id);
        if (!comp) {
            cout << "ERROR: Component " << id << " does not exist" << endl;
            return;
        }
        if (comp->getState() != ComponentState::INSTALLED) {
            cout << "ERROR: Component " << id << " is not currently installed" << endl;
            return;
        }
        if (comp->getInstalledParentsCount() > 0) {
            cout << "ERROR: Component " << id << " is required by another package" << endl;
            return;
        }
        comp->uninstall();
    }
}