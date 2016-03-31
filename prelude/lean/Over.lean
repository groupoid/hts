/- Over.lean -/

import Setoid
import Cat

/-
 - The category over X
 -/

record OverType (C : CatType) (X : C) : Type :=
    (Dom : C)
    (Hom : Dom ⇒C⇒ X)

namespace Over
  section withCatX
    variables (C : CatType) (X : C)

    -- commutative squares
    abbreviation TriProp {X1 X2 : C}
        (m1 : X1 ⇒C⇒ X)
        (m2 : X2 ⇒C⇒ X)
        (m12: X1 ⇒C⇒ X2)
            : Prop :=
        (m2 ⊙C⊙ m12) ≡(X1 ⇒C⇒ X)≡ m1

    definition TriId {X1 : C} (m : X1 ⇒C⇒ X)
            : TriProp C X m m ① :=
        CatType.UnitR C m

    section forMul1
        variables {X1 X2 X3 : C}
            {m1 : X1 ⇒C⇒ X} {m2 : X2 ⇒C⇒ X} {m3 : X3 ⇒C⇒ X}
            {m12 : X1 ⇒C⇒ X2} {m23 : X2 ⇒C⇒ X3}
            (tr12 : TriProp C X m1 m2 m12)
            (tr23 : TriProp C X m2 m3 m23)
        definition TriMul
            : TriProp C X m1 m3 (m23 ⊙C⊙ m12)
        :=
            (CatType.AssocInv C m3 m23 m12) ⊡_⊡
            (tr23 /⊙C⊙ m12) ⊡_⊡
            tr12
    end forMul1

    -- morphisms in the category of morphisms
    record HomType (A B : OverType C X) : Type :=
        (atDom : OverType.Dom A ⇒C⇒ OverType.Dom B)
        (tr : TriProp C X (OverType.Hom A) (OverType.Hom B) atDom)

    definition HomEqu {A B : OverType C X} : EquType (HomType C X A B) :=
        λ(f g : HomType C X A B),
            (HomType.atDom f ≡(OverType.Dom A ⇒C⇒ OverType.Dom B)≡ HomType.atDom g)

    definition HomSet : Cat.HomType (OverType C X) :=
        λ(A B : OverType C X), Setoid.MkOb
            /- El -/ (HomType C X A B)
            /- Equ -/ (@HomEqu C X A B)
            /- Refl -/ (λ(f : HomType C X A B), ⊜)
            /- Trans -/ (λ(f g h : HomType C X A B),
                λ(fg : HomEqu C X f g), λ(gh : HomEqu C X g h),
                    (fg ⊡_⊡ gh))
            /- Sym -/ (λ(f g : HomType C X A B),
                λ(fg : HomEqu C X f g),
                    (SetoidType.Sym _ fg))

    definition Id : Cat.IdType (@HomSet C X) :=
        λ(A : OverType C X),
            HomType.mk ① (TriId C X (OverType.Hom A))

    definition Mul : Cat.MulType (@HomSet C X) :=
        λ(m1 m2 m3 : OverType C X), Setoid.MkHom2
            (HomSet C X m2 m3) (HomSet C X m1 m2) (HomSet C X m1 m3)
            /- onElEl -/ (λ(mm23 : HomSet C X m2 m3), λ(mm12 : HomSet C X m1 m2), HomType.mk
                /- atDom -/ (HomType.atDom mm23 ⊙C⊙ HomType.atDom mm12)
                /- tr -/ (TriMul C X (HomType.tr mm12) (HomType.tr mm23)))
            /- onElEqu -/ (λ(mm23 : HomSet C X m2 m3), λ(mm12 mm12' : HomSet C X m1 m2),
                λ(eq : mm12 ≡(HomSet C X m1 m2)≡ mm12'),
                    ((HomType.atDom mm23) ⊙C⊙/ eq))
            /- onEquEl -/ (λ(mm23 mm23' : HomSet C X m2 m3),
                λ(eq : mm23 ≡(HomSet C X m2 m3)≡ mm23'),
                λ(mm12 : HomSet C X m1 m2),
                    (eq /⊙C⊙ (HomType.atDom mm12)))

    definition UnitL : Cat.UnitLProp (@Id C X) (@Mul C X) :=
        λ(m1 m2 : OverType C X), λ(m12 : HomType C X m1 m2),
            (@CatType.UnitL C (OverType.Dom m1) (OverType.Dom m2) (HomType.atDom m12))

    definition UnitR : Cat.UnitRProp (@Id C X) (@Mul C X) :=
        λ(m1 m2 : OverType C X), λ(m12 : HomType C X m1 m2),
            (@CatType.UnitR C (OverType.Dom m1) (OverType.Dom m2) (HomType.atDom m12))

    definition Assoc : Cat.AssocProp (@Mul C X) :=
        λ(m1 m2 m3 m4: OverType C X),
        λ(m34 : HomType C X m3 m4),
        λ(m23 : HomType C X m2 m3),
        λ(m12 : HomType C X m1 m2),
            (@CatType.Assoc C
                (OverType.Dom m1) (OverType.Dom m2)
                (OverType.Dom m3) (OverType.Dom m4)
                (HomType.atDom m34) (HomType.atDom m23) (HomType.atDom m12))

  end withCatX
end Over

definition OverCat (C : CatType) (X : C) : CatType :=
    Cat.MkOb
        (OverType C X) (Over.HomSet C X)
        (@Over.Id C X) (@Over.Mul C X)
        (@Over.UnitL C X) (@Over.UnitR C X) (@Over.Assoc C X)

definition OverSetoidType (Base : SetoidType) : Type :=
    OverType SetoidCat Base
definition OverSetoid.HomSet {Base : SetoidType} : Cat.HomType (OverSetoidType Base) :=
    Over.HomSet SetoidCat Base
definition OverSetoid.Id {Base : SetoidType} : Cat.IdType (@OverSetoid.HomSet Base) :=
    @Over.Id SetoidCat Base
definition OverSetoid.Mul {Base : SetoidType} : Cat.MulType (@OverSetoid.HomSet Base) :=
    @Over.Mul SetoidCat Base
definition OverSetoid.UnitL {Base : SetoidType} : Cat.UnitLProp (@OverSetoid.Id Base) (@OverSetoid.Mul Base) :=
    @Over.UnitL SetoidCat Base
definition OverSetoid.UnitR {Base : SetoidType} : Cat.UnitRProp (@OverSetoid.Id Base) (@OverSetoid.Mul Base) :=
    @Over.UnitR SetoidCat Base
definition OverSetoid.Assoc {Base : SetoidType} : Cat.AssocProp (@OverSetoid.Mul Base) :=
    @Over.Assoc SetoidCat Base

definition OverSetoidCat (Base : SetoidType) : CatType :=
    OverCat SetoidCat Base
