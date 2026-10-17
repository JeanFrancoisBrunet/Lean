import Mathlib

-- Évaluer des expressions
#eval "Bonjour Lean sur Pi 5"
#eval (List.range 10).map (· ^ 2)

-- Un premier théorème, prouvé automatiquement
theorem somme_comm (a b : Nat) : a + b = b + a := by
  omega

-- Une identité remarquable sur les réels (Mathlib)
example (a b : ℝ) : (a + b) ^ 2 = a ^ 2 + 2 * a * b + b ^ 2 := by
  ring

-- Inspecter un théorème existant
#check Nat.add_comm

theorem mon_theoreme (n : Nat) : n + 0 = n := by
  rfl
