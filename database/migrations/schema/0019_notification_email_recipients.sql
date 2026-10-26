-- Allow notifications addressed to a plain email address instead of a user.
--
-- Moderation notifications go to an address set in the server config (a team
-- inbox), which has no user account behind it.
alter table notification alter column user_id drop not null;
alter table notification add column email text check (email <> '');
alter table notification add constraint notification_recipient_check
    check (user_id is not null or email is not null);

insert into notification_kind (name) values ('job-pending-approval');

-- Remove legacy function signatures before reloading updated definitions
drop function if exists enqueue_notification(text, jsonb, uuid[]);

---- create above / drop below ----

delete from notification where user_id is null;
delete from notification where kind = 'job-pending-approval';
delete from notification_kind where name = 'job-pending-approval';

alter table notification drop constraint notification_recipient_check;
alter table notification drop column email;
alter table notification alter column user_id set not null;

drop function if exists enqueue_notification(text, jsonb, uuid[], text[]);
