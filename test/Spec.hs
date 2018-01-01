{-# OPTIONS_GHC -fno-warn-type-defaults #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE QuasiQuotes       #-}
import           Protolude

import           Test.Tasty
import           Test.Tasty.HUnit

import           Jsq.Query

import           Data.Aeson        (Value (..))
import qualified Data.Vector       as Vector
import qualified Data.HashMap.Lazy as HashMap

import           Text.RawString.QQ (r)

main :: IO ()
main = defaultMain tests

tests :: TestTree
tests = testGroup "Tests" [unitTests]

unitTests :: TestTree
unitTests = testGroup "Unit tests"
  [
    testCase "query - no filter" $
      queryStream "." "[1, 2, 3]" @?= [(Array $ Vector.fromList $ map Number [1, 2, 3])]

    , testCase "query - enumerate elements of a list" $
      queryStream ".[]" "[1, 2, 3]" @?= map Number [1, 2, 3]

    , testCase "query - access element of a list by index" $
      queryStream ".[1]" "[1, 2, 3]" @?= map Number [2]

    , testCase "query - simple selection within elements of a list" $
      queryStream
        ".[].one"
        [r| [{"one": 1, "two": 11}, {"one": 2, "two": 22}] |]
      @?= map Number [1, 2]

    , testCase "folding - simple output folding" $
      map (foldValue 1) (queryStream ".[]"
        [r|[
          {
            "subobject": {"one": "two"},
            "subarray": ["one", "two"],
            "value": "one",
            "nullvalue": null,
            "empty-subarray": []
          }
        ]|])
      @?= [Object $ HashMap.fromList [
                ("subobject", String "{...}"),
                ("subarray", String "[...]"),
                ("value", String "one"),
                ("nullvalue", Null),
                ("empty-subarray", Array Vector.empty)
              ]
          ]
  ]
