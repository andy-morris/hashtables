{-# LANGUAGE BangPatterns #-}
{-# LANGUAGE CPP          #-}
#ifdef UNSAFETRICKS
{-# LANGUAGE MagicHash    #-}
#endif

module Data.HashTable.Internal.UnsafeTricks
  ( Key
  , toKey
  , fromKey
  , emptyRecord
  , keyIsEmpty
  , makeEmptyVector
  ) where

import           Control.Monad.Primitive
import           Data.Vector.Mutable (MVector)
import qualified Data.Vector.Mutable as M
#ifdef UNSAFETRICKS
import           GHC.Exts
import           Unsafe.Coerce
#endif


------------------------------------------------------------------------------
#ifdef UNSAFETRICKS
type Key a = Any
#else
data Key a = Key !a
           | EmptyElement
#endif


------------------------------------------------------------------------------
-- Type signatures
emptyRecord :: Key a
keyIsEmpty :: Key a -> Bool
makeEmptyVector :: PrimMonad m => Int -> m (MVector (PrimState m) (Key a))
toKey :: a -> Key a
fromKey :: Key a -> a


#ifdef UNSAFETRICKS
data TombStone = EmptyElement
               | DeletedElement

{-# NOINLINE emptyRecord #-}
emptyRecord = unsafeCoerce EmptyElement

{-# INLINE keyIsEmpty #-}
keyIsEmpty a = x# ==# 1#
  where
    !x# = reallyUnsafePtrEquality# a emptyRecord

{-# INLINE toKey #-}
toKey = unsafeCoerce

{-# INLINE fromKey #-}
fromKey = unsafeCoerce

#else

emptyRecord = EmptyElement

keyIsEmpty EmptyElement = True
keyIsEmpty _            = False

toKey = Key

fromKey (Key x) = x
fromKey _ = error "impossible"

#endif


------------------------------------------------------------------------------
{-# INLINE makeEmptyVector #-}
makeEmptyVector m = M.replicate m emptyRecord
