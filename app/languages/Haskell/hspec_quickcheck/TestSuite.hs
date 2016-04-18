module TestSuite where

import Test.Hspec

import HeadSpec (headSpec)

main :: IO ()
main = hspec headSpec 

