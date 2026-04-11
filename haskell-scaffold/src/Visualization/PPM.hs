module Visualization.PPM
  ( writeSnapshot
  ) where

import qualified Data.Vector as V
import System.Directory (createDirectoryIfMissing)
import System.FilePath ((</>))
import Text.Printf (printf)
import Tartan.Grid
import Tartan.Types

writePPM :: FilePath -> Int -> Int -> (Int -> Int -> (Int, Int, Int)) -> IO ()
writePPM path w h pixel = do
  let header = "P3\n" ++ show w ++ " " ++ show h ++ "\n255\n"
      row y = unwords [ let (r,g,b) = pixel x y in unwords [show r, show g, show b] | x <- [0 .. w - 1] ]
      body = unlines [row y | y <- [0 .. h - 1]]
  writeFile path (header ++ body)

normalizeVector :: V.Vector Double -> V.Vector Double
normalizeVector v
  | V.null v = v
  | otherwise =
      let mn = V.minimum v
          mx = V.maximum v
      in if mx == mn then V.map (const 0) v else V.map (\x -> (x - mn) / (mx - mn)) v

scalarToPPM :: Grid -> ScalarField -> FilePath -> IO ()
scalarToPPM gr@(Grid w h) (ScalarField v) path = do
  let nv = normalizeVector v
      pixel x y =
        let val = nv V.! index2D gr x y
            c = floor (255 * val)
        in (c, c, c)
  writePPM path w h pixel

vectorMagToPPM :: Grid -> VectorField -> FilePath -> IO ()
vectorMagToPPM gr@(Grid w h) vf path = do
  let ScalarField vx = vxField vf
      ScalarField vy = vyField vf
      mags = normalizeVector (V.zipWith (\a b -> sqrt (a*a + b*b)) vx vy)
      pixel x y =
        let val = mags V.! index2D gr x y
            c = floor (255 * val)
        in (c, c, 255 - c)
  writePPM path w h pixel

writeSnapshot :: FilePath -> Int -> Grid -> RSVP -> IO ()
writeSnapshot outDir step gr st = do
  createDirectoryIfMissing True outDir
  let stem = printf "frame_%03d" step
  scalarToPPM gr (phiField st) (outDir </> (stem ++ "_phi.ppm"))
  scalarToPPM gr (entField st) (outDir </> (stem ++ "_entropy.ppm"))
  vectorMagToPPM gr (velField st) (outDir </> (stem ++ "_velocity.ppm"))
