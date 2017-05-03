#!/usr/bin/env stack
{- stack --resolver lts-8.12 --install-ghc
    runghc
    --package shake
    --package directory
-}
{-# LANGUAGE DataKinds #-}

import Development.Shake
import Development.Shake.Config
import System.Directory
import Data.Maybe
import Data.Monoid

main :: IO ()
main = shakeArgs shakeOptions { shakeFiles = ".shake", shakeLint = Just LintBasic } $ do
    usingConfigFile "config/build.cfg"

    want [ "target/main"
         ]

    "clean" ~> do
        putNormal "cleaning files..." 
        removeFilesAfter ".nim" ["//*"]

    "run" ~> do
        need ["target/main"]
        command [] "./target/main" []

    "configure" ~> do
        source <- (read :: String -> [String]) . fromMaybe [] <$> getConfig "LIB_DEPENDS"
        putNormal "installing dependencies..."
        mapM_ (\str -> command_ [] "nimble" ["install", str]) source

    ".nim/main.nim" %> \out -> do
        liftIO $ createDirectoryIfMissing True ".nim"
        source <- fromMaybe "src" <$> getConfig "SRC_DIR"
        cmd (Cwd ".nim") ["cp", "-r", "../" <> source <> "/main.nim", "."]

    ".nim/main" %> \out -> do
        need [".nim/main.nim"]
        options <- (read :: String -> [String]) . fromMaybe [] <$> getConfig "NIM_OPT"
        -- the environment variable fixes a bug building nimx with an older version of nim
        cmd (AddEnv "NIMX_RES_PATH" "123") (Cwd ".nim") (["nim", "c"] <> options <> ["main.nim"])

    "target/main" %> \out -> do
        need [".nim/main"]
        liftIO $ createDirectoryIfMissing True "target"
        cmd ["ln", "-f", ".nim/main", "target/main"]
