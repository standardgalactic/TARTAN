module RSVP.Dynamics
  ( syntheticTruth
  , stepRSVP
  ) where

import Tartan.Grid
import Tartan.Tile
import Tartan.Types

gradX :: Grid -> ScalarField -> Int -> Int -> Double
gradX gr fld x y =
  let l = readScalar gr fld (clampX gr (x - 1)) y
      r = readScalar gr fld (clampX gr (x + 1)) y
  in 0.5 * (r - l)

gradY :: Grid -> ScalarField -> Int -> Int -> Double
gradY gr fld x y =
  let u = readScalar gr fld x (clampY gr (y - 1))
      d = readScalar gr fld x (clampY gr (y + 1))
  in 0.5 * (d - u)

laplace :: Grid -> ScalarField -> Int -> Int -> Double
laplace gr fld x y =
  let c = readScalar gr fld x y
      l = readScalar gr fld (clampX gr (x - 1)) y
      r = readScalar gr fld (clampX gr (x + 1)) y
      u = readScalar gr fld x (clampY gr (y - 1))
      d = readScalar gr fld x (clampY gr (y + 1))
  in l + r + u + d - 4 * c

advectScalar :: Grid -> VectorField -> ScalarField -> Int -> Int -> Double
advectScalar gr vf fld x y =
  let vx = readScalar gr (vxField vf) x y
      vy = readScalar gr (vyField vf) x y
  in vx * gradX gr fld x y + vy * gradY gr fld x y

stepRSVP :: Params -> Grid -> RSVP -> RSVP
stepRSVP p gr st =
  let newPhi = mkScalar gr $ \x y ->
        let phi0 = readScalar gr (phiField st) x y
            adv  = advectScalar gr (velField st) (phiField st) x y
            dif  = laplace gr (phiField st) x y
        in phi0 + dt p * (-adv + dPhi p * dif)

      newVx = mkScalar gr $ \x y ->
        let vx0   = readScalar gr (vxField (velField st)) x y
            gradP = gradX gr (phiField st) x y
            dif   = laplace gr (vxField (velField st)) x y
        in vx0 + dt p * (-gradP - gamma p * vx0 + dVel p * dif)

      newVy = mkScalar gr $ \x y ->
        let vy0   = readScalar gr (vyField (velField st)) x y
            gradP = gradY gr (phiField st) x y
            dif   = laplace gr (vyField (velField st)) x y
        in vy0 + dt p * (-gradP - gamma p * vy0 + dVel p * dif)

      newVel = VectorField newVx newVy

      newEnt = mkScalar gr $ \x y ->
        let s0   = readScalar gr (entField st) x y
            adv  = advectScalar gr (velField st) (entField st) x y
            dif  = laplace gr (entField st) x y
            gx   = gradX gr (vxField (velField st)) x y
            gy   = gradY gr (vyField (velField st)) x y
            prod = kappa p * (gx * gx + gy * gy)
        in s0 + dt p * (-adv + prod + dEnt p * dif)
  in RSVP newPhi newVel newEnt

syntheticTruth :: Grid -> RSVP
syntheticTruth gr@Grid{gWidth, gHeight} =
  let phiF = mkScalar gr $ \x y ->
        let xf = fromIntegral x / fromIntegral (max 1 (gWidth - 1))
            yf = fromIntegral y / fromIntegral (max 1 (gHeight - 1))
            bump1 = exp (-35 * ((xf - 0.35)^2 + (yf - 0.45)^2))
            bump2 = 0.7 * exp (-55 * ((xf - 0.72)^2 + (yf - 0.62)^2))
            wave  = 0.15 * sin (8 * xf) * cos (10 * yf)
        in bump1 + bump2 + wave
      vxF = mkScalar gr $ \x y ->
        let xf = fromIntegral x / fromIntegral (max 1 gWidth)
            yf = fromIntegral y / fromIntegral (max 1 gHeight)
        in 0.1 * sin (6 * yf) - 0.08 * cos (5 * xf)
      vyF = mkScalar gr $ \x y ->
        let xf = fromIntegral x / fromIntegral (max 1 gWidth)
            yf = fromIntegral y / fromIntegral (max 1 gHeight)
        in 0.08 * sin (5 * xf) + 0.07 * cos (7 * yf)
      entF = mkScalar gr $ \x y ->
        let p0 = readScalar gr phiF x y
        in 0.2 + 0.4 * abs p0
  in RSVP phiF (VectorField vxF vyF) entF
