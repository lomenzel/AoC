&fras "input4.txt"
⊜□¬∊,"\n"
RemoveCardId ← (
  ⊜□¬∊,":"
  ↘ 1
  ⊔⊢
)
Split ← (
  ⊔
  ⊜□¬∊," "
  □
)

Points ← (
  ⊔
  RemoveCardId
  ⊜□¬∊,"|"

  ≡Split
  ⊔⊢⇌:⊔⊢.
  :
  .▽∊,
  :⧻↘1
  ⍥(×2): ↧ 1 ⧻
)
≡Points
/+
