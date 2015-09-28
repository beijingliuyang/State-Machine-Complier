dbase(fsm,[node,transition]).

table(node,[nodeid,name,type]).
table(transition,[transid,startsAt,endsAt]).


tuple(class,L):-node(A1,A2,A3),L=[A1,A2,A3].
tuple(method,L):-transition(A1,A2,A3),L=[A1,A2,A3].


classALL(A1,A2,A3):-node(A1,A2,A3).
methodALL(A1,A2,A3):-transition(A1,A2,A3).

