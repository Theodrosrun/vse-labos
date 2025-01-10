# Test unitiare

### Remarques

- Les macros `EXPECT_XXX` signalent un échec **sans interrompre** le test en cours.  
- Les macros `ASSERT_XXX` **interrompent** immédiatement le test en cas d’échec.  
- `EXPECT_TRUE(condition)` vérifie qu’une condition booléenne est vraie, sans interrompre le test.  
- `EXPECT_EQ(a, b)` compare les valeurs `a` et `b` et ne provoque pas d’arrêt immédiat si elles différent.  
- L’utilisation de l’une ou l’autre forme (EXPECT ou ASSERT) dépend de votre stratégie de tests : si un échec empêche tout test ultérieur d’avoir du sens, `ASSERT` est plus adapté, sinon `EXPECT` vous permettra de voir davantage de points d’échec potentiels.


```cpp
/************************************************************************************
 * classes_and_tests_example.cpp
 * -----------------------------
 * Exemple où on définit une classe, puis on définit directement les tests associés.
 *
 * Pour compiler (exemple) :
 *    g++ -std=c++17 -pthread classes_and_tests_example.cpp -lgtest -lgtest_main -lgmock -lgmock_main -o run_tests
 * Puis exécutez :
 *    ./run_tests
 ************************************************************************************/

#include <gtest/gtest.h>
#include <gmock/gmock.h>

#include <stdexcept>
#include <thread>
#include <cmath>
#include <fstream>
#include <mutex>
#include <array>

/************************************************************************************
 * 1) MyComponent
 *    - Composant basique pour tests de set/get
 ************************************************************************************/

class MyComponent {
public:
    void setValue(int v) {
        value_ = v;
    }

    int getValue() const {
        return value_;
    }

private:
    int value_ = 0;
};

/*******************************
 * Tests de MyComponent
 *******************************/
TEST(MyComponentTest, BasicSetAndGet) {
    MyComponent comp;
    comp.setValue(10);

    // On n’interrompt pas le test si ça échoue
    EXPECT_EQ(comp.getValue(), 10);

    // Exemple d’EXPECT_TRUE
    EXPECT_TRUE(comp.getValue() == 10) << "La valeur du composant devrait être 10";
}

/************************************************************************************
 * 2) MyArray
 *    - Tableau simple pour tester les accès hors limites, etc.
 ************************************************************************************/

template <typename T, int SIZE>
class MyArray {
public:
    void set(size_t index, T value) {
        if (index >= SIZE || index < 0) {
            throw std::runtime_error("Index out of bounds");
        }
        internalArray_[index] = value;
    }

    T get(size_t index) const {
        if (index >= SIZE || index < 0) {
            throw std::runtime_error("Index out of bounds");
        }
        return internalArray_[index];
    }

    size_t size() const {
        return SIZE;
    }

private:
    std::array<T, SIZE> internalArray_ = {};
};

/*******************************
 * Tests de MyArray
 *******************************/
TEST(MyArrayTest, OutOfBoundsAccess) {
    MyArray<int, 5> arr;
    // OK
    EXPECT_NO_THROW(arr.set(0, 42));
    EXPECT_EQ(arr.get(0), 42);

    // Hors limites
    EXPECT_THROW(arr.get(5), std::runtime_error);
    EXPECT_THROW(arr.set(5, 100), std::runtime_error);
    EXPECT_THROW(arr.set(-1, 100), std::runtime_error);

    // Petite vérification supplémentaire (optionnelle)
    EXPECT_TRUE(arr.size() == 5) << "La taille du tableau devrait être 5";
}

TEST(MyArrayTest, StressTest) {
    constexpr size_t size = 10000;
    MyArray<int, size> bigArr;
    for (size_t i = 0; i < size; i++) {
        // Si ceci échoue, on arrête le test pour éviter trop d’erreurs en cascade
        ASSERT_NO_THROW(bigArr.set(i, static_cast<int>(i * 2)));
    }
    for (size_t i = 0; i < size; i++) {
        // Ici, on n’interrompt pas forcément le test
        EXPECT_EQ(bigArr.get(i), static_cast<int>(i * 2));
    }
}

/************************************************************************************
 * 3) MyClass
 *    - Classe qui doit être initialisée avant usage (test d'usage non-initialisé)
 ************************************************************************************/

class MyClass {
public:
    void init(int value) {
        initialized_ = true;
        value_ = value;
    }

    int getValue() const {
        if (!initialized_) {
            throw std::runtime_error("MyClass not initialized");
        }
        return value_;
    }

private:
    bool initialized_ = false;
    int value_ = 0;
};

/*******************************
 * Tests de MyClass
 *******************************/
TEST(MyClassTest, UninitializedUsage) {
    MyClass obj;
    // Sans init => exception
    ASSERT_THROW(obj.getValue(), std::runtime_error);

    // Après init => OK
    obj.init(123);
    EXPECT_NO_THROW(obj.getValue());
    EXPECT_EQ(obj.getValue(), 123);
}

/************************************************************************************
 * 4) sqrtSafe
 *    - Fonction exemple pour tester les valeurs spéciales (négatives, etc.)
 ************************************************************************************/

double sqrtSafe(double x) {
    if (x < 0.0) {
        throw std::domain_error("Negative value for sqrt");
    }
    return std::sqrt(x);
}

/*******************************
 * Tests de sqrtSafe
 *******************************/
TEST(MathTest, NegativeSqrtThrows) {
    ASSERT_THROW(sqrtSafe(-1.0), std::domain_error);
}

TEST(MathTest, SqrtPositive) {
    // Utilisation de ASSERT_FLOAT_EQ pour comparer des flottants
    ASSERT_FLOAT_EQ(sqrtSafe(4.0), 2.0);
}

/************************************************************************************
 * 5) MyThreadSafeComponent
 *    - Composant simplifié thread-safe pour tester l'accès concurrent
 ************************************************************************************/

class MyThreadSafeComponent {
public:
    MyThreadSafeComponent() : counter_(0) {}

    void increment() {
        std::lock_guard<std::mutex> lock(mutex_);
        ++counter_;
    }

    int getValue() const {
        std::lock_guard<std::mutex> lock(mutex_);
        return counter_;
    }

private:
    mutable std::mutex mutex_;
    int counter_;
};

/*******************************
 * Tests de MyThreadSafeComponent
 *******************************/
TEST(MyThreadSafeComponentTest, ConcurrentAccess) {
    MyThreadSafeComponent comp;

    auto threadFunc = [&comp]() {
        for (int i = 0; i < 1000; i++) {
            comp.increment();
        }
    };

    std::thread t1(threadFunc);
    std::thread t2(threadFunc);

    t1.join();
    t2.join();

    // 2 threads * 1000
    ASSERT_EQ(comp.getValue(), 2000);
}

/************************************************************************************
 * 6) processData
 *    - Fonction pour tester le passage de pointeur null (nullptr)
 ************************************************************************************/

int processData(int* data) {
    if (!data) {
        throw std::runtime_error("Null pointer passed to processData");
    }
    return *data + 10;
}

/*******************************
 * Tests de processData
 *******************************/
TEST(ProcessDataTest, NullPointer) {
    // Pointeur nul => exception
    EXPECT_THROW(processData(nullptr), std::runtime_error);

    // Pointeur valide => OK
    int value = 10;
    ASSERT_NO_THROW(processData(&value));
    EXPECT_EQ(processData(&value), 20);
}

/************************************************************************************
 * 7) loadDataFromFile
 *    - Fonction pour tester l'accès fichier (fichier inexistant, etc.)
 ************************************************************************************/

bool loadDataFromFile(const std::string& filename) {
    std::ifstream file(filename);
    if (!file.is_open()) {
        return false;
    }
    // On simule un chargement...
    return true;
}

/*******************************
 * Tests de loadDataFromFile
 *******************************/
TEST(FileLoaderTest, NonExistentFile) {
    // On teste que la fonction retourne false pour un fichier inexistant
    EXPECT_TRUE(!loadDataFromFile("fichier_inexistant.xyz"));
}

TEST(FileLoaderTest, ExistingFile) {
    // On crée un fichier test
    std::string filename = "testfile.txt";
    {
        std::ofstream ofs(filename);
        ofs << "Hello world";
    }
    // On attend true car le fichier existe
    EXPECT_TRUE(loadDataFromFile(filename));

    // Nettoyage du fichier
    remove(filename.c_str());
}

/************************************************************************************
 * 8) ComplexSetup
 *    - Classe nécessitant un paramètre avant l'initialisation
 ************************************************************************************/

class ComplexSetup {
public:
    void setParam(int x) {
        x_ = x;
    }

    void initialize() {
        if (x_ == -1) {
            throw std::runtime_error("Param x not set before initialization");
        }
        initialized_ = true;
    }

    int computeResult() {
        if (!initialized_) {
            throw std::runtime_error("Not initialized before computeResult");
        }
        return x_ * 2;
    }

private:
    int x_ = -1;
    bool initialized_ = false;
};

/*******************************
 * Tests de ComplexSetup
 *******************************/
TEST(ComplexSetupTest, MissingSetup) {
    ComplexSetup obj;
    // Pas de setParam => x_ = -1 => exception
    EXPECT_THROW(obj.initialize(), std::runtime_error);
    EXPECT_THROW(obj.computeResult(), std::runtime_error);

    // On fournit le paramètre
    obj.setParam(5);
    ASSERT_NO_THROW(obj.initialize());
    EXPECT_EQ(obj.computeResult(), 10);
}

/************************************************************************************
 * 9) IDatabase + MockDatabase
 *    - Interface et mock pour tester les dépendances externes
 ************************************************************************************/

class IDatabase {
public:
    virtual ~IDatabase() = default;
    virtual int getData() const = 0;
};

class MockDatabase : public IDatabase {
public:
    MOCK_CONST_METHOD0(getData, int());
};

/************************************************************************************
 * 10) MyService
 *     - Dépend d'IDatabase (testable via Mock)
 ************************************************************************************/

class MyService {
public:
    MyService(IDatabase* db) : db_(db) {}

    int process() {
        if (!db_) {
            throw std::runtime_error("No database provided");
        }
        int val = db_->getData();
        return val * 2;  
    }

private:
    IDatabase* db_;
};

/*******************************
 * Tests de MyService + MockDatabase
 *******************************/
using ::testing::Return;
using ::testing::Throw;

TEST(MyServiceTest, HandleDatabaseOk) {
    MockDatabase db;
    EXPECT_CALL(db, getData())
        .WillOnce(Return(21));

    MyService service(&db);
    // On utilise EXPECT_EQ pour comparer
    EXPECT_EQ(service.process(), 42);
}

TEST(MyServiceTest, HandleDatabaseError) {
    MockDatabase db;
    EXPECT_CALL(db, getData())
        .WillRepeatedly(Throw(std::runtime_error("DB error")));

    MyService service(&db);
    ASSERT_THROW(service.process(), std::runtime_error);
}

TEST(MyServiceTest, NoDatabaseProvided) {
    MyService service(nullptr);
    ASSERT_THROW(service.process(), std::runtime_error);
}

/************************************************************************************
 * main() - Point d'entrée des tests
 ************************************************************************************/
int main(int argc, char** argv) {
    ::testing::InitGoogleTest(&argc, argv);
    ::testing::InitGoogleMock(&argc, argv);
    return RUN_ALL_TESTS();
}
```

