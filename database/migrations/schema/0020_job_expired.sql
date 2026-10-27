-- Track whether an archived job was archived because it expired.
--
-- Jobs are archived both by the expiry worker and by employers closing a
-- listing, and both leave the same status behind. Moderators can republish
-- expired jobs, so they need to tell the two apart: a listing the employer
-- closed must not come back.
alter table job add column expired boolean not null default false;

-- Backfill jobs archived by the expiry worker. It only archives jobs at least
-- 30 days after publication (the expiry window before this migration), while
-- employers archive whenever they like, so anything archived earlier than that
-- is treated as closed by the employer.
update job
set expired = true
where status = 'archived'
and published_at is not null
and archived_at >= published_at + '30 days'::interval;

---- create above / drop below ----

alter table job drop column expired;
