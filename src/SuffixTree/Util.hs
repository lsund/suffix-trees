
module SuffixTree.Util where

import           Data.Char     (chr)
import qualified Data.Text     as T
import           Prelude       (String)
import           Protolude
import           System.Random

randString :: Int -> IO String
randString n = do
    g <- newStdGen
    let cs = take n $ randoms g :: [Int]
    return $ map (\x -> chr . (+65) . abs $ x `mod` 26) cs


tail :: [a] -> [a]
tail []       = []
tail (_ : xs) = xs

removeHeads :: [[a]] -> [[a]]
removeHeads []              = []
removeHeads([] : xss)       = removeHeads xss
removeHeads((_ : xs) : xss) = xs : removeHeads xss

fst3 :: (a, b, c) -> a
fst3 (x, _, _) = x


headEq :: Eq a => a -> [a] -> Bool
headEq a (c : _) = c == a
headEq _ []      = False


removeDuplicates :: Text -> Text
removeDuplicates ""  =  ""
removeDuplicates t   =  x `T.cons` removeDuplicates withoutX
    where x = T.head t
          withoutX = T.filter (\y -> not (x == y)) (T.tail t)


listify :: (a, a) -> [a]
listify (a, b) = [a, b]


allStartsWith :: Eq a => a -> [[a]] -> Bool
allStartsWith c ((x : _) : xss) = x == c && allStartsWith c xss
allStartsWith _ []              = True
allStartsWith _ [[]]            = True
allStartsWith c ([] : xss)        = allStartsWith c xss