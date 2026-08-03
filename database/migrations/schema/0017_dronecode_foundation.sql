-- Make Dronecode the only foundation this instance serves.
--
-- The syncer picks up foundations that have a landscape_url set
-- (syncer_list_foundations), so this row is what causes members and projects to
-- be pulled in. The URL is an S3 REST endpoint rather than a domain: the
-- Dronecode landscape is published as a data feed for this job board, not as a
-- website, so it has no custom domain of its own.
--
-- The 'cncf' row seeded in 0001_initial is removed. It has no landscape_url so
-- the syncer would ignore it, but list_foundations() applies no such filter and
-- feeds the employer dashboard, which would offer "cncf" as a selectable
-- foundation when an employer creates a profile or posts a job.
--
-- The delete is deliberately unguarded. member.foundation and project.foundation
-- are the only foreign keys and both are ON DELETE RESTRICT, so if anything
-- still references cncf this migration fails loudly instead of silently
-- orphaning rows.

insert into foundation (name, landscape_url)
values ('dronecode', 'https://dronecode-landscape.s3.us-east-1.amazonaws.com')
on conflict (name) do update set landscape_url = excluded.landscape_url;

delete from foundation where name = 'cncf';

---- create above / drop below ----

insert into foundation (name) values ('cncf') on conflict (name) do nothing;

delete from foundation where name = 'dronecode';
