
module Algorithm.LazyTree.Functional where

import           Prelude         (String, init)
import           Protolude

import           Data.SuffixTree
import           Util

-------------------------------------------------------------------------------
-- Atomic Suffix Tree


edgeAST :: Eq a => EdgeFunction a
edgeAST xs = (0, xs)


-------------------------------------------------------------------------------
-- Position Suffix Tree


-- Takes a list of suffixes and removes the ones that occur in other suffixes
removeNested :: (Eq a) => [[a]] -> [[a]]
removeNested []                      = []
removeNested ([] : _ : _ )           = []
removeNested [s]                     = [s]
removeNested suffix@((x : xs) : xss)
    | (not . any (headEq x)) xss     = map tail removed
    | otherwise                      = suffix
        where
            removed                  = removeNested (xs : map tail xss)


edgePST :: Eq a => EdgeFunction a
edgePST = pstSplit . removeNested
    where
        pstSplit [x] = (length x, [[]])
        pstSplit xs  = (0, xs)


-------------------------------------------------------------------------------
-- Compact Suffix Tree: Extracts the largest common suffix for each branch


edgeCST :: Eq a => EdgeFunction a
-- edgeCST []                      = (-1, [[]])
-- edgeCST ([] : _ : _ )           = (-1, [[]])
edgeCST [s]                     = (length s, [[]])
edgeCST suffix@((x : xs) : xss)
  | allStartsWith x xss         = (succ lcp, xs')
  | otherwise                   = (0, suffix)
    where
        (lcp, xs')              = edgeCST (xs : map tail xss)
        allStartsWith c         = null . filter (not . headEq c)


-------------------------------------------------------------------------------
-- Functional LazyTree


lazyTree :: Eq a => EdgeFunction a -> Alphabet a -> [a] -> STree2 a
lazyTree edgeFun as x = lazyTree' (length x) (init $ tails x)
    where
        lazyTree' i [[]]     = Leaf2 i
        lazyTree' i suffixes = Branch2 (foldl (addEdge i suffixes) [] as)
        addEdge i suffixes edges a =
            let
                suffixGroup  = groupSuffixes a suffixes
                (lcp, rests) = edgeFun suffixGroup
            in
                case suffixGroup of
                    (mark : _) -> makeEdge mark lcp rests : edges
                    []         -> edges
            where
                groupSuffixes c         = map tail . filter (headEq c)
                newLabel mark lcp       = Label2 (a : mark) (succ lcp)
                descendTree lcp         = lazyTree' (i - succ lcp)
                makeEdge mark lcp rests = Edge2 (newLabel mark lcp)
                                                (descendTree lcp rests)

-------------------------------------------------------------------------------
-- Public API

lazyAST :: Eq a => [a] -> [a] -> STree2 a
lazyAST = lazyTree edgeAST

lazyPST :: Eq a => [a] -> [a] -> STree2 a
lazyPST = lazyTree edgePST

lazyCST :: Eq a => [a] -> [a] -> STree2 a
lazyCST = lazyTree edgeCST

