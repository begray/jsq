{-
Module: Jsq.Options
Description: parsing options of jsq
-}

module Jsq.Options(
  Config(..),
  config
) where

import           Options.Applicative
import           Protolude hiding (option)

data Config = Config {
  yamlOutput     :: Bool,
  depth          :: Maybe Int,
  query          :: Text,
  inputFilePaths :: [FilePath]
}

config :: Parser Config
config =
  Config
  <$> switch (
        short 'y'
        <> long "yaml"
        <> help "ouput results using YAML"
      )
  <*> optional (
        option auto (
          short 'd'
          <> long "depth"
          <> help "fold structure at specified level of depth"
        )
      )
  <*> argument str (
        metavar "QUERY"
      )
  <*> many (
        argument str (
              metavar "FILE"
        )
      )

