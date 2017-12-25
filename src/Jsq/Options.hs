{-
Module: Jsq.Options
Description: parsing options of jsq
-}

module Jsq.Options(
  Config(..),
  config
) where

import           Options.Applicative
import           Protolude

data Config = Config {
  yamlOutput     :: Bool,
  query          :: Text,
  inputFilePaths :: [FilePath]
}

config :: Parser Config
config =
  Config
  <$> switch (
        short 'y'
        <> long "yaml"
      )
  <*> argument str (
        metavar "QUERY"
      )
  <*> many (
        argument str (
              metavar "FILE"
        )
      )

