/*
 * There is no lock because in psql lock is in concept named TRANSACTION
 * function is always inside a TRANSACTION
 * so use lock in outside
 * TODO: there will be a file provide such interfaces

 * naming rules: directly get info from table use query [users table is an exception]
 *               use multiple table to form query result use get
 *               if query can be done by add, delete, update, select directly on a table,
                        declare function in table function section
                        call it at requirement accomplishment section
 * TODO: rename function name to clarify and be unique
 *     : error code more scientific
 *     : formalize the declaration of integer/int, boolean/bool, array
 *             : query func use query_(target)[_from_param]__[table for short]__
 */

-- Table Function Section --
----------------------------
/* @table: user */
/* @param: user_name */
/*       : user_password */
/* @return: uid */
/*        : error_type */
/* @note: user login query */
drop function if exists query_uid_from_uname_password__u__ cascade;

create or replace function query_uid_from_uname_password__u__(
    in user_name varchar(20),
    in user_password varchar(20)
)
    returns table
            (
                uid   integer,
                error error_type__u__
            )
as
$$
declare
    integer_var integer;
    uid         integer;
    error       error_type__u__;
begin
    select count(*) into integer_var from users where u_user_name = user_name;
    if (integer_var = 0) then
        uid := 0;
        error := 'ERROR_NOT_FOUND_UNAME';
    else
        select u_uid into uid from users where u_user_name = user_name and u_password = user_password;
        if uid is null then
            uid := 0;
            error := 'ERROR_NOT_CORRECT_PASSWORD';
        else
            error := 'NO_ERROR';
        end if;
    end if;
    return query select uid, error;
end;
$$ language plpgsql;

/* @table: user */
/* @param: user_name */
/*       : user_password */
/*       : phone_num */
/*       : user_email */
/* @return: uid */
/*        : error_type */
/* @note: insert into user table */
drop function if exists insert_all_info_into__u__ cascade;

create or replace function insert_all_info_into__u__(
    in user_name varchar(20),
    in user_password varchar(20),
    in phone_num varchar(11),
    in user_email varchar(50)
)
    returns table
            (
                uid integer,
                err error_type__u__
            )
as
$$
declare
    uid         integer;
    err         error_type__u__;
    integer_val integer;
begin
    select count(*) into integer_val from users where u_user_name = user_name;
    if integer_val != 0 then
        uid := 0;
        err := 'ERROR_DUPLICATE_UNAME';
    else
        select count(*) into integer_val from users where u_tel_num = phone_num;
        if integer_val != 0 then
            uid := 0;
            err := 'ERROR_DUPLICATE_U_TEL_NUM';
        else
            insert into users (u_user_name, u_password, u_email, u_tel_num)
            values (user_name, user_password, user_email, phone_num);
            select currval(pg_get_serial_sequence('users', 'u_uid')) into uid;
            err := 'NO_ERROR';
        end if;
    end if;
    return query select uid, err;
end;
$$ language plpgsql;

-- admin --
-- train --
/* @table: train */
/* @param: train_name */
/* @return: train_id */
/* @note: train_name -> train_id */
drop function if exists query_train_id_from_name__t__ cascade;

create or replace function query_train_id_from_name__t__(
    in train_name varchar(10)
)
    returns table
            (
                train_id integer
            )
as
$$
begin
    return query select t_train_id
                 from train
                 where t_train_name = train_name;
end;
$$ language plpgsql;

/* @table: train */
/* @param: train_id */
/* @return: train_name */
/* @note: train_id -> train_name */
drop function if exists query_train_name_from_id__t__ cascade;

create or replace function query_train_name_from_id__t__(
    in train_id integer
)
    returns table
            (
                train_name varchar(20)
            )
as
$$
begin
    return query
        select t_train_name
        from train
        where t_train_id = train_id;
end;
$$ language plpgsql;

-- city --
/* @table: city */
/* @param: city_name */
/* @return: city_id */
drop function if exists query_city_id_from_name__c__ cascade;

create or replace function query_city_id_from_name__c__(
    in city_name varchar(20)
)
    returns table
            (
                city_id integer
            )
