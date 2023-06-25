DROP TABLE IF exists bookings.results;
CREATE TABLE bookings.results (id int, response text NULL);

--------------1---------------
insert into bookings.results
select 1, max(t1.pass_cnt)
from (select
      book_ref
      ,count(passenger_id) pass_cnt
      from bookings.tickets
      group by book_ref
      ) t1;

--------------2---------------
insert into bookings.results
select 2, count(*)
          from  (
                select book_ref, count(passenger_id)
                from bookings.tickets
                group by book_ref
                having count(passenger_id) >
                		(select
                		avg(pass_cnt)
                		from (select
                			 book_ref
                			 ,count(passenger_id) pass_cnt
                			 from bookings.tickets
                           group by book_ref
               			 ) t1
               		)
                 ) t2;

--------------3---------------
insert into bookings.results
 select 3, count((select passenger
           from (
           	select book_ref
           	,STRING_AGG (passenger_name, ',' ORDER BY passenger_name) passenger
           	from bookings.tickets
           	where book_ref in (select book_ref
           			   from bookings.tickets
           			   group by book_ref having count(*)=5
           			  )
           	group by book_ref order by STRING_AGG (passenger_name, ',' ORDER BY passenger_name)  ) t1
           group by passenger
           having count(*)>=2));

--------------4---------------
insert into bookings.results
select 4, book_ref|| '|' ||STRING_AGG ((passenger_name|| '|' ||contact_data), ',')
from bookings.tickets
where
book_ref in (select book_ref from bookings.tickets group by book_ref having count(*)=3)
group by book_ref;

--------------5---------------
insert into bookings.results
select 5, max(t3.flights)
from(
	select
	t1.book_ref
	, count(distinct t2.flight_id) flights
	from bookings.Tickets t1
	left join Ticket_flights t2 on t1.ticket_no=t2.ticket_no
	group by t1.book_ref
	) t3;

--------------6---------------
insert into bookings.results
select 6, max(t3.flights)
from(
	select t1.book_ref
	, t1.passenger_id
	, count(distinct t2.flight_id) flights
	from bookings.Tickets t1
	join Ticket_flights t2 on t1.ticket_no =t2.ticket_no
	group by t1.book_ref, t1.passenger_id
	) t3;

--------------7---------------
insert into bookings.results
select 7, max(t3.flights_cnt)
from (
	 select t1.passenger_id, count(*) flights_cnt
	 from bookings.Tickets t1
	 inner join Ticket_flights t2 on t1.ticket_no=t2.ticket_no
	 group by t1.passenger_id
	 ) t3;

--------------8---------------
insert into bookings.results
select 8, t1.passenger_id|| '|' || t1.passenger_name|| '|' ||  t1.contact_data|| '|' ||  sum(amount)
from bookings.Tickets as t1
join Ticket_flights as t2 on t1.ticket_no =t2.ticket_no
group by t1.passenger_id, t1.passenger_name, t1.contact_data
having sum(t2.amount) = (
					 select min(t3.amount_cnt)
					 from (
						  select
						  t1.passenger_name
						  ,sum(t2.amount) as amount_cnt
						  from bookings.Tickets as t1
						  join Ticket_flights as t2 on t1.ticket_no =t2.ticket_no
						  group by  t1.passenger_name
						  ) t3
					  )
order by t1.passenger_id, t1.passenger_name, t1.contact_data;

--------------9---------------
insert into bookings.results
select 9, t1.passenger_id|| '|' || t1.passenger_name|| '|' ||  t1.contact_data|| '|' ||  cnt
from bookings.Tickets t1
join(
	select
	passenger_id
	,sum(actual_duration) cnt
	,RANK () OVER (ORDER BY sum(actual_duration) desc) ranking
	from bookings.Tickets t1
	join Ticket_flights t2 on t1.ticket_no =t2.ticket_no
	join bookings.flights_v t3 on t3.flight_id = t2.flight_id
	group by passenger_id
	having sum(actual_duration) is not null
	) t2 on t1.passenger_id = t2.passenger_id and t2.ranking=1
order by t1.passenger_id, t1.passenger_name, t1.contact_data;

