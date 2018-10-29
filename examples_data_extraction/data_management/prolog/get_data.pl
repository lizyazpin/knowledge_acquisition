
:- module(get_data,
    [
      extract_simple/2,
      extract_goal/2,
      extract_grasp/2,
      extract_put/2,
      extract_percep/2,
      load_episode/2,
      extract_write/1,
      extract_load_write/1
    ]).
:- use_module(library('semweb/rdf_db')).
:- use_module(library('semweb/rdfs')).
:- use_module(library('owl')).
:- use_module(library('jpl')).
:- use_module(library('rdfs_computable')).
:- use_module(library('owl_parser')).
:- use_module(library('comp_temporal')).
:- use_module(library('csv')).

/*Queries*/
owl_parse('episodes/Simulation/tablesetting_0/episode73/cram_log.owl').


load_episode(Exp,MemNum):-
  /*atom_concat(episodes,Exp,R1),
  atom_concat(R1,episode,R2),*/
  atom_concat('episodes/Simulation/tablesetting_0/episode',MemNum,R3),
  atom_concat(R3,'/cram_log.owl',R4),
  set_url_encoding(R4,R5),
  write(R5),nl,
  owl_parse(R5)
.

extract_simple(Task,Result):-
  findall([SRate,AvegTime,X,Y,Z,R1,R2,R3,R4],(
    entity(Act, [an, action, [task_context, Task],[task_success, TaskSuccess]]),
    (TaskSuccess == true ->
      SRate = 1;
    TaskSuccess == false ->
      SRate = 0
    ),
    occurs(Act, [Begin,End]), 
    entity(Base, [an, object, [srdl2comp:urdf_name, 'base_link']]),
    object_pose_at_time(Base, End, pose([X,Y,Z],[R1,R2,R3,R4])),
    AvegTime is End - Begin
  ), 
  Result)
.

/*Task = 'GOAL-PERFORM'*/
extract_goal(Task,Result):-
  findall([SRate,AvegTime,X,Y,Z,R1,R2,R3,R4],(
    entity(Act, [an, action, [task_context, Task],[task_success, TaskSuccess]]),
    (TaskSuccess == true ->
      SRate = 1;
    TaskSuccess == false ->
      SRate = 0
    ),
    occurs(Act, [Begin,End]), 
    entity(Base, [an, object, [srdl2comp:urdf_name, 'base_link']]),
    object_pose_at_time(Base, End, pose([X,Y,Z],[R1,R2,R3,R4])),
    AvegTime is End - Begin
  ), Result)
.

/*Task = 'GRASP'*/
extract_grasp(Task,Result):-
  findall([SRate,AvegTime,X,Y,Z,R1,R2,R3,R4,XO,YO,ZO,RO1,RO2,RO3,RO4,Obj],(
    entity(Act, [an, action, [task_context, Task],[task_success, TaskSuccess],[object_acted_on, Desig]]),
    (TaskSuccess == true ->
      SRate = 1;
    TaskSuccess == false ->
      SRate = 0
    ),
    occurs(Act, [Begin,End]), 
    entity(Base, [an, object, [srdl2comp:urdf_name, 'base_link']]),
    object_pose_at_time(Base, End, pose([X,Y,Z],[R1,R2,R3,R4])),
    mng_designator_props(Desig, 'TYPE', Obj),
    mng_designator_location(Desig,L,End),matrix_translation(L,[XO,YO,ZO]),matrix_rotation(L,[RO1,RO2,RO3,RO4]),
    AvegTime is End - Begin
  ), Result)
.

/*Task = 'PUTDOWN'*/
extract_put(Task,Result):-
  findall([SRate,AvegTime,X,Y,Z,R1,R2,R3,R4,XO,YO,ZO,RO1,RO2,RO3,RO4,Obj],(
    entity(Act, [an, action, [task_context, Task],[task_success, TaskSuccess],[object_acted_on, Desig],[putdown_location,D]]),
    (TaskSuccess == true ->
      SRate = 1;
    TaskSuccess == false ->
      SRate = 0
    ),
    occurs(Act, [Begin,End]), 
    entity(Base, [an, object, [srdl2comp:urdf_name, 'base_link']]),
    object_pose_at_time(Base, End, pose([X,Y,Z],[R1,R2,R3,R4])),
    mng_designator_props(Desig, 'TYPE', Obj),
    mng_designator_location(D,L,End),matrix_translation(L,[XO,YO,ZO]),matrix_rotation(L,[RO1,RO2,RO3,RO4]),
    AvegTime is End - Begin
  ), Result)
