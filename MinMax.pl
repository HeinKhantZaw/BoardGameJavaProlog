:- module(minMax,[minimax/5,getI/4,changeCol/2]).

%showa(B):-    % Put all the ovals inside a list - B
%    bagof(oval(I,X,Y,C) , oval(I,X,Y,C) ,B).
%Declare the min and max values for the winning position
minVal(1).
maxVal(7).
% The Depth of the searching tree
getN(3).

comTurn(C):- C = blue.

% Stop if it find winning position
minimax(C,Pos,_,Val,_) :-
    changeCol(C,CN),
    util(CN,Pos,Val),(Val =:= 1 ; Val =:= 7),!.

minimax(C,Pos,BestNextPos, Val,N) :-                     % Pos has successors
     getN(D),N <  D, moveN(C,Pos,NextPosList),     % BestNextPos is a list of lists - each list represents an optional next move
     best(C,NextPosList, BestNextPos, Val, N), !.

minimax(C,Pos,_,Val,_) :-                     % Pos has no successors
    changeCol(C,CN),
    util(CN,Pos,Val).
%Get the move with the best move
best(C,[Pos,[]], Pos, Val,N) :-                                % There is no more position to compare
     N1 is N + 1, changeCol(C,CN),
     minimax(CN,Pos, _, Val,N1), !.

best(C,[Pos], Pos, Val,N) :-                                % There is no more position to compare
     N1 is N + 1, changeCol(C,CN),
     minimax(CN,Pos, _, Val,N1), !.

best(C,[Pos1 | PosList], BestPos, BestVal,N) :-             % There are other positions
    N1 is N + 1, changeCol(C,CN),    % Increase depth and change to the color of the next player
    minimax(CN,Pos1, _, Val1,N1),      % Get the best val and for the Pos1 mvoe
    best(C,PosList, Pos2, Val2,N),      % Check the rest of the possible moves
    betterOf(CN,Pos1,Val1,Pos2,Val2,BestPos,BestVal).     % Take the better move

betterOf(C,Pos0, Val0, _, Val1, Pos0, Val0) :-   % Pos0 better than Pos1
    min_to_move(C),                         % MIN to move in Pos0
    Val0 > Val1, !.                            % MAX prefers the greater value

betterOf(C,Pos0, Val0, _, Val1, Pos0, Val0) :-   % Pos0 better than Pos1
    max_to_move(C),                         % MAX to move in Pos0
    Val0 < Val1, !.                            % MIN prefers the lesser value

betterOf(_,_, _, Pos1, Val1, Pos1, Val1).        % Otherwise Pos1 better than Pos0

min_to_move(M):- comTurn(C), M \= C.
max_to_move(M):- comTurn(C), M == C.

changeCol(C,CN):- (C == 'blue',CN = 'red');(C == 'red',CN = 'blue').

%Calculate the val of board- heuristic
% Central oval is in the current's player color
util(C,Pos,Val):-
    Pos = [Zero|Res],
    Zero = oval(_,_,_,C),
    getI(Res,I1,I2,C), S is I2 - I1,
    calcValZ(C,Pos,S,Val),!.
%Middle oval is black
util(C,Pos,Val):-
    Pos = [Zero|Res],
    Zero = oval(_,_,_,black),
    getI(Res,I1,I2,C), S is I2 - I1,
    calcValB(C,Pos,S,Val),!.
%The color of the central oval is in the opposite color
util(C,Pos,Val):-
    Pos = [_|Res],
    %Zero = oval(_,_,_,C1),
    getI(Res,I1,I2,C), S is I2 - I1,
    calcValD(C,Pos,S,Val).


