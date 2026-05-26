#pragma once

#include "Installable.hpp"

// --- Module (Leaf) --
class Module : public Installable {
public:
Module(string id, string title);
bool install(TransactionContext& tx) override;
void uninstall() override;
};