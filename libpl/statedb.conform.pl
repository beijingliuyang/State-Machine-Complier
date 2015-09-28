/* suppose: 
1. FSM might have more than one start node and more than one stop node. 
2. FSM might contain transition ending with start node.
3. FSM might contain different nodeid with the same name but different type.
4. Once transition ends with a stop node, FSM stops forever. Accordingly, the transition starts at stop node is invalid.
5. FSM does not allow the existence of alone node, which is not appeared in any transition.
6. FSM does not allow incomplete database information (null is not allowed in tuple).
*/
:- discontiguous table/2.
:- multifile run/0, dbase/2, table/2.



/* isError(S,N):- tell(user_error),write(S),writeln(N),told.*/

isError(S,N):- write(S),writeln(N).

/* the following rule/incantation I owe to Jan Wielemaker -- I never
   would have figured this out myself. this is used in comparing
   two prolog atoms (I1,I2), such as @I1 @> @I2.  */

:-op(200,fy,@).


/* Judge whether all attribute id names within the node table are unique. */
findNodePair(Name,Type) :- node(NID1,Name,Type),node(NID2,Name,Type), @NID1 @< @NID2.
nodeuniqueNames :- forall(findNodePair(Name,Type),isError('unique node names constraint violated: ',[Name,Type])).

/* Judge whether all attribute id names within the transition table are unique. */
findTransitionPair(StartsAt,EndsAt) :- transition(TID1,StartsAt,EndsAt),transition(TID2,StartsAt,EndsAt), @TID1 @< @TID2.
transitionuniqueNames :- forall(findTransitionPair(StartsAt,EndsAt),isError('unique transition pair constraint violated: ',[StartsAt,EndsAt])).

/* Judge whether there is a nodeid which have more than one name or type */
findNodeidPair(NID) :- node(NID,Name1,_),node(NID,Name2,_), @Name1 @< @Name2.
findNodeidPair(NID) :- node(NID,_,Type1),node(NID,_,Type2), @Type1 @< @Type2.
nodeIDunique :- forall(findNodeidPair(NID),isError('unique nodeid constraint violated: ',NID)).

/* Judge whether there is a transid which starts or ends at more than one node */
findTransidPair(TID) :- transition(TID,StartsAt1,_),transition(TID,StartsAt2,_), @StartsAt1 @< @StartsAt2.
findTransidPair(TID) :- transition(TID,_,EndsAt1),transition(TID,_,EndsAt2), @EndsAt1 @< @EndsAt2.
transIDunique :- forall(findTransidPair(TID),isError('unique transid constraint violated: ',TID)).

/* Judge whether there is a null node */
findnullnode(NID) :- node(NID,'null',_).
findnullnode(NID) :- node(NID,_,'null').
findnullnid(Name,Type) :- node('null',Name,Type).
nullnodeconstraint :- forall(findnullnode(NID),isError('Null node constraint violated: ',NID)),
                      forall(findnullnid(Name,Type),isError('Null node constraint violated: ',[Name,Type])).
 
/* Judge whether there is a null transition */
findnulltransition(TID) :- transition(TID,null,_).
findnulltransition(TID) :- transition(TID,_,null).
findnulltid(StartsAt,EndsAt) :- transition('null',StartsAt,EndsAt).
nulltransitionconstraint :- forall(findnulltransition(TID),isError('Null transition constraint violated: ',TID)),
                            forall(findnulltid(StartsAt,EndsAt),isError('Null transition constraint violated: ',[StartsAt,EndsAt])).

/* Judge whether there is a transition starting with stop node. */
findStartAtStop(TID) :- transition(TID,NID,_),node(NID,_,stop).
startsAtNonStopConstraint :- forall(findStartAtStop(TID),isError('start at non-stop node constraint violated: ',TID)).

/* Judge whether there is a node which is not covered in any transition */
coveredNode(NID) :- node(NID,_,_),transition(_,NID,_).
coveredNode(NID) :- node(NID,_,_),transition(_,_,NID).
findEmptyNode(NID,Name,Type) :- node(NID,Name,Type),not(coveredNode(NID)).
emptyNodeConstraint :- forall(findEmptyNode(NID,Name,Type),isError('Empty Node constraint violated: ',[NID,Name,Type])).

/* Judge whether there is a transition contain non-existent node */
existentNodeTrans(TID,StartsAt,EndsAt) :- transition(TID,StartsAt,EndsAt),node(StartsAt,_,_),node(EndsAt,_,_).
findNonexistentNodeTrans(TID,StartsAt,EndsAt) :- transition(TID,StartsAt,EndsAt),not(existentNodeTrans(TID,StartsAt,EndsAt)).
nonExistentNodeConstraint :- forall(findNonexistentNodeTrans(TID,StartsAt,EndsAt),isError('Non-existent Node constraint violated: ',[TID,StartsAt,EndsAt])).

/* Judge whether there is a node that is not reachable from start node */
:- dynamic q/1.
leafof(start,N) :- transition(_,NID,N),node(NID,_,start).
leafof(start,N) :- transition(_,M,N),@M \== @N,not(q(M)),assert(q(N)),leafof(start,M),retract(q(N)).
:- retractall(q()).
nonreachablenode(NID) :- node(NID,_,Type),not(leafof(start,NID)),not(Type =='start').
nonReachableNodeConstraint :- forall(nonreachablenode(NID),isError('Non-reachable Node constraintviolated: ',NID)).

/* Judge whether there is a node that cannot transit to stop node */
:- dynamic p/1.
endof(N,stop) :- transition(_,N,NID),node(NID,_,stop).
endof(N,stop) :- transition(_,N,M),@M \== @N,not(p(M)),assert(p(N)),endof(M,stop),retract(p(N)).
:- retractall(p()).
nontransitablenode(NID) :- node(NID,_,Type),not(endof(NID,stop)),not(Type =='stop').
nontransitableNodeConstraint :- forall(nontransitablenode(NID),isError('Transit to stop Node constraintviolated: ',NID)).

run :- nodeuniqueNames, transitionuniqueNames, nodeIDunique, transIDunique,nullnodeconstraint,
     nulltransitionconstraint,startsAtNonStopConstraint, emptyNodeConstraint,
     nonExistentNodeConstraint,nonReachableNodeConstraint,nontransitableNodeConstraint.
:-style_check(-discontiguous).


