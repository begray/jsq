{-
Module: Jsq.Query
Description: JSON stream querying
-}

{-# LANGUAGE NamedFieldPuns    #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE QuasiQuotes       #-}

module Jsq.Query(
  executeQuery,
  queryStream,
  foldValue
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
import qualified Data.HashMap.Lazy      as HashMap
import qualified Data.Text              as T
import qualified Data.Vector            as Vector
import qualified Data.Yaml              as Yaml

-- | execute query from config on lazy input and print output to console
executeQuery :: Config -> BSL.ByteString -> IO ()
executeQuery Config{query, depth, yamlOutput} input = do
  let encodeValue :: Aeson.Value -> BSL.ByteString
      encodeValue = case yamlOutput of
        True  -> BSL.fromStrict . Yaml.encode
        False -> Aeson.encode

      foldValue_ = case depth of
        Just d  -> foldValue d
        Nothing -> identity

  mapM_ (putStrLn . encodeValue . foldValue_) $ queryStream query input

-- | fold value at a specified level of structure
foldValue :: Int -> Aeson.Value -> Aeson.Value
foldValue 0 arr@(Aeson.Array vec)
  | Vector.null vec = arr
  | otherwise = Aeson.String "[...]"
foldValue 0 obj@(Aeson.Object props) 
  | HashMap.null props = obj
  | otherwise = Aeson.String "{...}"
foldValue d (Aeson.Array v) = Aeson.Array $ fmap (foldValue (d-1)) v
foldValue d (Aeson.Object h) = Aeson.Object $ fmap (foldValue (d-1)) h
foldValue _ v = v

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
