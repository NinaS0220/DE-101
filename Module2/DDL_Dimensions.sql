-- *************** SqlDBM: PostgreSQL ****************;
-- ***************************************************;
create schema dwh;

-- ************************************** calendar_dim
DROP TABLE dwh.calendar_dim;

CREATE TABLE dwh.calendar_dim
(
 date_id  serial NOT NULL,
 year     int NOT NULL,
 quarter  int NOT NULL,
 month    int NOT NULL,
 week     int NOT NULL,
 "date"     date NOT NULL,
 week_day int NOT NULL,
 CONSTRAINT PK_calendar PRIMARY KEY ( date_id )
);

--deleting rows
truncate table dwh.calendar_dim;
--
insert into dwh.calendar_dim 
select 
100+row_number() over() as date_id,  
       extract('year' from date)::int as year,
       extract('quarter' from date)::int as quarter,
       extract('month' from date)::int as month,
       extract('week' from date)::int as week,
       date::date,
       extract(DOW from date)::int as week_day
  from generate_series(date '2005-01-01',
                       date '2030-01-01',
                       interval '1 day')
       as t(date);
--checking
select * from dwh.calendar_dim; 

-- ************************************** customer_dim
DROP TABLE dwh.customer_dim;

CREATE TABLE dwh.customer_dim
(
 customer_id   varchar(8) NOT NULL,
 customer_name varchar(22) NOT NULL,
 CONSTRAINT PK_customer_dim PRIMARY KEY ( customer_id )
);

--deleting rows
truncate table dwh.customer_dim;
--inserting
insert into dwh.customer_dim 
select distinct customer_id, customer_name from public.orders;
--checking
select * from dwh.customer_dim cd;  

-- ************************************** geography_dim
DROP TABLE dwh.geography_dim;

CREATE TABLE dwh.geography_dim
(
 geo_id      serial NOT NULL,
 country     varchar(13) NOT NULL,
 city        varchar(17) NOT NULL,
 "state"       varchar(20) NOT NULL,
 region      varchar(7) NOT NULL,
 postal_code varchar(20) NULL,
 CONSTRAINT PK_geography_dim PRIMARY KEY ( geo_id )
);

--deleting rows
truncate table dwh.geography_dim;
--generating geo_id and inserting rows from orders
insert into dwh.geography_dim 
select 100+row_number() over(), country, city, state, region, postal_code from (select distinct country, city, state, region, postal_code from public.orders ) a;
--data quality check
select distinct country, city, state, region, postal_code from dwh.geography_dim
where country is null or city is null or postal_code is null;

-- City Burlington, Vermont doesn't have postal code
update dwh.geography_dim
set postal_code = '05401'
where city = 'Burlington'  and postal_code is null;

--also update source file
update public.orders
set postal_code = '05401'
where city = 'Burlington'  and postal_code is null;


select * from dwh.geography_dim
where city = 'Burlington'

-- ************************************** product_dim
DROP TABLE dwh.product_dim;

CREATE TABLE dwh.product_dim
(
 prod_id   serial NOT NULL,
 product_id   varchar(50) NOT NULL,
 category     varchar(15) NOT NULL,
 subcategory  varchar(11) NOT NULL,
 segment      varchar(11) NOT NULL,
 product_name varchar(130) NOT NULL,
 CONSTRAINT PK_product_dim PRIMARY KEY ( prod_id )
);

--deleting rows
truncate table dwh.product_dim ;
--
insert into dwh.product_dim 
select 100+row_number() over () as prod_id ,product_id, category, subcategory, segment, product_name from (select distinct product_id, product_name, category, subcategory, segment from public.orders ) a;--checking

select * from dwh.product_dim cd; 

-- ************************************** shipping_dim
DROP TABLE dwh.shipping_dim;

CREATE TABLE dwh.shipping_dim
(
 ship_id   serial NOT NULL,
 ship_mode varchar(14) NOT NULL,
 CONSTRAINT PK_shipping_dim PRIMARY KEY ( ship_id )
);

--deleting rows
truncate table dwh.shipping_dim;

--generating ship_id and inserting ship_mode from orders
insert into dwh.shipping_dim 
select 100+row_number() over(), ship_mode from (select distinct ship_mode from public.orders ) a;
--checking
select * from dwh.shipping_dim sd; 


-- ************************************** sales_fact
DROP TABLE dwh.sales_fact;


CREATE TABLE dwh.sales_fact
(
 row_id      serial NOT NULL,
 order_id    varchar(25) NOT NULL,
 sales       numeric(9,4) NOT NULL,
 quantity    int NOT NULL,
 discount    numeric(4,2) NOT NULL,
 profit      numeric(21,16) NOT NULL,
 ship_id     integer NOT NULL,
 prod_id     integer NOT NULL,
 customer_id varchar(8) NOT NULL,
 geo_id      integer NOT NULL,
 ship_date   date NOT NULL,
 order_date  date NOT NULL,
 returned    varchar(10) NULL,
 person      varchar(17) NOT NULL,
 CONSTRAINT PK_sales_fact PRIMARY KEY ( row_id ),
 CONSTRAINT FK_32 FOREIGN KEY ( ship_id ) REFERENCES dwh.shipping_dim ( ship_id ),
 CONSTRAINT FK_43 FOREIGN KEY ( prod_id ) REFERENCES dwh.product_dim ( prod_id ),
 CONSTRAINT FK_50 FOREIGN KEY ( customer_id ) REFERENCES dwh.customer_dim ( customer_id ),
 CONSTRAINT FK_61 FOREIGN KEY ( geo_id ) REFERENCES dwh.geography_dim ( geo_id )
);
CREATE INDEX fkIdx_33 ON dwh.sales_fact
(
 ship_id
);

CREATE INDEX fkIdx_44 ON dwh.sales_fact
(
 prod_id
);

CREATE INDEX fkIdx_51 ON dwh.sales_fact
(
 customer_id
);

CREATE INDEX fkIdx_62 ON dwh.sales_fact
(
 geo_id
);

--deleting rows
truncate table dwh.sales_fact;

insert into dwh.sales_fact 
select
     100+row_number() over() as row_id,
     o.order_id
     ,o.sales
     ,o.quantity
     ,o.discount
     ,o.profit
     ,s.ship_id
     ,p.prod_id
     ,cd.customer_id
     ,geo_id
     ,o.ship_date
     ,o.order_date
     ,r.returned 
     ,p2.person 
from public.orders o 
inner join dwh.shipping_dim s on o.ship_mode = s.ship_mode
inner join dwh.geography_dim g on o.postal_code = g.postal_code::int and g.country=o.country and g.city = o.city and o.state = g.state --City Burlington doesn't have postal code
inner join dwh.product_dim p on o.product_name = p.product_name and o.segment=p.segment and o.subcategory=p.subcategory and o.category=p.category and o.product_id=p.product_id 
inner join dwh.customer_dim cd on cd.customer_id=o.customer_id and cd.customer_name=o.customer_name 
left join public."returns" r on r.order_id = o.order_id 
left join public.people p2 on p2.region = o.region 

-- checking
select * from dwh.sales_fact f
left join dwh.calendar_dim cd 
on cd."date" = f.order_date


--checking
select count(*) from dwh.sales_fact sf
inner join dwh.shipping_dim s on sf.ship_id=s.ship_id
inner join dwh.geography_dim g on sf.geo_id=g.geo_id
inner join dwh.product_dim p on sf.prod_id=p.prod_id
inner join dwh.customer_dim cd on sf.customer_id=cd.customer_id;
