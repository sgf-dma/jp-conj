#!/usr/bin/env stack
{- stack
 script
 --resolver lts-11.3
 --package shelly
 --package pandoc
 --package text
 --package system-filepath
 -}
{-# LANGUAGE OverloadedStrings  #-}

import qualified Shelly     as S
import qualified Data.Text  as T
import Data.Maybe
import Control.Monad
import Filesystem.Path.CurrentOS

-- | Match filename according to expected "verb-forms" config file names:
-- "verbs-mX.yaml", where X is lesson number.
vformsConfigs :: S.FilePath -> S.Sh Bool
vformsConfigs p = do
    let (fp, mext) = splitExtension p
    t <- S.toTextWarn (basename fp)
    return ("verbs-m" `T.isPrefixOf` t && fromMaybe False ((== "yaml") <$> mext))

main :: IO ()
main        = do
    S.shelly $ do
      cfs <- S.findWhen vformsConfigs "."
      S.liftIO $ mapM_ print cfs
      -- Regenerate all vforms files.
      S.mkdir_p "vforms"
      forM_ cfs $ \cf -> do
        ct <- S.toTextWarn cf
        S.run_ "verb-forms" ["--config", ct]
      --  Update conjugations.html .
      S.run_ "stack" ["exec", "pandoc", "--"
                     , "-s", "--template=default.html5"
                     , "-f", "markdown+grid_tables"
                     , "-o", "vforms/conjugations.html"
                     , "conjugations.txt"
                     ]
      return ()

