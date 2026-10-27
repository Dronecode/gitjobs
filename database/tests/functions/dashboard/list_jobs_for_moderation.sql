-- ============================================================================
-- SETUP
-- ============================================================================

begin;
select plan(3);

-- ============================================================================
-- VARIABLES
-- ============================================================================

\set employerID '00000000-0000-0000-0000-000000000101'
\set job1ID '00000000-0000-0000-0000-000000000301'
\set job2ID '00000000-0000-0000-0000-000000000302'
\set job3ID '00000000-0000-0000-0000-000000000303'
\set job4ID '00000000-0000-0000-0000-000000000304'

-- ============================================================================
-- SEED DATA
-- ============================================================================

insert into employer (company, description, employer_id) values
    ('Acme', 'Employer for list_jobs_for_moderation tests', :'employerID');

insert into job (
    created_at,
    description,
    employer_id,
    job_id,
    kind,
    status,
    title,
    workplace
) values
    (
        '2026-01-01 10:00:00+00',
        'Pending role',
        :'employerID',
        :'job1ID',
        'full-time',
        'pending-approval',
        'Pending Engineer',
        'remote'
    ),
    (
        '2026-01-02 10:00:00+00',
        'Published role',
        :'employerID',
        :'job2ID',
        'full-time',
        'published',
        'Published Engineer',
        'remote'
    ),
    (
        '2026-01-03 10:00:00+00',
        'Expired role',
        :'employerID',
        :'job3ID',
        'full-time',
        'archived',
        'Expired Engineer',
        'remote'
    ),
    (
        '2026-01-04 10:00:00+00',
        'Closed role',
        :'employerID',
        :'job4ID',
        'full-time',
        'archived',
        'Closed Engineer',
        'remote'
    );

update job
set archived_at = '2026-04-03 10:00:00+00', expired = true
where job_id = :'job3ID'::uuid;

update job
set archived_at = '2026-01-10 10:00:00+00'
where job_id = :'job4ID'::uuid;

-- ============================================================================
-- TESTS
-- ============================================================================

-- Should return full moderation payload for the requested status
select is(
    list_jobs_for_moderation('pending-approval')::jsonb,
    jsonb_build_array(
        jsonb_build_object(
            'created_at',
            '2026-01-01 10:00:00+00'::timestamptz,
            'employer',
            jsonb_build_object(
                'company',
                'Acme',
                'employer_id',
                :'employerID'::uuid
            ),
            'job_id',
            :'job1ID'::uuid,
            'title',
            'Pending Engineer'
        )
    ),
    'Should return full moderation payload for the requested status'
);

-- Should return only expired jobs, with their archive date, for archived status
select is(
    list_jobs_for_moderation('archived')::jsonb,
    jsonb_build_array(
        jsonb_build_object(
            'archived_at',
            '2026-04-03 10:00:00+00'::timestamptz,
            'created_at',
            '2026-01-03 10:00:00+00'::timestamptz,
            'employer',
            jsonb_build_object(
                'company',
                'Acme',
                'employer_id',
                :'employerID'::uuid
            ),
            'job_id',
            :'job3ID'::uuid,
            'title',
            'Expired Engineer'
        )
    ),
    'Should return only expired jobs, with their archive date, for archived status'
);

-- Should return empty arrays when no jobs match the status
select is(
    list_jobs_for_moderation('deleted')::jsonb,
    '[]'::jsonb,
    'Should return empty arrays when no jobs match the status'
);

-- ============================================================================
-- CLEANUP
-- ============================================================================

select * from finish();
rollback;
