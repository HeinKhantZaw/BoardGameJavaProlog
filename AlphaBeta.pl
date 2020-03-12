:- module(alphaBeta,[alphabeta/7,getI/4,changeCol/2]).

% The Depth of the searching tree
setN(3).
%Declar max and min values for hueristic function
maxV(7).
minV(-7).
%AlphaBeta Algorithm taken from the book
alphabeta(C,Pos,_,_,_,Val1,N) :- % Check if we found winning position
    changeCol(C,CN),
    maxV(MA),minV(MI), %get Min and Max values
    setN(D),N1 is D - N, % Calculate at which depth we stopped
    util(CN,Pos,Val),((Val =:= MI, Val1 is Val - N1) ; (Val =:= MA,Val1 is Val + N1)),!.
alphabeta(C,Pos,Alpha,Beta,GoodPos,Val,N):-
      setN(L),N < L ,
      (moveN(C,Pos,Poslist), Poslist \= []),
    !,
      bound(C,Poslist,Alpha,Beta,GoodPos,Val,N)
    ;
      (changeCol(C,CN),util(CN,Pos,Val)).

bound(C,[Pos|Poslist],Alpha,Beta,GoodPos,GoodVal,N):-
    N1 is N + 1, changeCol(C,CN),
    alphabeta(CN,Pos,Alpha,Beta,_,Val,N1),
    goodenough(C,Poslist,Alpha,Beta,Pos,Val,GoodPos,GoodVal,N).

goodenough(_,[],_,_,Pos,Val,Pos,Val,_):-!.

goodenough(C,_,Alpha,Beta,Pos,Val,Pos,Val,_):-
    min_to_move(C),Val > Beta,!;
    max_to_move(C),Val < Alpha,!.

goodenough(C,Poslist,Alpha,Beta,Pos,Val,GoodPos,GoodVal,N):-
    newbounds(C,Alpha,Beta,Pos,Val,NewAlpha,NewBeta),
    bound(C,Poslist,NewAlpha,NewBeta,Pos1,Val1,N),
    changeCol(C,CN),
    betterof(CN,Pos,Val,Pos1,Val1,GoodPos,GoodVal).

newbounds(C,Alpha,Beta,_,Val,Val,Beta):-
    min_to_move(C),Val > Alpha,!.
newbounds(C,Alpha,Beta,_,Val,Alpha,Beta):-
    max_to_move(C),Val < Beta,!.

newbounds(_,Alpha,Beta,_,_,Alpha,Beta).

betterof(C,Pos,Val,_,Val1,Pos,Val):-
     min_to_move(C),Val > Val1,!;
     max_to_move(C),Val < Val1,!.

betterof(_,_,_,Pos1,Val1,Pos1,Val1).

comTurn(C):- C = blue.

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
    getI(Res,I1,I2,C), S is I2 - I1,
    calcValD(C,Pos,S,Val).


%When the centeral oval is in the color of the current turn
calcValZ(C,_,4,Val):- comTurn(CT),minV(Mi),maxV(Ma),((C == CT, Val = Ma,!);(Val = (Mi),!)). % 7 - computer wins, 1 - player wins
calcValZ(C,_,_,Val):- comTurn(CT),(C == CT, Val = 5,!);(Val = (-5)).
%When the centeral oval is black
calcValB(C,_,4,Val):- comTurn(CT),(C == CT, Val = 6,!);(Val = (-6),!).
calcValB(C,_,_,Val):- comTurn(CT),(C == CT, Val = 4,!);(Val = (-4),!).
%When the centeral oval is in the opposit color of the current turn
calcValD(C,_,4,Val):- comTurn(CT),(C == CT, Val = 5,!);(Val = (-5),!).
calcValD(C,_,_,Val):- comTurn(CT),(C == CT, Val = 4,!);(Val = (-4),!).

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
         (comColor2(C,CP,CZ),% Check possible move to the middle
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

    replace([B|Bs],I1,I2,[NB|NBs]):-
    B = oval(I,X,Y,C),(I =:= I1,
    !,
      (NB = oval(I,X,Y,CN),replaceTemp(Bs,I2,C,CN,NBs))
    ;
     (   I =:= I2,
             !,
               (NB = oval(I,X,Y,CN),replaceTemp(Bs,I1,C,CN,NBs))
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
