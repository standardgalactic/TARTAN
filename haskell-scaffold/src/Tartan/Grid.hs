module Tartan.Grid
  ( Grid(..)
  , Rect(..)
  , index2D
  , clampX
  , clampY
  , tileGrid
  , rectIntersect
  , inflateRect
  ) where

data Grid = Grid
  { gWidth  :: Int
  , gHeight :: Int
  } deriving (Eq, Show)

data Rect = Rect
  { rx :: Int
  , ry :: Int
  , rw :: Int
  , rh :: Int
  } deriving (Eq, Show)

index2D :: Grid -> Int -> Int -> Int
index2D Grid{gWidth} x y = y * gWidth + x

clampX :: Grid -> Int -> Int
clampX Grid{gWidth} x = max 0 (min (gWidth - 1) x)

clampY :: Grid -> Int -> Int
clampY Grid{gHeight} y = max 0 (min (gHeight - 1) y)

tileGrid :: Grid -> Int -> Int -> [Rect]
tileGrid Grid{gWidth, gHeight} nx ny =
  [ Rect x0 y0 (x1 - x0) (y1 - y0)
  | ty <- [0 .. ny - 1]
  , tx <- [0 .. nx - 1]
  , let x0 = tx * gWidth `div` nx
  , let x1 = (tx + 1) * gWidth `div` nx
  , let y0 = ty * gHeight `div` ny
  , let y1 = (ty + 1) * gHeight `div` ny
  ]

rectIntersect :: Rect -> Rect -> Maybe Rect
rectIntersect a b =
  let x0 = max (rx a) (rx b)
      y0 = max (ry a) (ry b)
      x1 = min (rx a + rw a) (rx b + rw b)
      y1 = min (ry a + rh a) (ry b + rh b)
      w  = x1 - x0
      h  = y1 - y0
  in if w > 0 && h > 0 then Just (Rect x0 y0 w h) else Nothing

inflateRect :: Grid -> Int -> Rect -> Rect
inflateRect Grid{gWidth, gHeight} pad r =
  let x0 = max 0 (rx r - pad)
      y0 = max 0 (ry r - pad)
      x1 = min gWidth  (rx r + rw r + pad)
      y1 = min gHeight (ry r + rh r + pad)
  in Rect x0 y0 (x1 - x0) (y1 - y0)
