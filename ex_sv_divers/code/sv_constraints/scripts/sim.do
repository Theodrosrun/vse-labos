###############################################################################
# Projet: Cours de systèmes numériques
#
# Fichier : sim.do
# Description : Script simple de compilation et simulation
#               Il doit être lancé depuis un répertoire au même niveau que
#               scripts. Il est suggéré d'utiliser un répertoire "comp" dans
#               lequel les fichiers seront générés.
#
# Auteur : Yann Thoma
# Equipe : Institut REDS
# Date   : 25.04.2017
#
#| Modifications |#############################################################
# Ver  Date      Qui   Description
# 1.0  25.04.17  YTA  Version initiale
###############################################################################

# Définition de la librairie à utiliser
vlib work

# Compilation
vlog -sv ../src_sv/constraints_test.sv

# Exécution
vsim work.constraints_test
# Testbench automatique. Il doit se terminer automatiquement
run -all

# S'il y a un argument et qu'il est "exit", alors le script quitte Questasim
if {$argc >= 1} {
  if {[string compare $1 "exit"] == 0} {
    exit
  }
}