<br><br><br>


Le problème que le **mocking** vise à résoudre est celui du **dépendances** dans les tests unitaires. Voici une explication détaillée et les avantages du mocking dans l'exemple donné.

## **Problème avec les dépendances**

Quand une classe **C1** dépend d'une autre classe **C2**, pour tester **C1**, vous devez :
1. Avoir une implémentation de **C2**.
2. Être sûr que **C2** fonctionne correctement.
3. Tester **C1** indépendamment des comportements de **C2**, mais cela est difficile si **C2** est directement utilisée par **C1**.

---

### Exemple concret (Classe `Driver` et `Car`)

Dans votre exemple, la classe `Driver` dépend de la classe abstraite `Car` :

```cpp
class Driver {
public:
    void setCar(Car* car) { this->car = car; }
    void drive() {
        car->accelerate(1);
        car->forward();
        car->accelerate(2);
        car->forward();
        car->turnRight();
        car->accelerate(2);
        int speed = car->currentSpeed();
        if (speed > 4) {
            car->brake();
        }
    }

private:
    Car* car; // Dépendance directe à Car
};
```

La méthode `Driver::drive()` appelle plusieurs fonctions de la classe `Car` (comme `accelerate`, `forward`, etc.), ce qui rend difficile de tester `Driver` sans une implémentation complète et fonctionnelle de `Car`.

---

## **Solution avec le mocking**