as
$$
begin
    return query
        select c_city_id
        from city
        where c_city_name = city_name;
end;
$$ language plpgsql;

-- city train --
/* @table: city_train */
/* @param: city_id */
/* @return: train_id_list */
drop function if exists query_train_id_list_from_cid__ct__ cascade;

create or replace function query_train_id_list_from_cid__ct__(
    in city_id integer
)
    returns table
            (
                train_id integer
            )
    language plpgsql
as
$$
begin
    return query select ct_train_id as train_id from city_train where ct_city_id = city_id;
end;
$$;

-- station list --
/* @table: station_list */
/* @param: station_id */
/* @return: station_name */
drop function if exists query_station_name_from_id__s__ cascade;

create or replace function query_station_name_from_id__s__(
    in station_id integer
)
    returns table
            (
                station_name varchar(20)
            )
as
$$
begin
    return query
        select s_station_name
        from station_list
        where s_station_id = station_id;
end;
$$ language plpgsql;

/* @table: station_list */
/* @param: station_id */
/* @return: city_id */
drop function if exists query_city_id_from_sid__s__ cascade;

create or replace function query_city_id_from_sid__s__(
    in station_id integer
)
    returns table
            (
                city_id integer
            )
as
$$
begin
    return query select s_station_city_id from station_list where s_station_id = station_id;
end;
$$ language plpgsql;

-- train full info --
-- start <-> leave --
-- end <-> arrive --
/* @table: train_full_info */
/* @param: train_id */
/* @return: leave_time */
/* @note: train_id in station -> leave time */
drop function if exists query_start_time_from_id__tfi__ cascade;

create or replace function query_start_time_from_id__tfi__(
    in train_id integer
)
    returns table
            (
                start_time time
            )
as
$$
begin
    return query
        select tfi_leave_time
        from train_full_info
        where tfi_train_id = train_id
          and tfi_station_order = 0;
end;
$$ language plpgsql;

-- train full info --
-- start <-> leave --
-- end <-> arrive --
/* @table: train_full_info */
/* @param: train_id */
/* @return: leave_time */
/* @note: train_id in station -> leave time */
drop function if exists query_start_station_from_id__tfi__ cascade;

create or replace function query_start_station_from_id__tfi__(
    in train_id integer
)
    returns table
            (
                start_station integer
            )
as
$$
begin
    return query
        select tfi_station_id
        from train_full_info
        where tfi_train_id = train_id
          and tfi_station_order = 0;
end;
$$ language plpgsql;

/* @table: train_full_info */
/* @param: train_id */
/*       : station_id */
/* @return: day_from_departure */
/* @note: train_id in station -> day_from_departure */
drop function if exists query_day_from_departure_from_id__tfi__ cascade;

create or replace function query_day_from_departure_from_id__tfi__(
    in train_id integer,
    in station_id integer
)
    returns table
            (
                day_from_departure integer
            )
as
$$
begin
    return query
        select tfi_day_from_departure
        from train_full_info
        where tfi_train_id = train_id
          and tfi_station_id = station_id;
end;
$$ language plpgsql;

/* @table: train_full_info */
/* @param: train_id */
/*       : station_id */
/* @return: station_order */
drop function if exists query_station_order_from_tid_sid__tfi__ cascade;

create or replace function query_station_order_from_tid_sid__tfi__(
    in train_id integer,
    in station_id integer
)
    returns table
            (
                station_order integer
            )
as
$$
begin
    return query
        select tfi_station_order
        from train_full_info
        where tfi_train_id = train_id
          and tfi_station_id = station_id;
end;
$$ language plpgsql;

/* @table: train_full_info */
/* @param: train_id */
/*       : station_id */
/* @return: all info */
drop function if exists query_train_all_info_from_tid_sid__tfi__ cascade;

create or replace function query_train_all_info_from_tid_sid__tfi__(
    in train_id integer,
    in station_id integer
)
    returns table
            (
                station_order      integer,
                arrive_time        time,
                leave_time         time,
                day_from_departure integer,
                distance           integer,
                price              decimal(5, 1)[7]
            )
