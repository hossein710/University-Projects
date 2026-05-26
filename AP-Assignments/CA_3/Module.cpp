#include "Module.hpp"

Module::Module(string id, string title): Installable(id,title){}

bool Module::install(TransactionContext& tx) {
    if (isMockFail()) {
        setState(ComponentState::FAILED);
        return false;
    }
    if (getState() == ComponentState::INSTALLED)
        return true;

    tx.stateChangedNodes.push_back(this);
    setState(ComponentState::INSTALLED);
    return true;
}

void Module::uninstall() {
    setState(ComponentState::PENDING);
    setExplicit(false);
    setMockFail(false);
}