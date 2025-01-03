# Exercice 12, memory check

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