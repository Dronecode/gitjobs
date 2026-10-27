-- Archives published jobs that expired more than 90 days ago.
create or replace function archive_expired_jobs()
returns void as $$
    update job
    set
        status = 'archived',
        archived_at = current_timestamp,
        expired = true,
        updated_at = current_timestamp
    where status = 'published'
    and published_at + '90 days'::interval < current_timestamp;
$$ language sql;
