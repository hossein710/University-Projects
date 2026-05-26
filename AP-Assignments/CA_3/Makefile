installer: main.o Module.o Package.o Installable.o InstallationEngine.o SystemLogger.o Utils.o
	g++ -o installer main.o Module.o Package.o Installable.o InstallationEngine.o SystemLogger.o Utils.o

main.o: main.cpp InstallationEngine.hpp
	g++ -c main.cpp

Module.o: Module.cpp Module.hpp Installable.hpp
	g++ -c Module.cpp

Package.o: Package.cpp Package.hpp Installable.hpp
	g++ -c Package.cpp

Installable.o: Installable.cpp Installable.hpp TransactionContext.hpp SystemLogger.hpp ComponentState.hpp
	g++ -c Installable.cpp

InstallationEngine.o: InstallationEngine.cpp InstallationEngine.hpp Installable.hpp utils.hpp Module.hpp Package.hpp
	g++ -c InstallationEngine.cpp

SystemLogger.o: SystemLogger.cpp SystemLogger.hpp Observer.hpp Installable.hpp ComponentState.hpp utils.hpp
	g++ -c SystemLogger.cpp

Utils.o: Utils.cpp Utils.hpp ComponentState.hpp
	g++ -c Utils.cpp

clean:
	rm *.o installer