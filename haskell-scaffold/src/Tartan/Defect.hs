module Tartan.Defect
  ( scalarNorm
  , velocityMagnitudeMean
  , rsvpNorm
  , rsvpDiff
  , allDefects
  , totalDefect
  ) where

import qualified Data.Vector as V
import Tartan.Grid
import Tartan.Overlap (extractOverlapFromTile)
import Tartan.Types
import Tartan.Tile (zipScalar)

scalarNorm :: Grid -> ScalarField -> Double
scalarNorm Grid{gWidth, gHeight} (ScalarField v) =
  let s = V.sum (V.map (\x -> x * x) v)
      n = fromIntegral (max 1 (gWidth * gHeight))
  in sqrt (s / n)

velocityMagnitudeMean :: Grid -> VectorField -> Double
velocityMagnitudeMean Grid{gWidth, gHeight} vf =
  let ScalarField vx = vxField vf
      ScalarField vy = vyField vf
      mags = V.zipWith (\a b -> sqrt (a*a + b*b)) vx vy
      n = fromIntegral (max 1 (gWidth * gHeight))
  in V.sum mags / n

rsvpNorm :: Grid -> RSVP -> Double
rsvpNorm gr st =
  scalarNorm gr (phiField st)
  + scalarNorm gr (vxField (velField st))
  + scalarNorm gr (vyField (velField st))
  + scalarNorm gr (entField st)

rsvpDiff :: RSVP -> RSVP -> RSVP
rsvpDiff a b = RSVP
  { phiField = zipScalar (-) (phiField a) (phiField b)
  , velField = VectorField
      (zipScalar (-) (vxField (velField a)) (vxField (velField b)))
      (zipScalar (-) (vyField (velField a)) (vyField (velField b)))
  , entField = zipScalar (-) (entField a) (entField b)
  }

computeDefect :: Grid -> [Tile] -> Overlap -> Defect
computeDefect worldGr tiles ov =
  let lTile = tiles !! ovLeft ov
      rTile = tiles !! ovRight ov
      lSt = extractOverlapFromTile worldGr lTile (ovRect ov)
      rSt = extractOverlapFromTile worldGr rTile (ovRect ov)
      ovGr = Grid (rw (ovRect ov)) (rh (ovRect ov))
      dSt = rsvpDiff lSt rSt
      phiD = scalarNorm ovGr (phiField dSt)
      velD = velocityMagnitudeMean ovGr (velField dSt)
      entD = scalarNorm ovGr (entField dSt)
  in Defect
      { defectLeft = ovLeft ov
      , defectRight = ovRight ov
      , defectPhi = phiD
      , defectVelocity = velD
      , defectEntropy = entD
      , defectMagnitude = phiD + velD + entD
      }

allDefects :: Grid -> [Tile] -> [Overlap] -> [Defect]
allDefects gr ts ovs = map (computeDefect gr ts) ovs

totalDefect :: [Defect] -> Double
totalDefect = sum . map defectMagnitude
