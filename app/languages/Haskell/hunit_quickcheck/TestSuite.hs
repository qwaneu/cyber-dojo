module TestSuite where

import Test.Hspec

import HeadSpecs (headSpecs)

main :: IO ()
main = hspec headSpecs 

