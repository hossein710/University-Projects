#pragma once

#include "Installable.hpp"


// --- Package (Composite) --
class Package : public Installable {
private:
vector<Installable*> children;
public:
Package(string id, string title);
bool isPackage() const override;
void addChild(Installable* child);
bool hasChild(const string& childId) const;
bool install(TransactionContext& tx) override;
void uninstall() override;
};