as
$$
begin
    return query
        select tfi_station_order, tfi_arrive_time, tfi_leave_time, tfi_day_from_departure, tfi_distance, tfi_price
        from train_full_info
        where tfi_train_id = train_id
          and tfi_station_id = station_id;
end;
$$ language plpgsql;

/* @table: train_full_info */
/* @param: train_id */
/*       : station_order */
/* @return: station_id */
drop function if exists query_station_id_from_tid_so__tfi__ cascade;

create or replace function query_station_id_from_tid_so__tfi__(
    in train_id integer,
    in station_order integer
)
    returns table
            (
                station_id integer
            )
as
$$
begin
    return query
        select tfi_station_id
        from train_full_info
        where tfi_train_id = train_id
          and tfi_station_order = station_order;
end;
$$ language plpgsql;

/* @table: train_full_info */
/* @param: train_id */
/*       : station_id */
/* @return: next_station_id */
drop function if exists get_next_station_id cascade;

create or replace function get_next_station_id(
    in train_id integer,
    in station_id integer
)
    returns table
            (
                next_station_id integer
            )
as
$$
declare
    station_order   integer;
    next_station_id integer;
begin
    select tfi_station_order
    into station_order
    from train_full_info
    where tfi_train_id = train_id
      and tfi_station_id = station_id;
    station_order := station_order + 1;
    select tfi_station_id
    into next_station_id
    from train_full_info
    where tfi_train_id = train_id
      and tfi_station_order = station_order;
    return query select next_station_id;
end;
$$ language plpgsql;

drop function if exists get_station_price;

create or replace function get_station_price(
    in train_id integer,
    in start_station_id integer,
    in end_station_id integer,
    in in_seat_type seat_type
)
returns table(
    price   decimal(5,1)
)
    as
    $$
    begin
        return query select end_tfi.tfi_price[in_seat_type::integer] - start_tfi.tfi_price[in_seat_type::integer] from train_full_info end_tfi
        left join train_full_info start_tfi on end_tfi.tfi_train_id = start_tfi.tfi_train_id
        where end_tfi.tfi_station_id = end_station_id and start_tfi.tfi_station_id = start_station_id
        and end_tfi.tfi_train_id = train_id;
    end;
    $$ language plpgsql;

-- station tickets --
/* @table: station_tickets */
/* @param: train_id */
/*       : query_date */
/*       : station_id */
/*       : seat_type_list */
/* @return: table of remain_seat num */
/* @caller-constraints: use lock outside */
/*                    : lock type - TO_FILL */
drop function if exists query_remain_seats__st__ cascade;

create or replace function query_remain_seats__st__(
    in train_id integer,
    in query_date date,
    in station_id integer,
    in seat_type_list seat_type[]
)
    returns table
            (
                seat_num integer
            )
as
$$
declare
    seat_type     seat_type;
    seat_nums_tmp integer[7];
begin
    foreach seat_type in array seat_type_list
        loop
            select stt_num
            into seat_nums_tmp
            from station_tickets
            where stt_station_id = station_id
              and stt_train_id = train_id
              and stt_date = query_date;
            seat_num := seat_nums_tmp[seat_type::integer];
            return next;
        end loop;
    return;
end;
$$ language plpgsql;

/* @table: station_tickets */
/* @param: train_id */
/*       : query_date */
/*       : station_from_id */
/*       : station_to_id */
/*       : seat_type_list */
/* @return: min_seats */
/* @note: get min seats num between start city and end */
/* @caller-constraints: use lock outside */
/*                    : lock type - TO_FILL */
drop function if exists get_min_seats cascade;

create or replace function get_min_seats(
    in train_id integer,
    in query_date date,
    in station_from_id integer,
    in station_to_id integer,
    in seat_type_list seat_type[]
)
    returns table
            (
                seat_num integer
            )
as
$$
declare
    station_start_order int;
    station_order_ptr   int;
    station_end_order   int;
    station_id_ptr      int        := station_from_id;
    station_seat_left   integer[7];
    seat_type           seat_type;
    min_seat_nums       integer[7] := array [5, 5, 5, 5, 5, 5, 5];
