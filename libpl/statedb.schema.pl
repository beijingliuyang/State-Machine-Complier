dbase(statedb,[node,transition]).

table(node,[id,"name",type]).
table(transition,[id,startsAt,endsAt]).

tuple(node,L):-node(A1,A2,A3),L=[A1,A2,A3].
tuple(transition,L):-transition(A1,A2,A3),L=[A1,A2,A3].

nodeALL(A1,A2,A3):-node(A1,A2,A3).
transitionALL(A1,A2,A3):-transition(A1,A2,A3).
