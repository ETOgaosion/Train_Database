-- must in order --
drop table if exists seat_type;
drop table if exists order_status;
drop table if exists orders;
drop table if exists city_train;
drop table if exists station_tickets;
drop table if exists train_full_info;
drop table if exists station_list;
drop table if exists city;
drop table if exists train;
drop table if exists users;

-- must in order --
create table if not exists users (
	u_uid       serial primary key,
	u_email     varchar(20) not null,
	u_user_name varchar(20) unique,
	u_password  varchar(20) not null,
	u_real_name varchar(20) not null,
	u_tel_num   varchar(20) unique,
	u_admin     bool        not null
);

create table if not exists train (
	t_train_id   serial primary key,
	t_train_type varchar(1)  not null,
	t_train_name varchar(10) not null
);

create table if not exists city (
	c_city_id   serial primary key,
	c_city_name varchar(20) not null
);

create table if not exists city_train (
	ct_city_id      integer,
	ct_train_id     integer,
	ct_next_city_id integer,
	ct_prior        integer not null,
	primary key (ct_city_id, ct_train_id),
	foreign key (ct_city_id) references city (c_city_id),
	foreign key (ct_train_id) references train (t_train_id),
	foreign key (ct_next_city_id) references city (c_city_id)
);

create table if not exists station_list (
	s_station_id      serial primary key,
	s_station_name    varchar(20) not null,
	s_station_city_id integer     not null,
	foreign key (s_station_city_id) references city (c_city_id)
);

create table if not exists train_full_info (
	tfi_train_id      integer,
	tfi_station_id    integer,
	tfi_station_order integer       not null,
	tfi_arrive_time   time          not null,
	tfi_leave_time    time          not null,
	tfi_distance      integer       not null,
	tfi_price_yz      decimal(5, 1) not null default 0,
	tfi_price_rz      decimal(5, 1) not null default 0,
	tfi_price_yw_s    decimal(5, 1) not null default 0,
	tfi_price_yw_z    decimal(5, 1) not null default 0,
	tfi_price_yw_x    decimal(5, 1) not null default 0,
	tfi_price_rw_s    decimal(5, 1) not null default 0,
	tfi_price_rw_x    decimal(5, 1) not null default 0,
	primary key (tfi_train_id, tfi_station_id),
	foreign key (tfi_train_id) references train (t_train_id),
	foreign key (tfi_station_id) references station_list (s_station_id)
);

create table if not exists station_tickets (
	stt_station_id integer,
	stt_train_id   integer,
	stt_date       date    not null,
	stt_num_yz     integer not null default 0,
	stt_num_rz     integer not null default 0,
	stt_num_yw_s   integer not null default 0,
	stt_num_yw_z   integer not null default 0,
	stt_num_yw_x   integer not null default 0,
	stt_num_rw_s   integer not null default 0,
	stt_num_rw_x   integer not null default 0,
	primary key (stt_station_id, stt_train_id),
	foreign key (stt_station_id) references station_list (s_station_id),
	foreign key (stt_train_id) references train (t_train_id),
	foreign key (stt_station_id, stt_train_id) references train_full_info (tfi_station_id, tfi_train_id)
);

create table if not exists orders (
	o_oid           serial primary key,
	-- allow uid to be null, only fill in when order confirm --
	o_uid           integer,
	o_train_id      integer       not null,
	o_date          date          not null,
	o_start_station integer       not null,
	o_end_station   integer       not null,
	o_price         decimal(5, 1) not null,
	o_seat_type     seat_type     not null,
	o_seat_id       integer       not null,
	o_status        order_status  not null,
	o_effect_time   timestamp     not null,
	foreign key (o_uid) references users (u_uid),
	foreign key (o_train_id) references train (t_train_id),
	foreign key (o_start_station) references station_list (s_station_id),
	foreign key (o_end_station) references station_list (s_station_id)
);