--------------10---------------
insert into bookings.results
select 10, city
from bookings.airports
group by city
having count(*)>1
order by city;

--------------11---------------
insert into bookings.results
select 11, t1.departure_city
from (
	 select
	 departure_city
	 ,count(distinct arrival_city)
	 ,RANK () OVER (ORDER BY count(distinct arrival_city) asc) ranking
	 from bookings.flights_v
	 group by departure_city
	 ) t1
where t1.ranking=1
order by t1.departure_city;

--------------12---------------
insert into bookings.results
select 12,t1.departure_city || '|' || t1.departure_city_2
from (
	 select
	 t1.departure_city
	 , t2.departure_city departure_city_2
	 from bookings.routes t1
	 inner join bookings.routes t2 on t1.departure_city<> t2.departure_city
	 group by t1.departure_city, t2.departure_city
	 ) t1
left join (
		  select
		  departure_city
		  ,arrival_city
		  from bookings.routes
		  group by
		  departure_city
		  ,arrival_city
		  ) t2 on t1.departure_city = t2.departure_city and t1.departure_city_2 = t2.arrival_city
where t2.departure_city is null
and t2.arrival_city is null
and t1.departure_city < t1.departure_city_2
order by t1.departure_city, t1.departure_city_2;

--------------13---------------
insert into bookings.results
select distinct 13, arrival_city
from  bookings.routes
where arrival_city not in
						   (select
						   arrival_city
						   from bookings.routes
						   where departure_city = 'Москва'
						   )
and arrival_city!='Москва';

--------------14---------------
insert into bookings.results
select 14, t2.model
from bookings.flights t1
join bookings.aircrafts t2 on t1.aircraft_code = t2.aircraft_code
where t1.status!='Cancelled'
group by t2.model
order by count(*) desc limit 1;

--------------15---------------
insert into bookings.results
select 15, t2.model
from  bookings.flights t1
join bookings.aircrafts t2 on t1.aircraft_code = t2.aircraft_code
join bookings.Ticket_flights t3 on t3.flight_id = t1.flight_id
join bookings.Tickets t4 on t4.ticket_no =t3.ticket_no
where t1.status!='Cancelled'
group by t2.model
order by count(*) desc limit 1;

--------------16---------------
insert into bookings.results
select 16, (DATE_PART('day', count_all) * 24 + DATE_PART('hour', count_all)) * 60 + DATE_PART('minute',count_all)
from (
	 select (sum(scheduled_duration) - sum(actual_duration)) as count_all
	 from bookings.flights_v
	 where status = 'Arrived'
	 ) as a;

--------------17---------------
insert into bookings.results
select distinct 17, coalesce (arrival_city)
from bookings.flights_v
where departure_city = 'Санкт-Петербург'
and status = 'Arrived'
and date_trunc('day', actual_departure) = '2016-09-13';

--------------18---------------
insert into bookings.results
select distinct 18, flight_id || '|' ||  flight_no|| '|' || departure_city || '|' || arrival_city
from bookings.flights_v
where flight_id = (
				  select flight_id
				  from bookings.ticket_flights
				  group by flight_id
				  order by sum(amount) desc limit 1
				  );

--------------19---------------
insert into bookings.results
select distinct 19, date_trunc('day', actual_departure)
from bookings.flights_v
where status = 'Arrived'
group by date_trunc('day', actual_departure)
having count(*) = (
				  select count(*)
				  from bookings.flights_v
				  where status = 'Arrived'
				  group by date_trunc('day', actual_departure)
				  order by count(*) limit 1
				  );

--------------20---------------
insert into bookings.results
select 20, avg(cnt)
from (select
	 count(*) as cnt
	 ,date_trunc('day', actual_departure)
	 from  bookings.flights_v
	 where departure_city = 'Москва'
	 and status = 'Arrived'
	 and date_trunc('month', actual_departure) = '2017-09-01'
	 group by date_trunc('day', actual_departure)
	 ) t1;

--------------21---------------
insert into bookings.results
select 21, departure_city
from bookings.flights_v
group by departure_city
having avg(actual_duration)  > '03:00:00'
order by avg(actual_duration) desc limit 5;

