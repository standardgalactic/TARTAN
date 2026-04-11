module Tartan.Repair
  ( scaleScalar
  , scaleRSVP
  , negRSVP
  , addRSVP
  , repairOverlap
  , repairSweepClassified
  ) where

import Data.List (foldl')
import Tartan.Grid
import Tartan.Overlap (extractOverlapFromTile)
import Tartan.Tile
import Tartan.Types
import Tartan.Defect (rsvpDiff)

scaleScalar :: Double -> ScalarField -> ScalarField
scaleScalar a = mapScalar (* a)

absScalar :: ScalarField -> ScalarField
absScalar = mapScalar abs

scaleRSVP :: Double -> RSVP -> RSVP
scaleRSVP a st =
  RSVP
    { phiField = scaleScalar a (phiField st)
    , velField = VectorField
        (scaleScalar a (vxField (velField st)))
        (scaleScalar a (vyField (velField st)))
    , entField = scaleScalar a (entField st)
    }

negRSVP :: RSVP -> RSVP
negRSVP = scaleRSVP (-1)

addRSVP :: RSVP -> RSVP -> RSVP
addRSVP a b = RSVP
  { phiField = zipScalar (+) (phiField a) (phiField b)
  , velField = VectorField
      (zipScalar (+) (vxField (velField a)) (vxField (velField b)))
      (zipScalar (+) (vyField (velField a)) (vyField (velField b)))
  , entField = zipScalar (+) (entField a) (entField b)
  }

applyCorrection :: Grid -> Tile -> Rect -> RSVP -> Tile
applyCorrection _ tile ov corr =
  let tr = tileRect tile
      localRect = Rect
        { rx = rx ov - rx tr
        , ry = ry ov - ry tr
        , rw = rw ov
        , rh = rh ov
        }
      localGr = Grid (rw tr) (rh tr)
      patch = embedRSVPAverage localGr (zerosRSVP localGr) localRect corr
  in tile { tileState = addRSVP (tileState tile) patch }

entropyLift :: Double -> RSVP -> RSVP
entropyLift a st = RSVP
  { phiField = scaleScalar 0 (phiField st)
  , velField = VectorField (scaleScalar 0 (vxField (velField st))) (scaleScalar 0 (vyField (velField st)))
  , entField = scaleScalar a (absScalar (entField st))
  }

repairOverlap :: Double -> Grid -> Tile -> Tile -> Rect -> (Tile, Tile)
repairOverlap alpha worldGr t1 t2 ov =
  let local1 = extractOverlapFromTile worldGr t1 ov
      local2 = extractOverlapFromTile worldGr t2 ov
      scaled = scaleRSVP alpha (rsvpDiff local1 local2)
      t1' = applyCorrection worldGr t1 ov (negRSVP scaled)
      t2' = applyCorrection worldGr t2 ov scaled
  in (t1', t2')

updateTiles :: [Tile] -> Int -> Tile -> Int -> Tile -> [Tile]
updateTiles ts i ti j tj =
  [ if k == i then ti else if k == j then tj else t
  | (k, t) <- zip [0..] ts
  ]

repairSweepClassified :: Double -> Grid -> [Tile] -> [Overlap] -> [ClassifiedDefect] -> [Tile]
repairSweepClassified alpha gr ts ovs cds =
  foldl' step ts (zip ovs cds)
  where
    step acc (ov, cd) =
      let t1 = acc !! ovLeft ov
          t2 = acc !! ovRight ov
      in case defectClass cd of
          GaugeLike ->
            let (t1', t2') = repairOverlap (0.10 * alpha) gr t1 t2 (ovRect ov)
            in updateTiles acc (ovLeft ov) t1' (ovRight ov) t2'
          ResolutionLike -> acc
          StructuralLike ->
            let (t1r, t2r) = repairOverlap (0.35 * alpha) gr t1 t2 (ovRect ov)
                local1 = extractOverlapFromTile gr t1 (ovRect ov)
                local2 = extractOverlapFromTile gr t2 (ovRect ov)
                liftPatch = entropyLift 0.15 (rsvpDiff local1 local2)
                t1' = applyCorrection gr t1r (ovRect ov) liftPatch
                t2' = applyCorrection gr t2r (ovRect ov) liftPatch
            in updateTiles acc (ovLeft ov) t1' (ovRight ov) t2'