calcValZ(C,_,4,Val):- comTurn(CT),minVal(Mi),maxVal(Ma),((C == CT, Val = Ma,!);(Val = (Mi),!)). % 7 - computer wins, 1 - player wins
calcValZ(C,_,_,Val):- comTurn(CT),(C == CT, Val = 5,!);(Val = (3)).
calcValB(C,_,4,Val):- comTurn(CT),(C == CT, Val = 6,!);(Val = (2),!).
calcValB(C,_,_,Val):- comTurn(CT),(C == CT, Val = 4,!);(Val = (4),!).
calcValD(C,_,4,Val):- comTurn(CT),(C == CT, Val = 5,!);(Val = (3),!).
calcValD(C,_,_,Val):- comTurn(CT),(C == CT, Val = 4,!);(Val = (4),!).

% Check if one of the C1 C2 is black and the two others are equal
comColor2(C,C1,C2):-
    (C1 == C , C2 == 'black');(C1 == 'black',C2 == C).

%Calculate next move
moveN(C,Pos,Res):-
    Pos = [_|Bres],findC2(C,Pos,Bres,Res).


findC2(_,_,[],[]):-!.
findC2(C,Pos,[P],Return):-  % when the remaining list [P] contains only one item - P
     Pos = [Zero,One|_],
     P = oval(IP,_,_,CP), Zero = oval(IZ,_,_,CZ),One = oval(IO,_,_,CO),
     (
       comColor2(C,CP,CO), % Check possible move to the neighbor
     !,(
         (comColor2(C,CP,CZ), % Check possible move to the middle
          Return = [New|List],replace(Pos,IP,IO,New),replace(Pos,IP,IZ,TList),List = [TList])
             ;(replace(Pos,IP,IO,TempRe),Return = [TempRe])
        )
     ;
       (comColor2(C,CP,CZ),
                 !,(replace(Pos,IP,IZ,TempReturn),Return = [TempReturn])
                 ; Return = [])    %findC2(_,_,[],Return))
       ).


findC2(C,Pos,Ps,Return):-  % At the first call Ps contains Pos from one(not zero)

     Pos = [Zero|_],
     Zero = oval(IZ,_,_,CZ),
     Ps = [P1|Ps2], Ps2 = [P2|_],
     P1 = oval(I1,_,_,C1), P2 = oval(I2,_,_,C2),
     (
     comColor2(C,C1,C2),
     !, (Return = [New|List],replace(Pos,I1,I2,New),(comColor2(C,C1,CZ),!,( List = [New2|List2],replace(Pos,I1,IZ,New2),
                                                   findC2(C,Pos,Ps2,List2))
                                                  ;
                                                   findC2(C,Pos,Ps2,List)))
     ;
       (comColor2(C,C1,CZ),!,(Return = [New|List],replace(Pos,I1,IZ,New),findC2(C,Pos,Ps2,List))
        ;
        findC2(C,Pos,Ps2,Return))
     ).
     % Replace the color of two ovals in a given list (board) - represent a move
    replace([B|Bs],I1,I2,[NB|NBs]):-
    B = oval(I,X,Y,C),(I =:= I1, % if the first oval to be replaced is found
    !,
      (NB = oval(I,X,Y,CN),replaceTemp(Bs,I2,C,CN,NBs)) % look for the second one
    ;
     (   I =:= I2, % if the second oval was found
             !,
               (NB = oval(I,X,Y,CN),replaceTemp(Bs,I1,C,CN,NBs)) % look for the first one
              ;
               (  NB = B, replace(Bs,I1,I2,NBs))
     )   ) .

% Look for the second relavent oval
replaceTemp([],_,_,_,[]):-!.

replaceTemp([B|Bs],I1,CO,CN,[NB|NBs]):-
    B = oval(I,X,Y,C),
    I =:= I1,
    !,
       (NB = oval(I,X,Y,CO),CN = C,replaceTemp(Bs,0,_,_,NBs))
     ;
       (  NB = B, replaceTemp(Bs,I1,CO,CN,NBs)).

% Get the indexs of oval of a specific color
getI([],_,_,_):- fail,!.
getI([X|Xs],I1,I2,C):-
   X = oval(I,_,_,C), (var(I1),I1 = I,getI(Xs,I1,I2,C) ; I2 = I),!.
getI([_|Xs],I1,I2,C):- getI(Xs,I1,I2,C).
