{-# LANGUAGE NamedFieldPuns    #-}
{-# LANGUAGE OverloadedStrings #-}

module Main where

import           Protolude

import qualified Data.ByteString.Lazy as BSL

import qualified Options.Applicative  as Options

import           Jsq.Options          (Config (..), config)
import           Jsq.Query            (executeQuery)

main :: IO ()
main = runQuery =<< Options.execParser opts
  where
    opts = Options.info (config <**> Options.helper)
           (
             Options.fullDesc
               <> Options.progDesc "Run QUERY against JSON stream"
               <> Options.header "jsq - JSON stream processor"
           )

runQuery :: Config -> IO ()
-- | run query on stdin
runQuery cfg@Config{inputFilePaths = []} = do
  input <- BSL.getContents
  executeQuery cfg input

-- | run query on files
runQuery cfg@Config{inputFilePaths} = do
  input <- mapM BSL.readFile inputFilePaths
  mapM_ (executeQuery cfg) input
