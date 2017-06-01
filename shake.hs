#!/usr/bin/env stack
{- stack --resolver lts-8.16 --install-ghc
    runghc
    --package shake
    --package directory
-}

import Development.Shake
import Development.Shake.Config
import System.Directory
import Data.Maybe
import Data.Monoid

main :: IO ()
main = shakeArgs shakeOptions { shakeFiles = ".shake", shakeLint = Just LintBasic, shakeProgress = progressSimple } $ do

    usingConfigFile "config/build.cfg"

    want [ "target/launcher"
         ]

    "install" ~> do
        home <- fromMaybe "" <$> getEnv "HOME"
        putNormal "writing to ~/.local/bin..."
        cmd ["cp","target/launcher", home <> "/.local/bin/"]

    "clean" ~> do
        putNormal "cleaning files..." 
        removeFilesAfter "target" ["//*"]
        removeFilesAfter ".nim" ["//*"]

    "run" ~> do
        need ["target/launcher"]
        command [] "./target/launcher" []

    "configure" ~> do
        source <- (read :: String -> [String]) . fromMaybe [] <$> getConfig "LIB_DEPENDS"
        putNormal "installing dependencies..."
        mapM_ (\str -> command_ [] "nimble" ["install", str]) source

    ".nim/launcher.nim" %> \out -> do
        source <- fromMaybe "src" <$> getConfig "SRC_DIR"
        need [ source <> "/launcher.nim"]
        liftIO $ createDirectoryIfMissing True ".nim"
        cmd (Cwd ".nim") ["cp", "-r", "../" <> source <> "/launcher.nim", "."]

    ".nim/launcher" %> \out -> do
        source <- fromMaybe "src" <$> getConfig "SRC_DIR"
        need [ source <> "/launcher.nim", ".nim/launcher.nim" ]
        options <- (read :: String -> [String]) . fromMaybe [] <$> getConfig "NIM_OPT"
        -- the environment variable fixes a bug building nimx with an older version of nim
        cmd (AddEnv "NIMX_RES_PATH" "123") (Cwd ".nim") (["nim", "c"] <> options <> ["launcher.nim"])

    "target/launcher" %> \out -> do
        source <- fromMaybe "src" <$> getConfig "SRC_DIR"
        need [ source <> "/launcher.nim", ".nim/launcher.nim", ".nim/launcher"]
        liftIO $ createDirectoryIfMissing True "target"
        cmd ["ln", "-f", ".nim/launcher", "target/launcher"]
