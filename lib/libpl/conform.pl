/* file conform.pl */

/* the following commands eliminate aggravating warnings 
*   about tuples of a table not being listed sequentially **/

:- discontiguous dbase/2, table/2.
:- multifile run/0, dbase/2, table/2.

/* conformance  utility predicates */

/* isError(S,N):- tell(user_error),write(S),writeln(N),told.*/

isError(S,N):- write(S),writeln(N).

/* the following rule/incantation I owe to Jan Wielemaker -- I never
   would have figured this out myself. this is used in comparing
   two prolog atoms (I1,I2), such as @I1 @> @I2.  */

:-op(200,fy,@).

