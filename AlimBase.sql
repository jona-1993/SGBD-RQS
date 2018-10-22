-- Insert Certifications

insert into certification values (1, 'G', 'GENERAL AUDIENCES','All ages admitted.', 'Nothing that would offend parents for viewing by children.');
insert into certification values (2, 'PG', 'PARENTAL GUIDANCE SUGGESTED', 'Some material may not be suitable for children.', 'Parents urged to give “parental guidance.” May contain some material parents might not like for their young children');
insert into certification values (3, 'PG-13', 'PARENTS STRONGLY CAUTIONED', 'Some material may be inappropriate for children under 13.', 'Parents are urged to be cautious. Some material may be inappropriate for pre-teenagers.');
insert into certification values (4, 'R', 'RESTRICTED', 'Under 17 requires accompanying parent or adult guardian.', 'Contains some adult material. Parents are urged to learn more about the film before taking their young children with them.');
insert into certification values (5, 'NC-17', 'NO ONE 17 AND UNDER ADMITTED', 'No One 17 and Under Admitted.','Clearly adult. Children are not admitted.');


-- Insert Status

insert into status values(1, 'Canceled');
insert into status values(2, 'In Production');
insert into status values(3, 'Planned');
insert into status values(4, 'Post Production');
insert into status values(5, 'Released');
insert into status values(6, 'Rumored');


commit;