begin
    select query_station_order_from_tid_sid__tfi__(train_id, station_from_id) into station_start_order;
    station_order_ptr := station_start_order;
    select query_station_order_from_tid_sid__tfi__(train_id, station_to_id) into station_end_order;
    station_seat_left := array(select query_res.seat_num
                               from query_remain_seats__st__(train_id, query_date, station_id_ptr,
                                                             seat_type_list) query_res);
    while station_order_ptr != station_end_order
        loop
            foreach seat_type in array seat_type_list
                loop
                    if station_seat_left[seat_type::integer] < min_seat_nums[seat_type::integer] then
                        select array_set(min_seat_nums, seat_type::integer, station_seat_left[seat_type::integer])
                        into min_seat_nums;
                    end if;
                end loop;
            station_order_ptr := station_order_ptr + 1;
            select query_station_id_from_tid_so__tfi__(train_id, station_order_ptr) into station_id_ptr;
            station_seat_left := array(select query_res.seat_num
                                       from query_remain_seats__st__(train_id, query_date, station_id_ptr,
                                                                     seat_type_list) query_res);
        end loop;
    foreach seat_type in array seat_type_list
        loop
            seat_num := min_seat_nums[seat_type::integer];
            return next;
        end loop;
    return;
end;
$$ language plpgsql;

/* @table: station_tickets */
/* @param: train_id */
/*       : station_from_id */
/*       : station_to_id */
/*       : seat_type */
/*       : seat_num */
/* @return: succeed or not */
/*        : seat id as left_seat if succeed */
/*        : actual left_seat if failed */
/* @caller-constraints: use lock outside */
/*                    : lock type - TO_FILL */
drop function if exists try_occupy_seats cascade;

create or replace function try_occupy_seats(
    in train_id integer,
    in order_date date,
    in station_from_id integer,
    in station_to_id integer,
    in seat_type seat_type,
    in seat_num integer
)
    returns table
            (
                succeed   boolean,
                left_seat integer
            )
as
$$
declare
    station_start_order int;
    station_order_ptr   int;
    station_end_order   int;
    station_id_ptr      int := station_from_id;
    min_seat            int := 5;
    succeed             boolean;
    left_seat           integer;
begin
    select query_station_order_from_tid_sid__tfi__(train_id, station_from_id) into station_start_order;
    station_order_ptr = station_start_order;
    select query_station_order_from_tid_sid__tfi__(train_id, station_to_id) into station_end_order;
    -- find min_seat --
    select get_min_seat.seat_num
    into min_seat
    from get_min_seats(train_id, order_date, station_from_id, station_to_id, array [seat_type]) get_min_seat;
    -- check satisfiability --
    if min_seat < seat_num then
        succeed := false;
        left_seat := min_seat;
    else
        succeed := true;
        left_seat := 5 - min_seat;
        -- second loop, update station tickets --
        while station_order_ptr != station_end_order
            loop
                update station_tickets
                set stt_num = (select array_set(stt_num, seat_type::integer, stt_num[seat_type::integer] - seat_num))
                where stt_train_id = train_id
                  and stt_station_id = station_id_ptr
                  and stt_date = order_date;
                station_order_ptr := station_order_ptr + 1;
                select query_station_id_from_tid_so__tfi__(train_id, station_order_ptr) into station_id_ptr;
            end loop;
    end if;
    return query select succeed, left_seat;
end;
$$ language plpgsql;

/* @table: station_tickets */
/* @param: train_id */
/*       : order_date */
/*       : station_from_id */
/*       : station_to_id */
/*       : seat_type */
/*       : seat_num */
/* @return: succeed or not */
/*        : 0 left_seat if succeed */
/*        : actual left_seat if failed */
/* @caller-constraints: use lock outside */
/*                    : lock type - TO_FILL */
drop function if exists release_seats cascade;

create or replace function release_seats(
    in train_id integer,
    in order_date date,
    in station_from_id integer,
    in station_to_id integer,
    in seat_type seat_type,
    in seat_num integer
)
    returns void
as
$$
declare
    station_start_order int;
    station_order_ptr   int;
    station_end_order   int;
    station_id_ptr      int := station_from_id;
