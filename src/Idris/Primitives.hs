{-# LANGUAGE RankNTypes, ScopedTypeVariables #-}

module Idris.Primitives(elabPrims) where

import Idris.ElabDecls
import Idris.ElabTerm
import Idris.AbsSyntax

import Core.TT
import Core.Evaluate

import Epic.Epic hiding (Term, Type, Name, fn)
import qualified Epic.Epic as E

data Prim = Prim { p_name  :: Name,
                   p_type  :: Type,
                   p_arity :: Int,
                   p_def   :: [Value] -> Maybe Value,
                   p_epic  :: ([E.Name], E.Term)
                 }

ty []     x = Constant x
ty (t:ts) x = Bind (MN 0 "T") (Pi (Constant t)) (ty ts x)

type ETm = E.Term
type EOp = E.Op

fun = E.fn
ref = E.ref

eOp :: EOp -> ([E.Name], ETm)
eOp op = ([E.name "x", E.name "y"], E.op_ op (E.fn "x") (E.fn "y")) 

eOpFn :: E.Type -> E.Type -> String -> ([E.Name], ETm)
eOpFn ty rty op = ([E.name "x", E.name "y"], 
                    foreign_ rty op [(E.fn "x", ty), (E.fn "y", ty)])

strToInt x = foreign_ tyInt "strToInt" [(x, tyString)]
intToStr x = foreign_ tyString "intToStr" [(x, tyInt)]
intToBigInt x = foreign_ tyBigInt "intToBigInt" [(x, tyInt)]
strToBigInt x = foreign_ tyBigInt "strToBig" [(x, tyString)]
bigIntToStr x = foreign_ tyString "bigToStr" [(x, tyBigInt)]
strToFloat x = foreign_ tyFloat "strToFloat" [(x, tyString)]
floatToStr x = foreign_ tyString "floatToStr" [(x, tyFloat)]
intToFloat x = foreign_ tyFloat "intToFloat" [(x, tyInt)]
floatToInt x = foreign_ tyInt "floatToInt" [(x, tyFloat)]

floatExp x = foreign_ tyFloat "exp" [(x, tyFloat)]
floatLog x = foreign_ tyFloat "log" [(x, tyFloat)]

strIndex x i = foreign_ tyChar "strIndex" [(x, tyString), (i, tyInt)]
strHead x = foreign_ tyChar "strHead" [(x, tyString)]
strTail x = foreign_ tyString "strTail" [(x, tyString)]
strCons x xs = foreign_ tyString "strCons" [(x, tyChar), (xs, tyString)]
strRev x = foreign_ tyString "strrev" [(x, tyString)]
strEq x y = foreign_ tyInt "streq" [(x, tyString), (y, tyString)]
strLt x y = foreign_ tyInt "strlt" [(x, tyString), (y, tyString)]

primitives =
   -- operators
  [Prim (UN "prim__addInt") (ty [IType, IType] IType) 2 (iBin (+))
    (eOp E.plus_),
   Prim (UN "prim__subInt") (ty [IType, IType] IType) 2 (iBin (-))
    (eOp E.minus_),
   Prim (UN "prim__mulInt") (ty [IType, IType] IType) 2 (iBin (*))
    (eOp E.times_),
   Prim (UN "prim__divInt") (ty [IType, IType] IType) 2 (iBin (div))
    (eOp E.divide_),
   Prim (UN "prim__eqInt")  (ty [IType, IType] IType) 2 (biBin (==))
    (eOp E.eq_),
   Prim (UN "prim__ltInt")  (ty [IType, IType] IType) 2 (biBin (<))
    (eOp E.lt_),
   Prim (UN "prim__lteInt") (ty [IType, IType] IType) 2 (biBin (<=))
    (eOp E.lte_),
   Prim (UN "prim__gtInt")  (ty [IType, IType] IType) 2 (biBin (>))
    (eOp E.gt_),
   Prim (UN "prim__gteInt") (ty [IType, IType] IType) 2 (biBin (>=))
    (eOp E.gte_),
   Prim (UN "prim__eqChar")  (ty [ChType, ChType] IType) 2 (bcBin (==))
    (eOp E.eq_),
   Prim (UN "prim__ltChar")  (ty [ChType, ChType] IType) 2 (bcBin (<))
    (eOp E.lt_),
   Prim (UN "prim__lteChar") (ty [ChType, ChType] IType) 2 (bcBin (<=))
    (eOp E.lte_),
   Prim (UN "prim__gtChar")  (ty [ChType, ChType] IType) 2 (bcBin (>))
    (eOp E.gt_),
   Prim (UN "prim__gteChar") (ty [ChType, ChType] IType) 2 (bcBin (>=))
    (eOp E.gte_),
   Prim (UN "prim__addBigInt") (ty [BIType, BIType] BIType) 2 (bBin (+))
    (eOpFn tyBigInt tyBigInt "addBig"),
   Prim (UN "prim__subBigInt") (ty [BIType, BIType] BIType) 2 (bBin (-))
    (eOpFn tyBigInt tyBigInt "subBig"),
   Prim (UN "prim__mulBigInt") (ty [BIType, BIType] BIType) 2 (bBin (*))
    (eOpFn tyBigInt tyBigInt "mulBig"),
   Prim (UN "prim__divBigInt") (ty [BIType, BIType] BIType) 2 (bBin (div))
    (eOpFn tyBigInt tyBigInt "divBig"),
   Prim (UN "prim__eqBigInt")  (ty [BIType, BIType] IType) 2 (bbBin (==))
    (eOpFn tyBigInt tyInt "eqBig"),
   Prim (UN "prim__ltBigInt")  (ty [BIType, BIType] IType) 2 (bbBin (<))
    (eOpFn tyBigInt tyInt "ltBig"),
   Prim (UN "prim__lteBigInt")  (ty [BIType, BIType] IType) 2 (bbBin (<=))
    (eOpFn tyBigInt tyInt "leBig"),
   Prim (UN "prim__gtBigInt")  (ty [BIType, BIType] IType) 2 (bbBin (>))
    (eOpFn tyBigInt tyInt "gtBig"),
   Prim (UN "prim__gtBigInt")  (ty [BIType, BIType] IType) 2 (bbBin (>=))
    (eOpFn tyBigInt tyInt "geBig"),
   Prim (UN "prim__addFloat") (ty [FlType, FlType] FlType) 2 (fBin (+))
    (eOp E.plusF_),
   Prim (UN "prim__subFloat") (ty [FlType, FlType] FlType) 2 (fBin (-))
    (eOp E.minusF_),
   Prim (UN "prim__mulFloat") (ty [FlType, FlType] FlType) 2 (fBin (*))
    (eOp E.timesF_),
   Prim (UN "prim__divFloat") (ty [FlType, FlType] FlType) 2 (fBin (/))
    (eOp E.divideF_),
   Prim (UN "prim__eqFloat")  (ty [FlType, FlType] IType) 2 (bfBin (==))
    (eOp E.eqF_),
   Prim (UN "prim__ltFloat")  (ty [FlType, FlType] IType) 2 (bfBin (<))
    (eOp E.ltF_),
   Prim (UN "prim__lteFloat") (ty [FlType, FlType] IType) 2 (bfBin (<=))
    (eOp E.lteF_),
   Prim (UN "prim__gtFloat")  (ty [FlType, FlType] IType) 2 (bfBin (>))
    (eOp E.gtF_),
   Prim (UN "prim__gteFloat") (ty [FlType, FlType] IType) 2 (bfBin (>=))
    (eOp E.gteF_),
   Prim (UN "prim__concat") (ty [StrType, StrType] StrType) 2 (sBin (++))
    ([E.name "x", E.name "y"], (fun "append") @@ fun "x" @@ fun "y"),
   Prim (UN "prim__eqString") (ty [StrType, StrType] IType) 2 (bsBin (==))
    ([E.name "x", E.name "y"], strEq (fun "x") (fun "y")),
   Prim (UN "prim__ltString") (ty [StrType, StrType] IType) 2 (bsBin (<))
    ([E.name "x", E.name "y"], strLt (fun "x") (fun "y")),
    -- Conversions
   Prim (UN "prim__strToInt") (ty [StrType] IType) 1 (c_strToInt)
    ([E.name "x"], strToInt (fun "x")),
   Prim (UN "prim__intToStr") (ty [IType] StrType) 1 (c_intToStr)
    ([E.name "x"], intToStr (fun "x")),
   Prim (UN "prim__intToBigInt") (ty [IType] BIType) 1 (c_intToBigInt)
    ([E.name "x"], intToBigInt (fun "x")),
   Prim (UN "prim__strToBigInt") (ty [StrType] BIType) 1 (c_strToBigInt)
    ([E.name "x"], strToBigInt (fun "x")),
   Prim (UN "prim__bigIntToStr") (ty [BIType] StrType) 1 (c_bigIntToStr)
    ([E.name "x"], bigIntToStr (fun "x")),
   Prim (UN "prim__strToFloat") (ty [StrType] FlType) 1 (c_strToFloat)
    ([E.name "x"], strToFloat (fun "x")),
   Prim (UN "prim__floatToStr") (ty [FlType] StrType) 1 (c_floatToStr)
    ([E.name "x"], floatToStr (fun "x")),
   Prim (UN "prim__intToFloat") (ty [IType] FlType) 1 (c_intToFloat)
    ([E.name "x"], intToFloat (fun "x")),
   Prim (UN "prim__floatToInt") (ty [FlType] IType) 1 (c_floatToInt)
    ([E.name "x"], floatToInt (fun "x")),
   Prim (UN "prim__floatExp") (ty [FlType] FlType) 1 (p_floatExp)
    ([E.name "x"], floatExp (fun "x")), 
   Prim (UN "prim__floatLog") (ty [FlType] FlType) 1 (p_floatLog)
    ([E.name "x"], floatLog (fun "x")),
   Prim (UN "prim__strHead") (ty [StrType] ChType) 1 (p_strHead)
    ([E.name "x"], strHead (fun "x")),
   Prim (UN "prim__strTail") (ty [StrType] StrType) 1 (p_strTail)
    ([E.name "x"], strTail (fun "x")),
   Prim (UN "prim__strCons") (ty [ChType, StrType] StrType) 2 (p_strCons)
    ([E.name "x", E.name "xs"], strCons (fun "x") (fun "xs")),
   Prim (UN "prim__strIndex") (ty [StrType, IType] ChType) 2 (p_strIndex)
    ([E.name "x", E.name "i"], strIndex (fun "x") (fun "i")),
   Prim (UN "prim__strRev") (ty [StrType] StrType) 1 (p_strRev)
    ([E.name "x"], strRev (fun "x"))
  ]

iBin op [VConstant (I x), VConstant (I y)] = Just $ VConstant (I (op x y))
iBin _ _ = Nothing

bBin op [VConstant (BI x), VConstant (BI y)] = Just $ VConstant (BI (op x y))
bBin _ _ = Nothing

bBini op [VConstant (BI x), VConstant (BI y)] = Just $ VConstant (I (op x y))
bBini _ _ = Nothing

biBin op = iBin (\x y -> if (op x y) then 1 else 0)
bbBin op = bBini (\x y -> if (op x y) then 1 else 0)

fBin op [VConstant (Fl x), VConstant (Fl y)] = Just $ VConstant (Fl (op x y))
fBin _ _ = Nothing

bfBin op [VConstant (Fl x), VConstant (Fl y)] = let i = (if op x y then 1 else 0) in
                                                Just $ VConstant (I i)
bfBin _ _ = Nothing

bcBin op [VConstant (Ch x), VConstant (Ch y)] = let i = (if op x y then 1 else 0) in
                                                Just $ VConstant (I i)
bcBin _ _ = Nothing

bsBin op [VConstant (Str x), VConstant (Str y)] 
    = let i = (if op x y then 1 else 0) in
          Just $ VConstant (I i)
bsBin _ _ = Nothing

sBin op [VConstant (Str x), VConstant (Str y)] = Just $ VConstant (Str (op x y))
sBin _ _ = Nothing

c_intToStr [VConstant (I x)] = Just $ VConstant (Str (show x))
c_intToStr _ = Nothing
c_strToInt [VConstant (Str x)] = Just $ VConstant (I (read x))
c_strToInt _ = Nothing

c_intToBigInt [VConstant (I x)] = Just $ VConstant (BI (fromIntegral x))
c_intToBigInt _ = Nothing

c_bigIntToStr [VConstant (BI x)] = Just $ VConstant (Str (show x))
c_bigIntToStr _ = Nothing
c_strToBigInt [VConstant (Str x)] = Just $ VConstant (BI (read x))
c_strToBigInt _ = Nothing

c_floatToStr [VConstant (Fl x)] = Just $ VConstant (Str (show x))
c_floatToStr _ = Nothing
c_strToFloat [VConstant (Str x)] = Just $ VConstant (Fl (read x))
c_strToFloat _ = Nothing

c_floatToInt [VConstant (Fl x)] = Just $ VConstant (I (truncate x))
c_floatToInt _ = Nothing

c_intToFloat [VConstant (I x)] = Just $ VConstant (Fl (fromIntegral x))
c_intToFloat _ = Nothing

p_floatExp [VConstant (Fl x)] = Just $ VConstant (Fl (exp x))
p_floatExp _ = Nothing
p_floatLog [VConstant (Fl x)] = Just $ VConstant (Fl (log x))
p_floatLog _ = Nothing

p_strHead [VConstant (Str (x:xs))] = Just $ VConstant (Ch x)
p_strHead _ = Nothing
p_strTail [VConstant (Str (x:xs))] = Just $ VConstant (Str xs)
p_strTail _ = Nothing
p_strIndex [VConstant (Str xs), VConstant (I i)] 
   | i < length xs = Just $ VConstant (Ch (xs!!i))
p_strIndex _ = Nothing
p_strCons [VConstant (Ch x), VConstant (Str xs)] = Just $ VConstant (Str (x:xs))
p_strCons _ = Nothing
p_strRev [VConstant (Str xs)] = Just $ VConstant (Str (reverse xs))
p_strRev _ = Nothing

elabPrim :: Prim -> Idris ()
elabPrim (Prim n ty i def epic) 
    = do updateContext (addOperator n ty i def)
         i <- getIState
         putIState i { idris_prims = (n, epic) : idris_prims i }

elabPrims :: Idris ()
elabPrims = do mapM_ (elabDecl toplevel) 
                     (map (PData defaultSyntax (FC "builtin" 0))
                         [inferDecl, unitDecl, falseDecl, pairDecl, eqDecl])
               mapM_ elabPrim primitives

