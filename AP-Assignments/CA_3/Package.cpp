#include "Package.hpp"


Package::Package(string id, string title): Installable(id,title){}


bool Package::isPackage() const { return true; }


void Package::addChild(Installable* child){ children.push_back(child); }


bool Package::hasChild(const string& childId) const{
    for(int i= 0;i<children.size();i++){
        if(children[i]->getId() == childId){
            return true;
        }
    }
    return false;
}


bool Package::install(TransactionContext& tx) {
    if (isMockFail()) {
        setState(ComponentState::FAILED);
        return false;
    }
    if (getState() == ComponentState::INSTALLED)
        return true;

    size_t stateSnap = tx.stateChangedNodes.size();
    size_t countSnap = tx.countIncreasedNodes.size();

    for (Installable* child : children) {
        if (child->getState() == ComponentState::INSTALLED) {
        child->incParents();
        tx.countIncreasedNodes.push_back(child);
        continue;
        }

        if (child->isMockFail()) {
            if (child->getState() != ComponentState::FAILED) {
                child->setState(ComponentState::FAILED);
            }
            while (tx.stateChangedNodes.size() > stateSnap) {
                tx.stateChangedNodes.back()->setState(ComponentState::PENDING);
                tx.stateChangedNodes.pop_back();
            }
            while (tx.countIncreasedNodes.size() > countSnap) {
                tx.countIncreasedNodes.back()->decParents();
                tx.countIncreasedNodes.pop_back();
            }
            setState(ComponentState::FAILED);
            return false;
        }

        bool success = child->install(tx);
        if (!success) {
            while (tx.stateChangedNodes.size() > stateSnap) {
                tx.stateChangedNodes.back()->setState(ComponentState::PENDING);
                tx.stateChangedNodes.pop_back();
            }
            while (tx.countIncreasedNodes.size() > countSnap) {
                tx.countIncreasedNodes.back()->decParents();
                tx.countIncreasedNodes.pop_back();
            }
            setState(ComponentState::FAILED);
            return false;
        }
        child->incParents();
        tx.countIncreasedNodes.push_back(child);
    }

    tx.stateChangedNodes.push_back(this);
    setState(ComponentState::INSTALLED);
    return true;
}


void Package::uninstall() {
    setState(ComponentState::PENDING);
    setExplicit(false);
    setMockFail(false);

    // Uninstall in LIFO order
    for (auto it = children.rbegin(); it != children.rend(); ++it) {
        Installable* child = *it;
        int oldCount = child->getInstalledParentsCount();
        child->decParents();

        if (oldCount == 1 && !child->getExplicit()) {
            child->uninstall();
        }
    }
}