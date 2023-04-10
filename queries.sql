-- Напишите запросы, которые выводят следующую информацию:
-- 1. Название компании заказчика (company_name из табл. customers) и ФИО сотрудника, работающего над заказом этой компании (см таблицу employees),
-- когда и заказчик и сотрудник зарегистрированы в городе London, а доставку заказа ведет компания United Package (company_name в табл shippers)

-- вариант 1 (join)

--explain analyze --time = 0.282..0.507
select 
	o.order_id, 
	o.customer_id, 
	c.company_name, 
	o.employee_id, e.first_name || ' '|| e.last_name as fullname_employee 
from orders o 
join customers c on o.customer_id = c.customer_id and c.city = 'London'
join employees e on o.employee_id = e.employee_id and e.city = 'London'
join shippers s on o.ship_via = s.shipper_id and s.company_name = 'United Package';

-- вариант 2 (подзапросы)

--explain analyze --time = 0.439..0.950
select 
	o.order_id, 
	o.customer_id, 
	c2.company_name, 
	o.employee_id, 
	e2.first_name || ' '|| e2.last_name as fullname_employee 
from orders o
join customers c2 on o.customer_id = c2.customer_id
join employees e2 ON e2.employee_id = o.employee_id 
where o.customer_id in (select c.customer_id from customers c where c.city = 'London')
and o.employee_id in (select e.employee_id from employees e where e.city = 'London')
and o.ship_via in (select s.shipper_id  from shippers s where s.company_name = 'United Package');

-- вариант 3 (cte)
--explain analyze --time = 0.213..0.390
with cte_customers as (
		select 
			c.customer_id, 
			c.company_name 
		from customers c 
		where c.city = 'London'
),
cte_employees as(
		select 
			e.employee_id, 
			e.last_name, 
			e.first_name 
		from employees e where e.city = 'London'
),
cte_shippers as (
		select 
			s.shipper_id 
		from shippers s 
		where s.company_name = 'United Package'
)
select 
		o.order_id, 
		o.customer_id, 
		cc.company_name, 
		o.employee_id, 
		ce.first_name || ' '|| ce.last_name as fullname_employee 
from orders o 
join cte_customers cc on o.customer_id = cc.customer_id
join cte_employees ce on o.employee_id = ce.employee_id
join cte_shippers cs on o.ship_via = cs.shipper_id;


-- 2. Наименование продукта, количество товара (product_name и units_in_stock в табл products),
-- имя поставщика и его телефон (contact_name и phone в табл suppliers) для таких продуктов,
-- которые не сняты с продажи (поле discontinued) и которых меньше 25 и которые в категориях Dairy Products и Condiments.
-- Отсортировать результат по возрастанию количества оставшегося товара.
select 
	p.product_name,
	p.units_in_stock,
	p.supplier_id,
	s.contact_name,
	s.phone, 
	p.category_id,
	c.category_name 
from products p
join suppliers s on p.supplier_id = s.supplier_id
join categories c on p.category_id = c.category_id and c.category_name in ('Dairy Products', 'Condiments')
where p.discontinued = 0 and p.units_in_stock < 25
order by p.units_in_stock; 

-- 3. Список компаний заказчиков (company_name из табл customers), не сделавших ни одного заказа

-- вариант 1 (join)

--explain analyze --time = 0.439
select 
	c.customer_id,
	c.company_name
from customers c 
left join orders o on c.customer_id = o.customer_id 
where o.order_id is null;

-- вариант 2 (подзапросы)

explain analyze --time = 0.533
select 
	c.customer_id,
	c.company_name
from customers c 
where c.customer_id not in (select distinct o.customer_id from orders o);


-- 4. уникальные названия продуктов, которых заказано ровно 10 единиц (количество заказанных единиц см в колонке quantity табл order_details)
-- Этот запрос написать именно с использованием подзапроса.
select 
	p.product_name
from products p 
where p.product_id in (select distinct od.product_id from order_details od where od.quantity = 10)
order by p.product_name;

