-- Remove the CNCF certifications seeded in 0013.
--
-- They are all Kubernetes and cloud-native credentials (CKA, CKAD, CKS, KCNA,
-- KCSA, PCA, ICA, CCA, CAPA, CGOA, CBA, OTCA, KCA). On a drone job board they
-- are noise: an employer posting for a PX4 firmware engineer would be offered
-- "Certified Kubernetes Administrator" as a relevant credential.
--
-- Dronecode has no certification programme of its own today, so the table is
-- left empty rather than repopulated. That is handled by the UI: certifications
-- are serialised to a JSON array for the dashboard-search component, so an
-- empty table renders an empty picker rather than failing.
--
-- Scoped to provider = 'CNCF' rather than truncating, so anything added later
-- survives a re-run.

delete from certification where provider = 'CNCF';

---- create above / drop below ----

-- Restoring these means re-running the seed from 0013. Deliberately not
-- duplicated here: this migration is only ever rolled back alongside 0013, and
-- copying the data would leave two sources of truth for it.
select 1;
