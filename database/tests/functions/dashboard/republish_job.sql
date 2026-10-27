-- ============================================================================
-- SETUP
-- ============================================================================

begin;
select plan(3);

-- ============================================================================
-- VARIABLES
-- ============================================================================

\set closedJobID '00000000-0000-0000-0000-000000000302'
\set employerID '00000000-0000-0000-0000-000000000101'
\set expiredJobID '00000000-0000-0000-0000-000000000301'
\set reviewerID '00000000-0000-0000-0000-000000000201'

-- ============================================================================
-- SEED DATA
-- ============================================================================

insert into "user" (auth_hash, email, moderator, name, user_id, username) values
    (decode('01', 'hex'), 'reviewer@example.com', true, 'Reviewer', :'reviewerID', 'reviewer');

insert into employer (company, description, employer_id) values
    ('Acme', 'Employer for republish_job tests', :'employerID');

insert into job (
    archived_at,
    description,
    employer_id,
    expired,
    first_published_at,
    job_id,
    kind,
    published_at,
    status,
    title,
    workplace
) values
    (
        current_timestamp - interval '1 day',
        'Expired role',
        :'employerID',
        true,
        current_timestamp - interval '91 days',
        :'expiredJobID',
        'full-time',
        current_timestamp - interval '91 days',
        'archived',
        'Expired Engineer',
        'remote'
    ),
    (
        current_timestamp - interval '1 day',
        'Closed role',
        :'employerID',
        false,
        current_timestamp - interval '10 days',
        :'closedJobID',
        'full-time',
        current_timestamp - interval '10 days',
        'archived',
        'Closed Engineer',
        'remote'
    );

-- ============================================================================
-- TESTS
-- ============================================================================

-- Should republish an expired job with a fresh publication date
select republish_job(:'expiredJobID'::uuid, :'reviewerID'::uuid);

select ok(
    (
        select status = 'published'
        and published_at > current_timestamp - interval '1 minute'
        and first_published_at < current_timestamp - interval '90 days'
        and archived_at is null
        and not expired
        and reviewed_by = :'reviewerID'::uuid
        and reviewed_at is not null
        from job
        where job_id = :'expiredJobID'::uuid
    ),
    'Should republish an expired job with a fresh publication date'
);

-- Should not republish a job archived by its employer
select republish_job(:'closedJobID'::uuid, :'reviewerID'::uuid);

select ok(
    (
        select status = 'archived'
        and archived_at is not null
        and reviewed_by is null
        from job
        where job_id = :'closedJobID'::uuid
    ),
    'Should not republish a job archived by its employer'
);

-- Should not republish a job that is already published
select republish_job(:'expiredJobID'::uuid, :'reviewerID'::uuid);

select is(
    (select count(*) from job where status = 'published'),
    1::bigint,
    'Should not republish a job that is already published'
);

-- ============================================================================
-- CLEANUP
-- ============================================================================

select * from finish();
rollback;
