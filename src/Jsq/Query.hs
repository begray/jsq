{-
Module: Jsq.Query
Description: JSON stream querying
-}

{-# LANGUAGE NamedFieldPuns    #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE QuasiQuotes       #-}

module Jsq.Query(
  executeQuery,
  queryStream
)
where

import           Data.Either            (fromRight)
import           Data.JsonStream.Parser
import           Data.Text.Read         (decimal)
import           Jsq.Options
import           Protolude
import           Text.RE.TDFA           (re, (=~))

import qualified Data.Aeson             as Aeson
import qualified Data.ByteString.Lazy   as BSL
import qualified Data.Text              as T
import qualified Data.Yaml              as Yaml

-- | execute query from config on lazy input and print output to console
executeQuery :: Config -> BSL.ByteString -> IO ()
executeQuery Config{query, yamlOutput} input = do
  let encodeValue :: Aeson.Value -> BSL.ByteString
      encodeValue = case yamlOutput of
        True  -> BSL.fromStrict . Yaml.encode
        False -> Aeson.encode

  mapM_ (putStrLn . encodeValue) $ queryStream query input

-- | execute a query on a stream and return a list of results
queryStream :: Text -> BSL.ByteString -> [Aeson.Value]
queryStream query stream =
    parseLazyByteString parser stream
  where
    tokens = T.splitOn "." query

    textToInt :: Text -> Int
    textToInt t = fst $ fromRight (0, "") (decimal t)

    combo :: Text -> Parser a -> Parser a
    combo t p
      | t == "" = p
      | t == "[]" = arrayOf p
      | [_,i]:_ <- (t =~ [re|\[([0-9]+)\]|]) = arrayWithIndexOf (textToInt i) p
      | otherwise  = objectWithKey t p

    parser :: Parser Aeson.Value
    parser = foldr combo value tokens
