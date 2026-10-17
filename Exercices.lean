import Mathlib

/-
  Exercices progressifs de découverte de Lean 4.
  Remplace chaque `sorry` par une preuve, puis lance :
      lake env lean Exercices.lean
  Quand il ne reste plus aucun avertissement "declaration uses sorry",
  tout est prouvé.
-/

/- ========== Niveau 1 : arithmétique ========== -/

-- Indice : `omega`, ou `Nat.add_comm a b`
theorem ex1 (a b : Nat) : a + b = b + a := by
  omega

-- Indice : `omega`, ou `simp`
theorem ex2 (n : Nat) : 2 * n = n + n := by
  omega

-- Indice : `simp`, ou `induction n with ...`
theorem ex3 (n : Nat) : 0 + n = n := by
  simp

/- ========== Niveau 2 : logique ========== -/

-- Indice : `exact ⟨hp, hq⟩`, ou `constructor` puis deux sous-buts
theorem ex4 (p q : Prop) (hp : p) (hq : q) : p ∧ q := by
  exact And.intro hp hq

-- Indice : `intro h`, puis `h.1` et `h.2` donnent les deux composantes
theorem ex5 (p q : Prop) : p ∧ q → q ∧ p := by
  intro h; exact And.intro h.2 h.1

-- Indice : `intro hpq hqr hp`, puis `exact hqr (hpq hp)`
theorem ex6 (p q r : Prop) : (p → q) → (q → r) → p → r := by
  intro hpq hqr hp; exact hqr (hpq hp)

-- Indice : `intro h`, `rcases h with hp | hq`, puis `Or.inl` / `Or.inr`
-- (ou la tactique `tauto`, qui résout beaucoup de problèmes logiques)
theorem ex7 (p q : Prop) : p ∨ q → q ∨ p := by
  tauto

/- ========== Niveau 3 : nombres réels et ensembles (Mathlib) ========== -/

-- Indice : `ring`
theorem ex8 (a b : ℝ) : (a - b) ^ 2 = a ^ 2 - 2 * a * b + b ^ 2 := by
  ring

-- Indice : `positivity`
theorem ex9 (x : ℝ) (h : 0 ≤ x) : 0 ≤ x ^ 2 + x := by
  positivity

-- Indice : `Set.inter_comm A B`, ou `ext x` puis `simp [and_comm]`
theorem ex10 (A B : Set ℕ) : A ∩ B = B ∩ A := by
  exact Set.inter_comm A B

/- ========== Défi : récurrence ========== -/

-- Somme des entiers de 0 à n : 2 * (0 + 1 + ... + n) = n * (n + 1)
-- Indice : `induction n with | zero => ... | succ k ih => ...`
-- Dans le cas `succ`, essaie `rw [Finset.sum_range_succ]`, puis `ih`,
-- puis termine avec `ring`.
theorem defi (n : Nat) : 2 * (∑ i ∈ Finset.range (n + 1), i) = n * (n + 1) := by
  induction n with | zero => simp | succ k ih => rw [Finset.sum_range_succ]; nlinarith [ih]
