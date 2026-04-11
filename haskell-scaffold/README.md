# TARTAN Haskell Scaffold

A minimal executable scaffold for the TARTAN architecture.

This second-pass version includes:

- staged defect classification (`GaugeLike`, `ResolutionLike`, `StructuralLike`)
- an obstruction log keyed by quantized defect signatures
- branch-aware repair decisions
- refinement triggered by resolution defects
- CLIO-style parameter updates conditioned on classified obstruction patterns
- PPM snapshot export for lattice inspection

## Layout

- `app/Main.hs` — executable entry point
- `experiments/Experiment.hs` — staged-closure demo loop
- `src/Tartan/` — tiling, overlaps, defects, repair, retiling, obstruction log, trajectory summaries, CLIO
- `src/RSVP/` — minimal RSVP lattice dynamics
- `src/Visualization/` — PPM exporters

## Notes

This is a research scaffold rather than a finished simulator. The obstruction log and classification branch are intentionally simple, but they reflect the staged closure protocol described in the monograph:

1. gauge repair
2. refinement
3. state extension

The current implementation approximates state extension through an entropy-lift patch on structurally persistent overlaps.