.

/*Task = 'UIMA-PERCEIVE'*/
extract_percep(Task,Result):-
  findall([SRate,AvegTime,X,Y,Z,R1,R2,R3,R4,XO,YO,ZO,RO1,RO2,RO3,RO4,Obj],(
    entity(Act, [an, action, [task_context, Task],[task_success, TaskSuccess],[perception_request, Desig]]),
    (TaskSuccess == true ->
      SRate = 1;
    TaskSuccess == false ->
      SRate = 0
    ),
    occurs(Act, [Begin,End]), 
    entity(Base, [an, object, [srdl2comp:urdf_name, 'base_link']]),
    object_pose_at_time(Base, End, pose([X,Y,Z],[R1,R2,R3,R4])),
    mng_designator_props(Desig, 'TYPE', Obj),
    mng_designator_location(Desig,L,End),matrix_translation(L,[XO,YO,ZO]),matrix_rotation(L,[RO1,RO2,RO3,RO4]),
    AvegTime is End - Begin
  ), Result)
.


extract_write(Task):-
  read(Mem),
  (Task == 'UIMA-PERCEIVE' -> extract_percep(Task,PResult),Name='Perceive';
   Task == 'PUTDOWN' -> extract_put(Task,PResult),Name='Putdown';
   Task == 'GRASP' -> extract_grasp(Task,PResult),Name='Grasp';
   Task == 'GOAL-PERFORM' -> extract_goal(Task,PResult),Name='GoalPerform'
  ),  
  length(PResult,Len),
  write('Test finished'),nl,
  (Len\=0->Result=PResult,TNames=['SRate','AvegTime','X','Y','Z','R1','R2','R3','R4','XO','YO','ZO','RO1','RO2','RO3','RO4','Obj]'];
   Len==0->extract_simple(Task,Result),TNames=['SRate','AvegTime','X','Y','Z','R1','R2','R3','R4]']
  ),
  atom_concat('Ep',Mem,N1),
  atom_concat(N1,Name,N2),
  atom_concat(N2,'.csv',N3),
  absolute_file_name(N3,N4),
  write('File name '),write(N4),nl,
  write('Data: '),write(Result),nl,
  append(TNames,Result,Data),
  open(N4,write,Stream),
  write(Stream,Data),
  close(Stream)
.

extract_load_write(Task):-
  /*read(Exp),*/
  read(Mem),
  load_episode(Exp,Mem),
  write('Episode loaded'),nl,
  (Task == 'UIMA-PERCEIVE' -> extract_percep(Task,PResult),Name='Perceive';
   Task == 'PUTDOWN' -> extract_put(Task,PResult),Name='Putdown';
   Task == 'GRASP' -> extract_grasp(Task,PResult),Name='Grasp';
   Task == 'GOAL-PERFORM' -> extract_goal(Task,PResult),Name='GoalPerform'
  ),  
  length(PResult,Len),
  write('Test finished'),nl,
  (Len\=0->Result=PResult;
   Len==0->extract_simple(Task,Result)
  ),
  atom_concat('Ep',Mem,N1),
  atom_concat(N1,Name,N2),
  atom_concat(N2,'.csv',N3),
  absolute_file_name(N3,N4),
  write('File name '),write(N4),nl,
  write('Data: '),write(Result),nl,
  append(['SRate','AvegTime','X','Y','Z','R1','R2','R3','R4','XO','YO','ZO','RO1','RO2','RO3','RO4','Obj],'],Result,Data),
  open(N4,write,Stream),
  write(Stream,Data),
  close(Stream)
.
/*csv_write_file('output.csv', Rows).*/
