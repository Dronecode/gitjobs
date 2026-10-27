-- Republishes an expired job as a moderator, starting a new expiry window.
create or replace function republish_job(p_job_id uuid, p_reviewer uuid)
returns void as $$
    update job
    set
        status = 'published',
        published_at = current_timestamp,
        archived_at = null,
        expired = false,
        reviewed_at = current_timestamp,
        reviewed_by = p_reviewer
    where job_id = p_job_id
    and status = 'archived'
    and expired = true;
$$ language sql;
