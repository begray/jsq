{-
Module: Jsq.Query
Description: JSON stream querying
-}

{-# LANGUAGE NamedFieldPuns    #-}
{-# LANGUAGE OverloadedStrings #-}

module Jsq.Query(
  executeQuery,
  queryStream
)
where

import           Data.JsonStream.Parser
import           Jsq.Options
import           Protolude

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

    combo :: Text -> Parser a -> Parser a
    combo t p = case t of
      ""   -> p
      "[]" -> arrayOf p
      str  -> objectWithKey str p

    parser :: Parser Aeson.Value
    parser = foldr combo value tokens
