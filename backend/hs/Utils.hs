module Utils (module Utils, module Unique) where

import Data.List (find)
import qualified Data.Map as M
import Control.Lens

import Unique

fromJust :: String -> Maybe a -> a
fromJust _ (Just a) = a
fromJust msg Nothing = error msg

-- A version of the ix lens that errors out if the value is not there
hardix :: (Ord k) => String -> k -> Simple Lens (M.Map k a) a
hardix msg k = lens find replace where
    find = fromJust msg . M.lookup k
    replace m a = case M.lookup k m of
                    (Just _) -> M.insert k a m
                    Nothing -> error msg

-- Suitable for counting with Data.Map.alter
maybeSucc :: Num a => Maybe a -> Maybe a
maybeSucc Nothing = Just 1
maybeSucc (Just x) = Just $ x+1

embucket :: (Num a, Ord b) => [(b, b)] -> [b] -> M.Map (b, b) a
embucket buckets values = foldl insert M.empty values where
    insert m v = case find (v `isInside`) buckets of
                   (Just b) -> M.alter maybeSucc b m
                   Nothing -> m
    isInside v (low,high) = low <= v && v < high

buckets :: Int -> [Double] -> [(Double,Double)]
buckets ct values = zip lows (tail lows ++ [high+0.01]) where
    low = minimum values
    high = maximum values
    step = (high - low) / fromIntegral ct
    lows = [low,low+step..high]

histogram :: Int -> [Double] -> M.Map (Double,Double) Int
histogram ct values = embucket (buckets ct values) values where

-- TODO Check this with quickcheck (constraining ct to be positive)
-- See, e.g. http://stackoverflow.com/questions/3120796/haskell-testing-workflow
property_histogram_conserves_data :: Int -> [Double] -> Bool
property_histogram_conserves_data ct values = length values == (sum $ M.elems $ histogram ct values)