begin
    select query_station_order_from_tid_sid__tfi__(train_id, station_from_id) into station_start_order;
    station_order_ptr := station_start_order;
    select query_station_order_from_tid_sid__tfi__(train_id, station_to_id) into station_end_order;
    while station_order_ptr != station_end_order
        loop
            update station_tickets
            set stt_num = (select array_set(stt_num, seat_type::integer, stt_num[seat_type::integer] + seat_num))
            where stt_train_id = train_id
              and stt_station_id = station_id_ptr
              and stt_date = order_date;
            station_order_ptr := station_order_ptr + 1;
            select query_station_id_from_tid_so__tfi__(train_id, station_order_ptr) into station_id_ptr;
        end loop;
end;
$$ language plpgsql;

-- mixed --
-- user passengers --
/* @table: user */
/*       : passengers */
/* @param: user_name */
/*       : user_password */
/*       : name */
/*       : phone_num */
/*       : user_email */
/*       : is_admin */
/* @return: uid */
/* @note: insert into user table */
drop function if exists insert_all_info_into__up__ cascade;

create or replace function insert_all_info_into__up__(
    in user_name varchar(20),
    in user_password varchar(20),
    in name varchar(20),
    in phone_num varchar(11),
    in user_email varchar(50)
)
    returns table
            (
                pid integer,
                err error_type__u__
            )
as
$$
declare
    pid integer;
    err error_type__u__;
begin
    select * into pid, err from insert_all_info_into__u__(user_name, user_password, phone_num, user_email);
    if err = 'NO_ERROR' then
        insert into passengers (p_pid, p_real_name)
        values (pid, name);
    end if;
    return query select pid, err;
end;
$$ language plpgsql;

/* @table: users */
/*       : passengers */
/* @param: user_name */
/*       : user_password */
/* @return: pid */
/*        : error_type */
/* @note: user login query */
drop function if exists query_p_uid_from_uname_password__up__ cascade;

create or replace function query_p_uid_from_uname_password__up__(
    in user_name varchar(20),
    in user_password varchar(20)
)
    returns table
            (
                pid   integer,
                error error_type__u__
            )
as
$$
begin
    return query select * from query_uid_from_uname_password__u__(user_name, user_password);
end;
$$ language plpgsql;

/* @table: users */
/*       : admin */
/* @param: user_name */
/*       : user_password */
/*       : u_authentication */
/*       : u_authority */
/*       : user_email */
/*       : u_tel_num */
/* @return: aid */
/* @note: insert into admin table */
drop function if exists insert_all_info_into__ua__ cascade;

create or replace function insert_all_info_into__ua__(
    in user_name varchar(20),
    in user_password varchar(20),
    in authentication varchar(20),
    in authority admin_authority,
    in phone_num varchar(11),
    in user_email varchar(50)
)
    returns table
            (
                aid integer,
                err error_type__u__
            )
as
$$
declare
    aid integer;
    err error_type__u__;
begin
    select * into aid, err from insert_all_info_into__u__(user_name, user_password, phone_num, user_email);
    if err = 'NO_ERROR' then
        insert into admin (a_aid, a_authentication, a_authority)
        values (aid, authentication, authority);
    end if;
    return query select aid, err;
end;
$$ language plpgsql;

/* @table: users */
/*       : admin */
/* @param: user_name */
/*       : user_password */
/*       : u_authentication */
/*       : u_authority */
/* @return: aid */
/* @note: insert into admin table */
drop function if exists insert_passengers_into__ua__ cascade;

create or replace function insert_passengers_into__ua__(
    in user_name varchar(20),
    in user_password varchar(20),
    in authentication varchar(20),
    in authority admin_authority
)
    returns table
            (
                aid integer,
                err error_type__u__
            )
as
$$
declare
    aid integer;
    err error_type__u__;
begin
    select * into aid, err from query_uid_from_uname_password__u__(user_name, user_password);
    if err = 'NO_ERROR' then
        if (select * from admin where a_aid = aid) is not null then
            err := 'ERROR_DUPLICATE_AID';
        else
            insert into admin (a_aid, a_authentication, a_authority)
            values (aid, authentication, authority);
        end if;
    end if;
    return query select aid, err;
