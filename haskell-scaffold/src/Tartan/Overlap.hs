module Tartan.Overlap
  ( buildOverlaps
  , extractOverlapFromTile
  ) where

import Tartan.Grid
import Tartan.Tile (extractRSVPRect)
import Tartan.Types

buildOverlaps :: Grid -> Int -> [Tile] -> [Overlap]
buildOverlaps gr halo ts =
  [ Overlap (tileId a) (tileId b) ov
  | (i, a) <- zip [0..] ts
  , b <- drop (i + 1) ts
  , let ra = inflateRect gr halo (tileRect a)
  , let rb = inflateRect gr halo (tileRect b)
  , Just ov <- [rectIntersect ra rb]
  ]

extractOverlapFromTile :: Grid -> Tile -> Rect -> RSVP
extractOverlapFromTile _ tile ov =
  let tr = tileRect tile
      localRect = Rect
        { rx = rx ov - rx tr
        , ry = ry ov - ry tr
        , rw = rw ov
        , rh = rh ov
        }
      localGr = Grid (rw tr) (rh tr)
  in extractRSVPRect localGr (tileState tile) localRect
