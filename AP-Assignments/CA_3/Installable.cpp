#include "Installable.hpp"

Installable::Installable(string id,string title): id(id), title(title){
    mockFail = false;
    state = ComponentState::PENDING;
    installedParentsCount = 0;
    isExplicitlyInstalled = false;
}
Installable::~Installable(){}

void Installable::setState(ComponentState newState) {
    if (state == newState) return;
    ComponentState old = state;
    state = newState;
    for (Observer* obs : observers) {
        obs->onStateChanged(this, old, newState);
    }
}
string Installable::getId() const { return id; }


string Installable::getTitle() const { return title; }

ComponentState Installable::getState() const { return state; }


bool Installable::isMockFail() const{ return mockFail; } 


void Installable::setMockFail(bool val){
    mockFail = val;
}
int Installable::getInstalledParentsCount() const{ return installedParentsCount; }

void Installable::incParents(){ installedParentsCount++; }

void Installable::decParents(){ if(installedParentsCount>0) installedParentsCount--; }

bool Installable::getExplicit() const{ return isExplicitlyInstalled; }

void Installable::setExplicit(bool val){ isExplicitlyInstalled = val; }

void Installable::addObserver(Observer* obs){ observers.push_back(obs); }

bool Installable::isPackage() const { return false; }

void Installable::forcePending() {
    if (state != ComponentState::PENDING) {
        setState(ComponentState::PENDING);
        installedParentsCount = 0;
        isExplicitlyInstalled = false;
        mockFail = false;
    }
}