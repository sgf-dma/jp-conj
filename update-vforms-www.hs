#!/usr/bin/env stack
{- stack
 script
 --resolver lts-11.3
 --package shelly
 --package pandoc
 -}
{-# LANGUAGE OverloadedStrings  #-}

import Shelly


main :: IO ()
main        = do
    shelly $ do
      run "k2csv-exe" ["--config", "verbs-m14.yaml"]
      return ()
