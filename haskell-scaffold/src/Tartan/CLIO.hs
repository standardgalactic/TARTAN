module Tartan.CLIO
  ( updateTheta
  ) where

import Tartan.Types

updateTheta :: Theta -> Double -> [ClassifiedDefect] -> Theta
updateTheta (Theta s) totalDef cds =
  let structural = length [ () | cd <- cds, defectClass cd == StructuralLike ]
      resolution = length [ () | cd <- cds, defectClass cd == ResolutionLike ]
      targetBase = 0.22 / (1.0 + totalDef)
      target = max 0.04 (min 0.45 (targetBase + 0.015 * fromIntegral structural - 0.010 * fromIntegral resolution))
  in Theta (0.85 * s + 0.15 * target)
