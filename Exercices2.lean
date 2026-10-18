import Mathlib

/-
  Exercices 2 : quantificateurs, parité, fonctions, ensembles, récurrence.
  Même principe que Exercices.lean : remplace chaque `sorry` par une preuve,
  puis lance :
      lake env lean Exercices2.lean
  Au départ : 15 avertissements "declaration uses sorry". Quand il n'en reste
  aucun, tout est prouvé.

  Nouvelles tactiques utiles ici :
    intro x          fixer un x quelconque (pour prouver un « ∀ »)
    use a            donner le témoin a (pour prouver un « ∃ »)
    obtain ⟨x, hx⟩ := h   ouvrir une hypothèse « ∃ » ou « ∧ »
    rintro ⟨x, hx⟩   comme intro, mais en ouvrant tout de suite
    norm_num         calcul numérique
    exact?           demande à Lean de chercher dans Mathlib un théorème qui conclut
-/

/- ========== Niveau 4 : quantificateurs ∀ et ∃ ========== -/

-- Indice : `intro n`, puis `rfl` ou `simp`
theorem ex11 : ∀ n : ℕ, n + 0 = n := by
  simp

-- Indice : donne le témoin avec `use 7`, puis `norm_num`
theorem ex12 : ∃ n : ℕ, n * n = 49 := by
  use 7

-- Indice : `exact h 3` (une hypothèse « ∀ » s'applique comme une fonction)
theorem ex13 (P : ℕ → Prop) (h : ∀ x, P x) : P 3 := by
  exact h 3

-- Indice : `rintro ⟨x, hp, hq⟩`, puis `exact ⟨x, hp⟩`
theorem ex14 (P Q : ℕ → Prop) : (∃ x, P x ∧ Q x) → ∃ x, P x := by
  sorry

-- Indice : `rintro ⟨n, hn⟩`, puis `omega` (ou directement `simp`)
theorem ex15 : ¬ ∃ n : ℕ, n < 0 := by
  sorry

/- ========== Niveau 5 : parité et divisibilité ========== -/

-- Indice : `decide`, ou `use 5` (Even n signifie : ∃ r, n = r + r)
theorem ex16 : Even (10 : ℕ) := by
  sorry

-- Indice : `obtain ⟨k, hk⟩ := h`, puis `use k + 1`, puis `omega`
theorem ex17 (n : ℕ) (h : Even n) : Even (n + 2) := by
  sorry

-- Indice : `dvd_trans h1 h2`
theorem ex18 (a b c : ℕ) (h1 : a ∣ b) (h2 : b ∣ c) : a ∣ c := by
  sorry

-- Indice : essaie `exact?` : Lean cherche dans Mathlib un théorème qui conclut.
-- Si il en trouve un, remplace `exact?` par ce qu'il propose.
theorem ex19 (n : ℕ) : Even (n * (n + 1)) := by
  sorry

/- ========== Niveau 6 : fonctions et ensembles ========== -/

-- Indice : `simp [h]`, ou `rw [h]`
theorem ex20 (f : ℕ → ℕ) (h : ∀ x, f x = 2 * x) : f 3 = 6 := by
  sorry

-- Indice : `intro a b h`, puis `simpa using h`
theorem ex21 : Function.Injective (fun n : ℕ => n + 1) := by
  sorry

-- Indice : `intro x hx`, puis `exact hx.1`
theorem ex22 (A B : Set ℕ) : A ∩ B ⊆ A := by
  sorry

-- Indice : `intro x hx`, puis `exact Or.inl hx`
theorem ex23 (A B : Set ℕ) : A ⊆ A ∪ B := by
  sorry

/- ========== Défis : récurrence ========== -/

-- Indice : `induction n with | zero => simp | succ k ih => ...`
-- Dans le cas `succ` : `rw [pow_succ]` puis `omega` (ou `nlinarith [ih]`)
theorem defi_puissance (n : ℕ) : n + 1 ≤ 2 ^ n := by
  sorry

-- La somme des n premiers nombres impairs vaut n².
-- Indice : `induction n with | zero => simp | succ k ih => ...`
-- Dans le cas `succ` : `rw [Finset.sum_range_succ, ih]` puis `ring`
theorem defi_impairs (n : ℕ) : ∑ i ∈ Finset.range n, (2 * i + 1) = n ^ 2 := by
  sorry