Un **mock** est une classe qui simule le comportement de `Car`. Elle permet de :
1. **Contrôler les retours des fonctions** comme `currentSpeed()` (ex. : forcer un retour précis pour un test).
2. **Observer les appels faits par `Driver`** (compter le nombre d'appels à `accelerate` ou `brake`).
3. Tester le comportement de `Driver` **sans avoir besoin d'une implémentation réelle de `Car`**.

La classe `MockCar` est un exemple de mock utilisant une bibliothèque de mocking comme **Google Mock** :

```cpp
class MockCar : public Car {
public:
    MOCK_METHOD(void, forward, (), (override));
    MOCK_METHOD(void, accelerate, (int acceleration), (override));
    MOCK_METHOD(void, turnRight, (), (override));
    MOCK_METHOD(int, currentSpeed, (), (const, override));
    MOCK_METHOD(void, brake, (), (override));
};
```

---

## **Exemple de test**

Voici un test pour `Driver::drive()` :

```cpp
TEST(DriverTest, CanDrive) {
    auto* car = new MockCar(); // Création d'un mock pour Car

    EXPECT_CALL(*car, forward())   // Vérifier que forward() est appelé
        .Times(AtLeast(2));        // ... au moins 2 fois
    EXPECT_CALL(*car, currentSpeed()) 
        .WillOnce(Return(5));      // currentSpeed() retourne 5
    EXPECT_CALL(*car, brake())     // Vérifier que brake() est appelé
        .Times(1);                 // ... exactement 1 fois

    Driver driver;
    driver.setCar(car);            // Injecter le mock dans Driver
    driver.drive();                // Appeler la méthode à tester

    delete car; // Nettoyage
}
```

---

### **Explication du test**

1. **Injection du mock dans `Driver` :**
   - Au lieu d'une implémentation réelle de `Car`, on injecte un `MockCar` dans `Driver`.

2. **Attentes (`EXPECT_CALL`) :**
   - **`EXPECT_CALL(*car, forward())`** : On s'attend à ce que la méthode `forward()` soit appelée au moins deux fois.
   - **`EXPECT_CALL(*car, currentSpeed())`** : On force le retour de `currentSpeed()` à `5`.
   - **`EXPECT_CALL(*car, brake())`** : On vérifie que `brake()` est appelé exactement une fois si la vitesse dépasse 4.

3. **Exécution :**
   - On appelle `driver.drive()`, et les attentes définies dans `EXPECT_CALL` sont vérifiées pendant l'exécution.

4. **Validation du comportement :**
   - Si `Driver::drive()` n'appelle pas les méthodes de `Car` comme attendu, le test échoue.

---

## **Avantages du mocking**

1. **Indépendance :** On peut tester `Driver` sans dépendre d'une implémentation réelle de `Car`.
2. **Flexibilité :** On peut simuler des comportements précis de `Car`, comme une vitesse ou un état spécifique.
3. **Observation :** On peut compter combien de fois une méthode est appelée ou vérifier les arguments passés.

---

## **Conclusion**

Le mocking est utile pour tester une classe (comme `Driver`) **indépendamment des implémentations réelles** des classes qu'elle utilise (comme `Car`). Cela facilite le développement piloté par les tests (TDD) et garantit une séparation claire des responsabilités entre les classes.

### Remarques

- Les macros `EXPECT_XXX` signalent un échec **sans interrompre** le test en cours.  
- Les macros `ASSERT_XXX` **interrompent** immédiatement le test en cas d’échec.  
- `EXPECT_TRUE(condition)` vérifie qu’une condition booléenne est vraie, sans interrompre le test.  
- `EXPECT_EQ(a, b)` compare les valeurs `a` et `b` et ne provoque pas d’arrêt immédiat si elles différent.  
- L’utilisation de l’une ou l’autre forme (EXPECT ou ASSERT) dépend de votre stratégie de tests : si un échec empêche tout test ultérieur d’avoir du sens, `ASSERT` est plus adapté, sinon `EXPECT` vous permettra de voir davantage de points d’échec potentiels.

Oui, **les `EXPECT_CALL` doivent être déclarés avant d'exécuter le code à tester**, c'est une règle fondamentale dans l'utilisation de frameworks de mocking comme **Google Mock**. Voici pourquoi :

---

## **Pourquoi déclarer `EXPECT_CALL` avant ?**

1. **Configuration des attentes :**
   - Les `EXPECT_CALL` définissent ce que le mock doit observer ou retourner.
   - Ces attentes doivent être configurées **avant** que le code testé (comme `driver.drive()`) soit exécuté. Sinon, le mock ne saura pas quoi surveiller.

2. **Injection de comportements :**
   - Si une méthode mockée doit retourner une valeur spécifique (par exemple, `currentSpeed()` retourne `5`), cela doit être configuré **avant** l'appel de la méthode.
   - Exemple : `EXPECT_CALL(*car, currentSpeed()).WillOnce(Return(5));`.

3. **Vérification après l'exécution :**
   - Les attentes définies dans `EXPECT_CALL` sont vérifiées **après** l'exécution du code testé.
   - Si les méthodes attendues ne sont pas appelées comme spécifié, le test échoue.

---

## **Exemple de séquence correcte**

Voici la séquence correcte dans un test utilisant Google Mock :

1. Créez et configurez votre mock (`MockCar`).
2. Déclarez les attentes avec `EXPECT_CALL`.
3. Exécutez la méthode à tester (`driver.drive()`).
4. Validez que les attentes ont été respectées (Google Mock le fait automatiquement).

### Code correct :

```cpp
TEST(DriverTest, CanDrive) {
    // Étape 1 : Créez un mock
    auto* car = new MockCar();

    // Étape 2 : Configurez les attentes
    EXPECT_CALL(*car, forward())
        .Times(AtLeast(2)); // forward() doit être appelé au moins 2 fois
    EXPECT_CALL(*car, currentSpeed())
        .WillOnce(Return(5)); // currentSpeed() retourne 5 à son premier appel
    EXPECT_CALL(*car, brake())
        .Times(1); // brake() doit être appelé exactement 1 fois

    // Étape 3 : Exécutez le code testé
    Driver driver;
    driver.setCar(car); // Injectez le mock
    driver.drive();     // Appeler la méthode à tester

    // Étape 4 : Nettoyez (si besoin)
    delete car;
}
```

## **Conclusion**

Toujours **déclarer les `EXPECT_CALL` avant d'exécuter le code** à tester. Cela garantit que :
1. Les comportements simulés (comme les retours de méthode) sont correctement injectés.
2. Les appels et paramètres sont surveillés pendant l'exécution.
3. Les validations (`Times`, `WillOnce`, etc.) peuvent être vérifiées après coup.

<br><br><br><br><br><br><br><br><br><br>

# Invariants

**LAMBDA_INVARIANT**

- **But** : Permet de vérifier des invariants complexes ou dépendant de l'état courant en utilisant des lambdas.
- **Fonctionnement :**
  - Un lambda est exécuté, et son résultat est vérifié.
  - Si le lambda retourne `false`, une exception est levée avec un message d'erreur.

**Exemple** :

```cpp
LAMBDA_INVARIANT(
    { return (value % 2 == 0); },
    "Value must be even"
);
```

### **Différences principales entre méthodes**

| Méthode/Directive       | Quand s'applique-t-elle ?               | Active en mode DEBUG ? | Levée d'exception ? |
|--------------------------|-----------------------------------------|-------------------------|---------------------|
| `PRE_CONDITION`         | Avant une exécution                    | Oui                     | Oui                 |
| `POST_CONDITION`        | Après une exécution                    | Oui                     | Oui                 |
| `INVARIANT`             | Tout moment de l'existence d'un objet  | Oui                     | Oui                 |
| `CHECKINVARIANTS`       | Vérification explicite des invariants  | Oui                     | Oui                 |
| `EMPTYINVARIANTS`       | Fournit un `checkInvariants` trivial   | Oui                     | Non (retourne `true`) |



```cpp
#ifndef SYNTAXTREE_H
#define SYNTAXTREE_H

#include <cmath>
#include <memory>

#include "contract.h"

class Factor {
public:
    virtual double evaluate() = 0;

    EMPTYINVARIANTS
};

class BinaryExpression : public Factor {
public:
    enum class operation_t {
        Addition = 0,
        Subtraction,
        Multiplication,
        Division
    };

    void setOperation(operation_t operation) {
        this->operation = operation;
    }

    void setLeft(std::unique_ptr<Factor> node) {
        left = std::move(node);
    }

    void setRight(std::unique_ptr<Factor> node) {
        right = std::move(node);
    }

    INVARIANTS_OVERRIDE(
        INVARIANT((left != nullptr), "The left side of a binary expression shall not be nullptr");
        INVARIANT((right != nullptr), "The right side of a binary expression shall not be nullptr");
        LAMBDA_INVARIANT({if (left == nullptr) { return false;}return left->checkInvariants();}, "Invalid left child");
        LAMBDA_INVARIANT({if (right == nullptr) { return false;}return right->checkInvariants();}, "Invalid right child");
        )

    double evaluate() override {
        // Actually we should check NAN as well
        CHECKINVARIANTS;
        PRE_CONDITION((!std::isnan(left->evaluate())), "The left side of a binary operation shall not be NAN");
        PRE_CONDITION((!std::isnan(right->evaluate())), "The right side of a binary operation shall not be NAN");
        PRE_CONDITION((operation != operation_t::Division || (right->evaluate() != 0.0)), "The right side of a division shall not be 0");
        switch (operation) {
        case operation_t::Addition : return left->evaluate() + right->evaluate();
        case operation_t::Subtraction : return left->evaluate() - right->evaluate();
        case operation_t::Multiplication : return left->evaluate() * right->evaluate();
        case operation_t::Division : return left->evaluate() / right->evaluate();
        default : return 0.0;
        }
    }
private:
     operation_t operation;

     // Could be interesting to see what happens without the nullptr here
    std::unique_ptr<Factor> left{nullptr};
    std::unique_ptr<Factor> right{nullptr};
};

class UnaryExpression : public Factor {
public:
    enum class operation_t {
        Subtraction = 0
    };

    INVARIANTS_OVERRIDE(
        INVARIANT((child != nullptr), "The child node of a binary expression shall not be nullptr");
        LAMBDA_INVARIANT({if (child == nullptr) { return false;}return child->checkInvariants();}, "Invalid child");
        )

    void setChild(std::unique_ptr<Factor> node) {
        child = std::move(node);
    }

    double evaluate() override {
        CHECKINVARIANTS;
        switch (operation) {
        case operation_t::Subtraction : return -child->evaluate();
        default : return 0.0;
        }
    }
private:
    operation_t operation;

    std::unique_ptr<Factor> child;
};


class Number : public Factor {
public:
    Number(double value) : value(value){ }
    Number() {}

    INVARIANTS_OVERRIDE(
        INVARIANT((!std::isnan(value)), "A number shall not be NAN");
        )

    double evaluate() override {
        CHECKINVARIANTS;
        return value;
    }
private:
    double value{NAN};
};

#endif // SYNTAXTREE_H
```

```cpp
#ifndef DOUBLELINKEDLIST_H
#define DOUBLELINKEDLIST_H


#include "contract.h"

template<typename T>
class Node {
public:
    Node *prev = nullptr;
    Node *next = nullptr;
    T element{};
};

template<typename T>
class DoubleLinkedList
{

    Node<T> *first{nullptr};
    Node<T> *last{nullptr};
    size_t nbElements{0};
public:

    INVARIANTS(
        INVARIANT(((nbElements == 0) || (first != nullptr)), "The first element of a non-empty list cannot be nullptr")
        INVARIANT((nbElements == 0) || (last != nullptr), "The last element of a non-empty list cannot be nullptr"))

    ///
    /// \brief Adds a node at the end of the list
    /// \param node Node to be added
    ///
    void pushBack(Node<T>* node) {
        CHECKINVARIANTS;
        PRE_CONDITION((node != nullptr), "A node to be inserted cannot be nullptr");
        if (last != nullptr) {
            node->prev = last;
            last->next = node;
        }
        last = node;
        if (first == nullptr) {
            first = node;
        }
        nbElements ++;
        CHECKINVARIANTS;
    }

    ///
    /// \brief Adds a node at the front of the list
    /// \param node Node to be added
    ///
    void pushFront(Node<T>* node) {
        CHECKINVARIANTS;
        PRE_CONDITION((node != nullptr), "A node to be inserted cannot be nullptr");
        if (first != nullptr) {
            node->next = first;
            first->prev = node;
        }
        first = node;
        if (last == nullptr) {
            last = node;
        }
        nbElements ++;
        CHECKINVARIANTS;
    }

    ///
    /// \brief Adds a node after an existing node of the list
    /// \param node Node to be added
    /// \param afterThis Node after which the new node shall be added
    ///
    void insertAfter(Node<T>* node, Node<T>* afterThis) {
        CHECKINVARIANTS;
        PRE_CONDITION((node != nullptr), "A node to be inserted cannot be nullptr");
        PRE_CONDITION(isNodeInList(afterThis), "We cannot add a node after a one that is not in the list");
        node->next = afterThis->next;
        if (afterThis->next != nullptr) {
            afterThis->next->prev = node;
        }
        else {
            last = node;
        }
        node->prev = afterThis;
        afterThis->next = node;
        nbElements ++;
        CHECKINVARIANTS;
    }

    ///
    /// \brief Removes a node from the list
    /// \param node Node to be removed
    ///
    /// As an asumption the node should be in the list, else there is a misuse of this function
    ///
    void remove(Node<T>* node) {
        CHECKINVARIANTS;
        PRE_CONDITION(isNodeInList(node), "Try to remove a node that is not in the list");

        if (node->prev != nullptr) {
            node->prev->next = node->next;
        }
        else {
            first = node->next;
            if (first == nullptr) {
                last = nullptr;
            }
        }
        if (node->next != nullptr) {
            node->next->prev = node->prev;
        }
        else {
            last = node->prev;
            if (last == nullptr) {
                first = nullptr;
            }
        }
        nbElements --;
        CHECKINVARIANTS;
    }

    ///
    /// \brief Returns true if the node is in the list, false else
    /// \param node Node to be checked
    /// \return true if the node is in the list, falst else
    ///
    [[nodiscard]]
    bool isNodeInList(Node<T> *node) const {
        CHECKINVARIANTS;
        Node<T> *n = node;
        while (n != nullptr) {
            if (n == node) {
                return true;
            }
            n = n->next;
        }
        return false;
    }

    ///
    /// \brief Returns the last node of the list
    /// \return The last node of the list, nullptr if the list is empty
    ///
    [[nodiscard]]
    Node<T>* getLastNode() const {
        CHECKINVARIANTS;
        return last;
    }

    ///
    /// \brief Returns the first node of the list
    /// \return The first node of the list, nullptr if the list is empty
    ///
    [[nodiscard]]
    Node<T>* getFirstNode() const {
        CHECKINVARIANTS;
        return first;
    }

    ///
    /// \brief Returns the last element of the list
    /// \return The last element of the list
    ///
    /// This function should only be called on a non-empty list.
    ///
    [[nodiscard]]
    T getLastElement() const {
        CHECKINVARIANTS;
        PRE_CONDITION(last != nullptr, "Cannot get the last element if it doesn't exist");
        return last->element;
    }

    ///
    /// \brief Returns the first element of the list
    /// \return The first element of the list
    ///
    /// This function should only be called on a non-empty list.
    ///
    [[nodiscard]]
    T getFirstElement() const {
        CHECKINVARIANTS;
        PRE_CONDITION(first != nullptr, "Cannot get the first element if it doesn't exist");
        return first->element;
    }

    ///
    /// \brief Returns the number of elements in the list
    /// \return The number of elements in the list
    ///
    [[nodiscard]]
    size_t getNbElements() const {
        CHECKINVARIANTS;
        return nbElements;
    }

    ///
    /// \brief Removes the first element of the list.
    ///
    /// The call is invalid if the list is empty.
    ///
    void popFront() {
        CHECKINVARIANTS;
        PRE_CONDITION(first != nullptr, "Cannot popFront an empty list");
        if (first != nullptr) {
            if (first->next != nullptr) {
                first->next->prev = nullptr;
            }
        }
        if (last == first) {
            last = nullptr;
        }
        first = first->next;
        nbElements --;
        CHECKINVARIANTS;
    }

    ///
    /// \brief Removes the last element of the list.
    ///
    /// The call is invalid if the list is empty.
    ///
    void popBack() {
        CHECKINVARIANTS;
        PRE_CONDITION(last != nullptr, "Cannot popBack an empty list");
        if (last != nullptr) {
            if (last->prev != nullptr) {
                last->prev->next = nullptr;
            }
        }
        if (first == last) {
            first = nullptr;
        }
        last = last->prev;
        nbElements --;
        CHECKINVARIANTS;
    }

};


#endif // DOUBLELINKEDLIST_H
```
Voici une correction et une amélioration des scénarios mentionnés avec des commentaires clairs pour les invariants, les préconditions et les postconditions. Les corrections portent sur des validations supplémentaires et une meilleure structuration du code.

---

### **1. Gestion de connexion réseau**

```cpp
INVARIANTS(
    INVARIANT(isOpen_ || socket_ == INVALID_SOCKET,
              "If isOpen_ is false, the socket should be invalid (closed).")
)

// Méthode pour se connecter
void connect(const std::string& host, int port) {
    CHECKINVARIANTS;
    PRE_CONDITION(!host.empty(), "Host name cannot be empty");
    PRE_CONDITION(port > 0 && port <= 65535, "Port number must be in range 1-65535");

    // Code pour ouvrir la connexion
    socket_ = /* créer le socket */;
    isOpen_ = (socket_ != INVALID_SOCKET);

    POST_CONDITION(isOpen_, "After connect(), isOpen_ must be true");
    CHECKINVARIANTS;
}

// Méthode pour envoyer
void sendData(const std::string& data) {
    CHECKINVARIANTS;
    PRE_CONDITION(isOpen_, "Connection must be open before sending data");
    PRE_CONDITION(!data.empty(), "Data to send cannot be empty");

    // Code d'envoi des données...

    CHECKINVARIANTS;
}

// Méthode pour fermer la connexion
void close() {
    CHECKINVARIANTS;
    PRE_CONDITION(isOpen_, "Cannot close a connection that is not open");

    // Code pour fermer la connexion
    socket_ = INVALID_SOCKET;
    isOpen_ = false;

    POST_CONDITION(!isOpen_, "After close(), isOpen_ must be false");
    CHECKINVARIANTS;
}
```

---

### **2. Parser JSON**

```cpp
INVARIANTS(
    INVARIANT(!parsed_ || !internalData_.empty(), 
              "If parsed_ == true, then internalData_ should not be empty")
)

void parse(const std::string& jsonText) {
    CHECKINVARIANTS;
    PRE_CONDITION(!jsonText.empty(), "Input JSON text cannot be empty");

    // Code pour parser le JSON...
    internalData_ = /* résultat du parsing */;
    parsed_ = true;

    POST_CONDITION(parsed_, "After parse(), the parser must be in 'parsed' state");
    CHECKINVARIANTS;
}

std::string getString(const std::string& key) const {
    CHECKINVARIANTS;
    PRE_CONDITION(parsed_, "Must parse JSON before accessing data");

    // Code pour obtenir la valeur associée à la clé...
    return /* valeur */;
}
```

---

### **3. Gestion de threads**

```cpp
INVARIANTS(
    INVARIANT(threadCount_ >= 0, "Thread count must not be negative")
    INVARIANT((threadCount_ == 0) == threads_.empty(),
              "If threadCount_ is 0, threads_ list should be empty (and vice versa)")
)

void start(int n) {
    CHECKINVARIANTS;
    PRE_CONDITION(n > 0, "Number of threads must be positive");

    // Code pour démarrer les threads
    threadCount_ = n;

    POST_CONDITION(threadCount_ == n, "threadCount_ must match the requested number");
    CHECKINVARIANTS;
}

void shutdown() {
    CHECKINVARIANTS;
    PRE_CONDITION(threadCount_ > 0, "No threads to shut down");

    // Code pour arrêter les threads
    threadCount_ = 0;
    threads_.clear();

    POST_CONDITION(threadCount_ == 0, "All threads must be shut down");
    CHECKINVARIANTS;
}

void enqueueJob(const Job& job) {
    CHECKINVARIANTS;
    PRE_CONDITION(threadCount_ > 0, "Cannot enqueue a job if the thread pool is not started");

    // Code pour ajouter le job à la queue

    CHECKINVARIANTS;
}
```

---

### **4. Gestion d’un buffer circulaire**

```cpp
INVARIANTS(
    INVARIANT(tail_ >= 0 && tail_ < capacity_, "tail_ index out of range")
    INVARIANT(head_ >= 0 && head_ < capacity_, "head_ index out of range")
    INVARIANT(size_ <= capacity_, "Circular buffer size cannot exceed capacity")
)

void push(int value) {
    CHECKINVARIANTS;
    PRE_CONDITION(size_ < capacity_, "Cannot push into a full circular buffer");

    buffer_[tail_] = value;
    tail_ = (tail_ + 1) % capacity_;
    size_++;

    POST_CONDITION(size_ > 0, "Size must be > 0 after push");
    CHECKINVARIANTS;
}

int pop() {
    CHECKINVARIANTS;
    PRE_CONDITION(size_ > 0, "Cannot pop from an empty buffer");

    int val = buffer_[head_];
    head_ = (head_ + 1) % capacity_;
    size_--;

    POST_CONDITION(size_ >= 0, "Size must not be negative after pop");
    CHECKINVARIANTS;

    return val;
}
```

---

### **5. Sémaphore ou verrous**

```cpp
INVARIANTS(
    INVARIANT(count_ >= 0, "Semaphore count must never be negative")
)

void acquire() {
    CHECKINVARIANTS;
    PRE_CONDITION(count_ > 0, "Cannot acquire if semaphore count is zero");

    count_--;

    POST_CONDITION(count_ >= 0, "After acquire, semaphore count cannot be negative");
    CHECKINVARIANTS;
}

void release() {
    CHECKINVARIANTS;

    count_++;

    POST_CONDITION(count_ > 0, "After release, semaphore count must be > 0");
    CHECKINVARIANTS;
}
```

### Points clés
- **Préconditions** : on ne `start()` pas un timer déjà démarré, on ne `stop()` pas un timer déjà stoppé.  
- **Invariant** : si le timer est en cours, on a un `startTime_` valide.
- **Ajout de CHECKINVARIANTS systématique** : Pour garantir la cohérence avant et après chaque opération critique.

---

### Conclusion

Dans toutes ces situations **courantes** (gestion réseau, parsing, threads, transactions, cache, etc.), on retrouve le même schéma de **Design by Contract** :

1. **Invariants** pour assurer la cohérence globale de l’objet (et de ses champs).  
2. **Préconditions** pour **empêcher** un appel en situation illégitime (fichier non chargé, ressource déjà fermée, etc.).  
3. **Postconditions** pour **garantir** que l’état après exécution est conforme (taille qui a augmenté/diminué, compte débité, etc.).

Ces **exemples de contrats** sont **indépendants** des macros ; vous pouvez les implémenter avec vos propres macros (`INVARIANT(...)`, `PRE_CONDITION(...)`, `POST_CONDITION(...)`) ou les placer directement dans des `if`/`throw`. L’important est de **définir clairement** les règles qui doivent être satisfaites **avant**, **après**, et **en permanence** pour chaque objet ou méthode critique.

<br><br><br><br><br><br><br><br><br><br>

# Memory check

### **Résumé des observations avec Valgrind**

#### **Test 0 : `testingNoLeak()`**
- Utilisation de `std::unique_ptr`, qui gère automatiquement la libération de mémoire.
- **Résultat attendu :**
  - Pas de fuite mémoire, car `std::unique_ptr` détruit l'objet lorsqu'il sort du champ.
- **Comportement observé :**
  - Pas de fuite mémoire, comme confirmé par Valgrind.

---

#### **Test 1 : `testingLeak()`**
- Alloue dynamiquement un objet avec `new`, mais **ne le libère pas** avec `delete`.
- **Résultat attendu :**
  - Fuite mémoire de 8 octets correspondant à la structure allouée.
- **Comportement observé :**
  - Valgrind détecte une fuite mémoire de 8 octets.

---

#### **Test 2 : `testBadPointer()`**
- Manipule des pointeurs non valides :
  - `int *p = nullptr;` → Écriture dans un pointeur nul (undefined behavior).
  - `int *p2 = (int*)3;` → Écriture dans une adresse non allouée.
- **Résultat attendu :**
  - Erreur critique (`segmentation fault`) sur les deux écritures invalides.
- **Comportement observé :**
  - Valgrind détecte une "écriture invalide" avec des adresses hors plage.

---

#### **Test 3 : `testBadVector()`**
- Accède directement à un index non alloué dans un vecteur (`vector[3]`).
- **Résultat attendu :**
  - Erreur d'accès mémoire (out-of-bounds).
- **Comportement observé :**
  - Valgrind signale une "écriture invalide".

---

#### **Test 4 : `testBadPointer2()`**
- Libère correctement un pointeur avec `delete`, mais tente ensuite de le lire.
- **Résultat attendu :**
  - Comportement indéfini : lecture d'un pointeur libéré.
- **Comportement observé :**
  - Aucun problème signalé par Valgrind dans certains cas (car l'accès est encore "visible"), mais ce code est dangereux.

---

#### **Test 5 : `testBadMultiThread()`**
- Deux threads modifient une variable partagée sans synchronisation.
- **Résultat attendu :**
  - Comportement imprévisible (race condition).
- **Comportement observé :**
  - Aucun problème signalé par Valgrind pour l'accès à la mémoire, mais ce comportement est incorrect et non sûr.

---

#### **Test 6 : `testMultiThread()`**
- Identique au test 5, mais attend les threads avec `pthread_join`.
- **Résultat attendu :**
  - Toujours une race condition, car les threads modifient une variable partagée sans synchronisation.
- **Comportement observé :**
  - Aucun problème signalé par Valgrind pour la mémoire, mais la synchronisation est absente.

---

#### **Test 7 : `testBetterMultiThread()`**
- Introduit un mutex pour synchroniser l'accès à la variable partagée.
- **Résultat attendu :**
  - Pas de problème de concurrence (race condition).
- **Comportement observé :**
  - Pas de problèmes signalés par Valgrind.

---

### **Comportement global du code**

1. **Tests liés à la mémoire :**
   - `testingLeak()` (Test 1) provoque une fuite mémoire.
   - Les autres tests (`testingNoLeak()`, `testBadPointer2()`) gèrent correctement la mémoire mais certains comportements (lecture après libération) restent dangereux.

2. **Tests liés aux accès mémoire invalides :**
   - `testBadPointer()` et `testBadVector()` provoquent des écritures invalides, générant des erreurs critiques (`segmentation fault`).

3. **Tests multithreads :**
   - `testBadMultiThread()` et `testMultiThread()` souffrent de race conditions.
   - `testBetterMultiThread()` corrige cela avec l'utilisation de `pthread_mutex`.

---

### **Recommandations**
- **Corriger les fuites mémoire :**
  - Libérer explicitement les objets alloués dans `testingLeak()` :
    ```cpp
    delete pointer;
    ```

- **Protéger les pointeurs :**
  - Toujours vérifier les pointeurs avant de les utiliser (éviter d'écrire dans un pointeur nul).

- **Gérer les accès aux vecteurs :**
  - Utiliser `at()` au lieu de `operator[]` pour éviter les accès hors limites :
    ```cpp
    vector.at(3) = 10;  // Lève une exception si l'index est invalide
    ```

- **Synchronisation des threads :**
  - Utiliser des primitives de synchronisation comme `pthread_mutex` dans tous les cas où des variables partagées sont modifiées.

Ce code illustre plusieurs bonnes pratiques et erreurs courantes, et Valgrind est un outil puissant pour les détecter.

---

### **Résumé des observations avec AddressSanitizer**

#### **Test 0 : `testingNoLeak()`**
- **Description :**
  Utilisation de `std::unique_ptr` pour gérer la mémoire.
- **Résultat :**
  - Pas de fuite mémoire détectée.
  - Le programme s'exécute correctement.

---

#### **Test 1 : `testingLeak()`**
- **Description :**
  Allocation dynamique avec `new` sans libération.
- **Observation :**
  - **LeakSanitizer** détecte une fuite mémoire de **8 octets**.
  - Rapport détaillé :
    - Localisation exacte : ligne 19 dans `testingLeak()`.
    - Trace de la pile montrant l'origine de l'allocation.
  - **Problème identifié :**
    La mémoire allouée avec `new` n'a pas été libérée.

---

#### **Test 2 : `testBadPointer()`**
- **Description :**
  Manipulation de pointeurs non valides :
  - Écriture dans un pointeur nul.
  - Écriture dans une adresse non allouée (adresse `0x3`).
- **Observation :**
  - **Segmentation fault** (SEGV) signalé.
  - Détails :
    - Localisation exacte : ligne 35 dans `testBadPointer()`.
    - L'adresse d'écriture est nulle (`0x0`).
    - Type d'erreur : **WRITE memory access**.
  - **Problème identifié :**
    Accès mémoire non valide causé par un pointeur nul.

---

#### **Test 3 : `testBadVector()`**
- **Description :**
  Accès hors limites à un vecteur.
- **Observation :**
  - **Segmentation fault** (SEGV) signalé.
  - Détails :
    - Localisation exacte : ligne 59 dans `testBadVector()`.
    - L'adresse d'écriture (`0xC`) pointe vers une zone mémoire non mappée.
    - Type d'erreur : **WRITE memory access**.
  - **Problème identifié :**
    Accès à un index non valide dans le vecteur.

---

#### **Test 4 : `testBadPointer2()`**
- **Description :**
  Lecture après libération d'un pointeur.
- **Observation :**
  - **Heap-use-after-free** détecté.
  - Détails :
    - Localisation exacte : ligne 52 dans `testBadPointer2()`.
    - Adresse libérée : `0x602000000010`.
    - Rapport montre :
      - La libération (ligne 50).
      - L'allocation (ligne 46).
  - **Problème identifié :**
    Utilisation d'un pointeur après sa libération.

---

#### **Test 5 : `testBadMultiThread()`**
- **Description :**
  Deux threads accèdent à une variable partagée sans synchronisation.
- **Observation :**
  - Aucun problème détecté par AddressSanitizer.
  - Toutefois, cette implémentation souffre de **race conditions**, non détectées par ASan. Un outil comme **ThreadSanitizer** est requis pour les repérer.

---

#### **Test 6 : `testMultiThread()`**
- **Description :**
  Identique au test 5, avec `pthread_join` pour attendre les threads.
- **Observation :**
  - Aucun problème détecté.
  - La race condition persiste, mais n'est pas signalée par ASan.

---

#### **Test 7 : `testBetterMultiThread()`**
- **Description :**
  Synchronisation correcte avec un mutex.
- **Observation :**
  - Aucun problème détecté.
  - Le programme fonctionne correctement, et les accès à la variable partagée sont protégés.

---

### **Résumé global**
1. **Tests réussis :**  
   - Test 0 (gestion correcte de la mémoire).  
   - Tests 6 et 7 (multi-threading correctement synchronisé pour le test 7).

2. **Problèmes détectés :**  
   - **Fuite mémoire :** Test 1.  
   - **Accès mémoire invalide :** Tests 2, 3, et 4.  
   - **Race conditions :** Tests 5 et 6 (non détectées par ASan, nécessitent ThreadSanitizer).

3. **Recommandations :**
   - Libérer explicitement la mémoire dans `testingLeak()` (Test 1).
   - Vérifier les pointeurs avant de les utiliser (Test 2).
   - Utiliser `at()` pour les accès sécurisés aux vecteurs (Test 3).
   - Éviter les lectures après libération (Test 4).
   - Toujours synchroniser les accès multi-threads (Test 5).

   ---

   ### **Résumé des résultats avec Helgrind**

Voici un résumé des résultats obtenus pour chaque test lors de l'exécution avec **Helgrind**, un détecteur d'erreurs liées à la concurrence.

---

### **Test 0 : `testingNoLeak()`**
- **Description :** Ce test n'implique pas de threads ou d'accès concurrents.
- **Résultat Helgrind :**
  - **Aucune erreur détectée.**
  - Le programme fonctionne correctement, comme attendu.

---

### **Test 1 : `testingLeak()`**
- **Description :** Test d'une fuite mémoire, sans implication de threads.
- **Résultat Helgrind :**
  - **Aucune erreur détectée.**
  - Helgrind n'est pas conçu pour détecter les fuites mémoire ; utilisez **Memcheck** ou **ASan** pour cela.

---

### **Test 2 : `testBadPointer()`**
- **Description :** Manipulation de pointeurs non valides (pointeur nul ou adresse non allouée).
- **Résultat Helgrind :**
  - **Erreur critique (segmentation fault).**
  - La cause :
    - Écriture dans un pointeur nul (adresse 0x0).
    - Helgrind détecte une tentative d'accès invalide mais n'affiche pas d'informations supplémentaires sur les threads, car ce test n'implique pas de multi-threading.

---

### **Test 3 : `testBadVector()`**
- **Description :** Accès hors limites dans un vecteur.
- **Résultat Helgrind :**
  - **Erreur critique (segmentation fault).**
  - La cause :
    - Écriture dans une zone non allouée du vecteur (adresse 0xC).
    - Helgrind identifie le problème comme un accès mémoire invalide mais ne le relie pas à un problème de concurrence.

---

### **Test 4 : `testBadPointer2()`**
- **Description :** Utilisation d'un pointeur après sa libération.
- **Résultat Helgrind :**
  - **Aucune erreur détectée.**
  - Helgrind ne signale pas ce type d'erreur, qui est mieux géré par **AddressSanitizer**.

---

### **Test 5 : `testBadMultiThread()`**
- **Description :** Deux threads accèdent à une variable partagée sans synchronisation.
- **Résultat Helgrind :**
  - **Erreur détectée : race condition.**
  - Rapport Helgrind :
    - Plusieurs threads écrivent simultanément sur la variable partagée `sharedVariable` sans mécanisme de verrouillage.
    - Conflit détecté sur l'adresse `0x10c164`, correspondant à la variable partagée.

---

### **Test 6 : `testMultiThread()`**
- **Description :** Similaire au test 5, mais les threads sont joints (`pthread_join`).
- **Résultat Helgrind :**
  - **Erreur détectée : race condition.**
  - Rapport Helgrind :
    - Même cause que dans le test 5 : absence de synchronisation entre les threads lors de l'accès à `sharedVariable`.

---

### **Test 7 : `testBetterMultiThread()`**
- **Description :** Synchronisation correcte avec un mutex.
- **Résultat Helgrind :**
  - **Aucune erreur détectée.**
  - Helgrind confirme que le programme fonctionne correctement, avec une synchronisation adéquate.

---

### **Synthèse des résultats**

| **Test** | **Description**                   | **Résultat Helgrind**                    | **Remarque**                                    |
|----------|-----------------------------------|------------------------------------------|------------------------------------------------|
| **0**    | Test sans threads                 | Aucune erreur détectée                   | Fonctionne correctement.                        |
| **1**    | Test de fuite mémoire             | Aucune erreur détectée                   | Utiliser ASan pour détecter les fuites.        |
| **2**    | Manipulation de pointeurs invalides | Segmentation fault                       | Problème de pointeur nul, hors scope d'Helgrind.|
| **3**    | Accès hors limites dans un vecteur | Segmentation fault                       | Hors scope d'Helgrind.                         |
| **4**    | Utilisation après libération      | Aucune erreur détectée                   | Utiliser ASan pour ce type de problème.        |
| **5**    | Accès concurrent non synchronisé  | Race condition détectée                  | Synchronisation nécessaire.                    |
| **6**    | Accès concurrent avec join        | Race condition détectée                  | Synchronisation nécessaire.                    |
| **7**    | Synchronisation avec mutex        | Aucune erreur détectée                   | Fonctionne correctement.                       |

---

### **Recommandations**
1. **Synchronisation des threads :**
   - Pour les tests 5 et 6, utilisez un mutex pour protéger l'accès à `sharedVariable`.

2. **Détection des fuites mémoire :**
   - Pour le test 1, utilisez **AddressSanitizer** ou **Memcheck**.

3. **Gestion des erreurs mémoire :**
   - Les tests 2, 3 et 4 nécessitent une attention particulière pour éviter les accès hors limites ou l'utilisation de mémoire après libération. Utilisez **AddressSanitizer** pour ces cas.

   ---

   ### **Résumé des résultats avec ThreadSanitizer**

Voici une analyse des sorties générées par **ThreadSanitizer** pour chaque test.

---

### **Test 0 : `testingNoLeak()`**
- **Description :** Aucune utilisation de threads.
- **Résultat :**
  - Pas de problèmes détectés.
  - ThreadSanitizer n'indique aucun avertissement ou erreur.

---

### **Test 1 : `testingLeak()`**
- **Description :** Test de fuite mémoire, sans threads.
- **Résultat :**
  - Pas de problèmes détectés.
  - **ThreadSanitizer** ne détecte pas les fuites mémoire. Utilisez **AddressSanitizer** pour cela.

---

### **Test 2 : `testBadPointer()`**
- **Description :** Manipulation de pointeurs non valides.
- **Résultat :**
  - **Erreur critique détectée : segmentation fault (SEGV).**
  - La cause :
    - Écriture dans un pointeur nul (`nullptr`).
    - Adresse : `0x0`.
    - **ThreadSanitizer** ne fournit pas d'informations supplémentaires, car ce problème n'est pas lié à la concurrence.

---

### **Test 3 : `testBadVector()`**
- **Description :** Accès hors limites dans un vecteur.
- **Résultat :**
  - **Erreur critique détectée : segmentation fault (SEGV).**
  - La cause :
    - Accès à une adresse non valide (`0xC`) dans le vecteur.
    - **ThreadSanitizer** ne fournit pas d'informations supplémentaires, car ce problème n'est pas lié à la concurrence.

---

### **Test 4 : `testBadPointer2()`**
- **Description :** Utilisation d'un pointeur après libération.
- **Résultat :**
  - **Erreur détectée : heap-use-after-free.**
  - Détails :
    - Lecture après la libération d'un pointeur.
    - Localisation :
      - Allocation : Ligne 50 dans `testBadPointer2()`.
      - Lecture après libération : Ligne 52 dans `testBadPointer2()`.
  - **ThreadSanitizer** fournit des détails clairs sur la mémoire libérée et utilisée à tort.

---

### **Test 5 : `testBadMultiThread()`**
- **Description :** Accès non synchronisé à une variable partagée par plusieurs threads.
- **Résultat :**
  - **Erreur détectée : data race.**
  - Détails :
    - Conflit sur la variable `sharedVariable`.
    - Threads impliqués :
      - `Thread T1` écrit dans `sharedVariable`.
      - `Thread T2` écrit dans la même variable sans synchronisation.
    - ThreadSanitizer indique les points d'écriture dans les threads et fournit une trace de pile pour chaque accès.
  - **Avertissements supplémentaires :**
    - Fuite de threads signalée (les threads ne sont pas correctement joints).

---

### **Test 6 : `testMultiThread()`**
- **Description :** Similaire au test 5, mais avec `pthread_join`.
- **Résultat :**
  - **Erreur détectée : data race.**
  - Détails :
    - Conflit sur la variable `sharedVariable`, comme dans le test 5.
    - Threads impliqués :
      - `Thread T1` écrit dans `sharedVariable`.
      - `Thread T2` écrit dans la même variable sans synchronisation.
    - ThreadSanitizer fournit une trace de pile détaillée.

---

### **Test 7 : `testBetterMultiThread()`**
- **Description :** Synchronisation correcte avec un mutex.
- **Résultat :**
  - Aucun problème détecté.
  - Le programme fonctionne correctement.

---

### **Synthèse des résultats**

| **Test** | **Description**                   | **Résultat ThreadSanitizer**              | **Remarque**                                    |
|----------|-----------------------------------|-------------------------------------------|------------------------------------------------|
| **0**    | Test sans threads                 | Aucun problème détecté                    | Fonctionne correctement.                        |
| **1**    | Test de fuite mémoire             | Aucun problème détecté                    | Pas pertinent pour ThreadSanitizer.            |
| **2**    | Manipulation de pointeurs invalides | Segmentation fault                        | Problème hors du scope de ThreadSanitizer.     |
| **3**    | Accès hors limites dans un vecteur | Segmentation fault                        | Problème hors du scope de ThreadSanitizer.     |
| **4**    | Utilisation après libération      | Heap-use-after-free détecté               | Fournit des détails utiles pour la correction. |
| **5**    | Accès concurrent non synchronisé  | Data race et fuite de threads détectés    | Synchronisation nécessaire.                    |
| **6**    | Accès concurrent avec join        | Data race détectée                        | Synchronisation nécessaire.                    |
| **7**    | Synchronisation avec mutex        | Aucun problème détecté                    | Fonctionne correctement.                       |

---

### **Recommandations**
1. **Synchronisez les threads dans les tests 5 et 6 :**
   - Ajoutez un mutex ou un autre mécanisme de verrouillage pour éviter les **data races** sur `sharedVariable`.

2. **Corrigez les problèmes de gestion mémoire :**
   - Pour le test 4, assurez-vous que les pointeurs ne sont pas utilisés après avoir été libérés.

3. **Utilisez des outils spécialisés pour les autres types d'erreurs :**
   - **AddressSanitizer** pour les problèmes de mémoire.
   - **ThreadSanitizer** pour les problèmes liés à la concurrence.