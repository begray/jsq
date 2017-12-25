{-
Module: Jsq.Query
Description: JSON stream querying
-}

{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE NamedFieldPuns #-}

module Jsq.Query(
  executeQuery
)
where

import           Data.JsonStream.Parser
import           Jsq.Options
import           Protolude

import qualified Data.Aeson             as Aeson
import qualified Data.ByteString.Lazy   as BSL
import qualified Data.Text              as T
import qualified Data.Yaml              as Yaml

-- | execute query from config on lazy input
executeQuery :: Config -> BSL.ByteString -> IO ()
executeQuery Config{query, yamlOutput} input = do
  let tokens = T.splitOn "." query

      combo :: Text -> Parser a -> Parser a
      combo t p = case t of
        ""   -> p
        "[]" -> arrayOf p
        str  -> objectWithKey str p

      parser1 :: Parser Aeson.Value
      parser1 = foldr combo value tokens

      encodeOutput :: Aeson.Value -> BSL.ByteString
      encodeOutput = case yamlOutput of
        True -> BSL.fromStrict . Yaml.encode
        False -> Aeson.encode

  mapM_ (putStrLn . encodeOutput) (parseLazyByteString parser1 input)