end;
$$ language plpgsql;

/* @table: users */
/*       : admin */
/* @param: user_name */
/*       : user_password */
/*       : authentication */
/* @return: aid */
/*        : error_type */
/* @note: admin login query */
drop function if exists query_aid_from_uname_password_auth__ua__ cascade;

create or replace function query_aid_from_uname_password_auth__ua__(
    in user_name varchar(20),
    in user_password varchar(20),
    in authentication varchar(20)
)
    returns table
            (
                aid   integer,
                error error_type__u__
            )
as
$$
declare
    aid         integer;
    error       error_type__u__;
    integer_val integer;
begin
    select * into aid, error from query_uid_from_uname_password__u__(user_name, user_password);
    if error = 'NO_ERROR' then
        select count(*) into integer_val from admin where a_aid = aid and a_authentication = authentication;
        if (integer_val > 0) then
            error := 'ERROR_NOT_CORRECT_AUTH';
            aid := 0;
        end if;
    end if;
    return query select aid, error;
end;
$$ language plpgsql;

/* @tables: station_list, city */
/* @param: city_name */
/* @return: station_name List */
drop function if exists get_station_name_from_cid cascade;

create or replace function get_station_name_from_cid(
    in city_name varchar(20)
)
    returns table
            (
                station_name varchar(20)
            )
    language plpgsql
as
$$
begin
    return query select s_station_name
                 from station_list
                          join city c on c.c_city_id = station_list.s_station_city_id
                 where c_city_name = city_name;
end;
$$;

/* @tables: station_list, train_full_info */
/* @param: city_id */
/*       : train_id */
/* @return: station_id */
/* @note: find which station the train stops when arriving the city */
/*      : column is in station list, so we put function here */
/*      : but actually info */
drop function if exists get_station_id_from_cid_tid cascade;

create or replace function get_station_id_from_cid_tid(
    in city_id integer,
    in train_id integer
)
    returns table
            (
                station_id integer
            )
as
$$
begin
    return query
        select s_station_id
        from train_full_info
                 left join station_list on station_list.s_station_id = train_full_info.tfi_station_id
        where s_station_city_id = city_id
          and tfi_train_id = train_id
        limit 1;
end;
$$ language plpgsql;

/* @tables: city_train, train_full_info, station_list */
/* @param: city_id */
/*       : train_id */
/* @return: priority */
/* @note: find city priority in this train line */
drop function if exists get_ct_priority cascade;

create or replace function get_ct_priority(
    in city_id integer,
    in train_id integer
)
    returns table
            (
                priority integer
            )
as
$$
begin
    return query
        select tfi_station_order
        from train_full_info
        where tfi_train_id = train_id
          and tfi_station_id = (select get_station_id_from_cid_tid(city_id, train_id))
        limit 1;
end;
$$ language plpgsql;

/* @tables: city_train, train_full_info, station_list */
/* @param: city_id */
/*       : train_id */
/* @return: next_city_list */
/* @note: find one  */
drop function if exists get_ct_next_city_list cascade;

create or replace function get_ct_next_city_list(
    in city_id integer,
    in dest_city_id integer,
    in train_id_list integer[]
)
    returns table
            (
                next_city_id integer
            )
    language plpgsql
as
$$
declare
    train_idi  integer;
    station_id integer;
begin
    <<get_ct_next_city_list_loop>>
    foreach train_idi in array train_id_list
        loop
            if ((select tfi_station_id
                 from train_full_info
                 where tfi_station_id = dest_city_id and tfi_train_id = train_idi) is not null) then
                continue ;
            end if;
            select get_station_id_from_cid_tid(city_id, train_idi) into station_id;
            while ((select * from get_next_station_id(train_idi, station_id)) is not null)
                loop
                    select query_city_id_from_sid__s__(
                                       (select get_next_station_id(train_idi, station_id))
                               )
                    into next_city_id;
                    return next;
                    station_id := station_id + 1;
                end loop;
        end loop;
end
$$;
