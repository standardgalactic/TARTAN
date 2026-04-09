# Operational Protocol: TARTAN Defensive Branch and Sensor Integrity Management

## 1. Architectural Foundations: From Prediction to Constraint Closure

In high-stakes autonomous systems, traditional predictive models—those that estimate a state from independent sensor samples p(X | y)—are structurally insufficient. They optimize local accuracy while ignoring global coherence, resulting in **predictive inconsistency**.

To achieve system integrity, the objective must shift from prediction to **constraint closure**. The system must identify a world-state X* such that:

C(X*) = X*

where C is the consistency operator.

Reconstruction is grounded in the **Relativistic Scalar–Vector Plenum (RSVP)** substrate, which enforces conservation laws and physical constraints. The system evolves over trajectories γ rather than static snapshots, following the **Yarncrawler principle** toward a stable fixed point.

The RSVP fields are defined as follows.

The scalar potential Φ encodes structural possibility.  
The vector flow v governs transport and momentum.  
Entropy S tracks dissipation and irreversibility.

A central limitation is the **No Free Global Section** condition. If sensors are optimized independently, there is no guarantee a globally consistent state exists. Constraint closure provides the mechanism for eliminating structurally impossible configurations and detecting violations caused by noise or adversarial interference.

---

## 2. Detection and Classification of Malignant Novelty

System integrity requires distinguishing between **genuine novelty**, which demands ontological expansion, and **malignant novelty**, which arises from sensor corruption or adversarial input.

The diagnostic object is the **defect tensor**:

δ̂ᵢⱼ = ρᵢⱼ(sᵢ) − ρⱼᵢ(sⱼ)

This measures disagreement between neighboring sensor tiles.

Classification is determined by response to normalization (N) and refinement (R).

Gauge defects satisfy N(δ̂ᵢⱼ) ≈ 0 and arise from representation misalignment.  
Resolution defects satisfy R(δ̂ᵢⱼ) → 0 and arise from insufficient detail.  
Structural or malignant defects persist under both operations.

Two filters identify malignant novelty.

Modality ablation removes a sensor; if the defect disappears, that sensor is corrupt.  
Cross-context transportability tests whether a feature appears across modalities.

A strict **causal reciprocity** condition is enforced. Valid updates must produce reciprocal effects in neighboring regions. Variables that fail to propagate consequences are rejected as **explanation sinks**.

---

## 3. The Defensive Branch: Corruption Modeling and Correction

The defensive branch constructs a **corrected projection operator** Kᵢ to transform corrupted observations into admissible inputs.

Given an observation y_obs, the corrected input is:

y_corr = Kᵢ(y_obs)

The corrected observation must remain compatible with RSVP dynamics to participate in global reconstruction.

Model updates are governed by the **Global Description Length (GDL)** principle. The system selects the path minimizing total description length, balancing model complexity and residual defect.

This prevents **defensive overfitting**, where the system misclassifies real-world structure as sensor noise.

---

## 4. Operational Sensor Lifecycle: Quarantine and Probation

When a sensor is identified as compromised, it enters a controlled lifecycle.

### Quarantine Phase

The sensor’s reliability weight wᵢ is reduced toward zero. Its data is excluded from reconstruction while provenance tracking continues.

### Probation Protocol

Reintegration proceeds through marginal contribution analysis.

The system compares total defect with and without the sensor.  
If inclusion reduces aggregate defect, its weight is gradually increased.  
Sustained agreement is required before full restoration.

### Adaptive Reliability

Sensor reliability is continuously updated based on consistency with the RSVP-constrained global state. This maintains stability under fluctuating sensor quality.

---

## 5. Global Coherence and the CLIO Optimization Loop

The **CLIO (Cognitive Loop via In-Situ Optimization)** module refines the consistency operator in real time.

The update rule is:

θₜ₊₁ = Θ(θₜ, Xₜ, δ̂ₜ)

where θ are the operator parameters, X the current state, and δ̂ the aggregate defect.

Persistent **uncertainty oscillations** indicate proximity to non-trivial cohomological obstructions. These are not noise but signals requiring structural repair.

Stability is achieved through joint convergence of the world-state and the consistency operator, ensuring resilience under dynamic or adversarial conditions.

---

## 6. Diagnostic Protocols for Systemic Failure Modes

Robust operation requires identifying and responding to structural failure modes.

Projection degeneracy occurs when distinct states produce identical observations. The remedy is expansion of the projection family through additional sensing modalities.

Summary collapse occurs when coarse-graining removes critical distinguishing information. The remedy is enrichment of the representation.

Ontological overgrowth arises from excessive latent expansion without reciprocal evidence. The remedy is rollback based on complexity-to-benefit ratios.

Defensive overfitting occurs when correction operators suppress real structure. The remedy is regularization of Kᵢ.

Oscillatory non-convergence indicates unresolved structural contradiction. The remedy is structural repair through alignment, refinement, or ontology expansion.

---

## Conclusion

The TARTAN framework achieves system integrity through the iterative elimination of all structural inconsistencies. Rather than predicting observations, it reconstructs a world that can exist.

Global consistency is not assumed—it is enforced.
