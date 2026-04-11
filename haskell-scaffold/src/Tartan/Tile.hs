module Tartan.Tile
  ( zerosScalar
  , mkScalar
  , readScalar
  , writeScalar
  , mapScalar
  , zipScalar
  , zerosVector
  , zerosRSVP
  , extractScalarRect
  , extractRSVPRect
  , embedScalarAverage
  , embedRSVPAverage
  , initTilesFromTruth
  ) where

import qualified Data.Vector as V
import Data.Vector (Vector)
import Tartan.Grid
import Tartan.Types

zerosScalar :: Grid -> ScalarField
zerosScalar Grid{gWidth, gHeight} = ScalarField $ V.replicate (gWidth * gHeight) 0.0

mkScalar :: Grid -> (Int -> Int -> Double) -> ScalarField
mkScalar gr@Grid{gWidth, gHeight} f =
  ScalarField $ V.generate (gWidth * gHeight) $ \k ->
    let (y, x) = k `divMod` gWidth in f x y

readScalar :: Grid -> ScalarField -> Int -> Int -> Double
readScalar gr (ScalarField v) x y = v V.! index2D gr x y

writeScalar :: Grid -> ScalarField -> Int -> Int -> Double -> ScalarField
writeScalar gr (ScalarField v) x y val =
  ScalarField (v V.// [(index2D gr x y, val)])

mapScalar :: (Double -> Double) -> ScalarField -> ScalarField
mapScalar f (ScalarField v) = ScalarField (V.map f v)

zipScalar :: (Double -> Double -> Double) -> ScalarField -> ScalarField -> ScalarField
zipScalar f (ScalarField a) (ScalarField b) = ScalarField (V.zipWith f a b)

zerosVector :: Grid -> VectorField
zerosVector gr = VectorField (zerosScalar gr) (zerosScalar gr)

zerosRSVP :: Grid -> RSVP
zerosRSVP gr = RSVP (zerosScalar gr) (zerosVector gr) (zerosScalar gr)

extractScalarRect :: Grid -> ScalarField -> Rect -> ScalarField
extractScalarRect gr fld Rect{rx, ry, rw, rh} =
  mkScalar (Grid rw rh) $ \x y -> readScalar gr fld (rx + x) (ry + y)

extractRSVPRect :: Grid -> RSVP -> Rect -> RSVP
extractRSVPRect gr st rect =
  RSVP
    { phiField = extractScalarRect gr (phiField st) rect
    , velField = VectorField
        (extractScalarRect gr (vxField (velField st)) rect)
        (extractScalarRect gr (vyField (velField st)) rect)
    , entField = extractScalarRect gr (entField st) rect
    }

embedScalarAverage :: Grid -> ScalarField -> Rect -> ScalarField -> ScalarField
embedScalarAverage gr base Rect{rx, ry, rw, rh} sub =
  foldl step base [(x, y) | y <- [0 .. rh - 1], x <- [0 .. rw - 1]]
  where
    subGr = Grid rw rh
    step acc (x, y) =
      let oldVal = readScalar gr acc (rx + x) (ry + y)
          newVal = readScalar subGr sub x y
      in writeScalar gr acc (rx + x) (ry + y) ((oldVal + newVal) / 2)

embedRSVPAverage :: Grid -> RSVP -> Rect -> RSVP -> RSVP
embedRSVPAverage gr base rect sub =
  RSVP
    { phiField = embedScalarAverage gr (phiField base) rect (phiField sub)
    , velField = VectorField
        (embedScalarAverage gr (vxField (velField base)) rect (vxField (velField sub)))
        (embedScalarAverage gr (vyField (velField base)) rect (vyField (velField sub)))
    , entField = embedScalarAverage gr (entField base) rect (entField sub)
    }

initTilesFromTruth :: Grid -> [Rect] -> RSVP -> [Tile]
initTilesFromTruth gr rects truth = zipWith mk [0..] rects
  where
    mk i rect = Tile i rect (extractRSVPRect gr truth rect)
