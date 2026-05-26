#pragma once

#include <string>
#include <vector>

#include "ComponentState.hpp"
#include "SystemLogger.hpp"
#include "TransactionContext.hpp"

using namespace std;

class Installable {
protected:
string id;
string title;
ComponentState state;
bool mockFail;
int installedParentsCount;
bool isExplicitlyInstalled;
vector<Observer*> observers;
public:
Installable(string id, string title);
virtual ~Installable();
void setState(ComponentState newState);
string getId() const;
string getTitle() const;
ComponentState getState() const;
bool isMockFail() const;
void setMockFail(bool val);
int getInstalledParentsCount() const;
void incParents();
void decParents();
bool getExplicit() const;
void setExplicit(bool val);
void addObserver(Observer* obs);
virtual bool isPackage() const;
virtual bool install(TransactionContext& tx) = 0;
virtual void uninstall() = 0;
virtual void forcePending();
};