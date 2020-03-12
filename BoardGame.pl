%:-use_module(minMax).
:-use_module(alphaBeta).

:- dynamic oval/4.
:- dynamic blueOval/3.
:- dynamic redOval/3.
:- dynamic comTurn/1.

%Programmer : Anton Rubenchik
%File Name : BoardGame.pl
%Description : It is board game for two players. The purpose of the
% game is to create a row of 3 oval of the same color(The central oval
% must be included). The rules are explained in the Info menu of the
% game.
%Input : No
%Output : No

% Set rules for drawing the board
oval(0,500,350,black).
oval(1,500,100,black).
oval(2,750,180,black).
oval(3,900,350,black).
oval(4,750,530,black).
oval(5,500,600,black).
oval(6,250,530,black).
oval(7,100,350,black).
oval(8,250,180,black).

redOval(0,630,750).
redOval(1,700,750).
redOval(2,770,750).

blueOval(0,230,750).
blueOval(1,300,750).
blueOval(2,370,750).

line(525,180,525,320).
line(525,430,525,570).
line(200,375,450,375).
line(600,375,850,375).

line(330,243,455,325).
line(575,420,725,525).
line(575,325,725,243).
line(330,525,455,420).

line(330,190,465,140).
line(580,140,725,190).
line(820,243,890,320).
line(890,425,820,520).
line(725,575,580,625).
line(465,625,330,575).
line(230,520,150,425).
line(150,320,230,243).
% Size of each oval
length(50).
% Computer's color - will be modified again after selection
comTurn(red).
% Restorirng the rules to the beginning
restartScene:-
	retract(oval(I,X,Y,red)), assert(oval(I,X,Y,black)),fail.
restartScene:-
	retract(oval(I,X,Y,blue)),assert(oval(I,X,Y,black)),fail.
restartScene:-
	retract(oval(I,X,Y,pink)),assert(oval(I,X,Y,black)),fail.
restartScene.
% Choose random item from list
choose([],[]).
choose(List,E):-
	length(List,Length),
	random(0,Length,Index),
	nth0(Index,List,E).
%Count how many ovals left outside the board
step(S):-
	((redOval(_,_,_),bagof(redOval(X,Y,C) , redOval(X,Y,C) ,SR),length(SR,LR));(LR = 0)),
	((blueOval(_,_,_),bagof(blueOval(X,Y,C) , blueOval(X,Y,C) ,SB),length(SB,LB));(LB = 0)),
	  S is LR + LB.
setDepth(D):- retract(setN(_)),assert(setN(D)).
% Calculate computer's next move
% Stage: 0 - While there are still ovals outside of the board
% Game Level: 1
computerMove(Turn,LVL,Stage):-(LVL =:= 1),Stage =:= 0, addColorOval(Turn),!.
% Game Level: 2
computerMove(Turn,LVL,Stage):- (LVL =:= 2;LVL =:= 3),Stage =:= 0,step(S),
	(
	 ( S >= 4, addColorOval(Turn))
	;
	 (S =:= 3 ,addS3(Turn))
        ;
	 (S =< 2 ,addS12(Turn) )).
% Stage: 1 - All the ovals are on the board
% Game Level:  1
computerMove(Turn,LVL,Stage):- LVL =:= 1,Stage =:= 1,
((Turn =:= 0 , C = red) ; (Turn =:= 1 , C = blue)),
oval(I1,X1,Y1,C),
oval(I2,X2,Y2,black),
checkMove(I1,I2),
retract(oval(I1,X1,Y1,C)),
assert(oval(I1,X1,Y1,black)),
retract(oval(I2,X2,Y2,black)),
assert(oval(I2,X2,Y2,C)).

% Game Level - 2
computerMove(Turn,LVL,Stage):- (LVL =:= 2;LVL =:= 3),Stage =:= 1,
((Turn =:= 0 , C = red) ; (Turn =:= 1 , C = blue)),
 board(BTemp), % Transfer rules about ovals to a list - BTemp
 sortB(BTemp,BSorted), % Sort the list
   alphabeta(C,BSorted,(-1000),1000,BestNextPos,_,0) % Calculate next move
  ,reDrawBoard(BestNextPos). % ReDraw the board

% Calculate the distance between two ovals - exluding the central
calcDiff(C,S):- oval(I1,_,_,C),oval(I2,_,_,C), I1 \= I2,I1 \= 0, I2 \= 0,
		((I2 > I1,S is I2 - I1);(I2 < I1,S is I1 - I2)),!.
% Calculate the best spot for inserting the next oval - Computer's
% move stage 0.
addS12(Turn) :- % Where left less than 3 ovals outside the board
         getCol(Turn,C),changeCol(C,CT),(
	% Check if computer Or player can win by replacing the middle oval
	(((calcDiff(C,S),S =:= 4);(calcDiff(CT,ST),ST =:= 4)),oval(0,_,_,black),replaceOval(Turn,0))
	;
	(oval(0,_,_,C),oval(I,_,_,C),I \= 0,((I >= 5,IN is I - 4);(I < 5, IN is I + 4)),oval(IN,_,_,black),replaceOval(Turn,IN))
	; % Check if player can win, if he does, block him
	(oval(0,_,_,CT),oval(IT,_,_,CT),IT \= 0,((IT >= 5,ITN is IT - 4);(IT < 5, ITN is IT + 4)),oval(ITN,_,_,black),replaceOval(Turn,ITN))
	;
	addColorOval(Turn)).
addS3(Turn):- % Where left 3 ovals outside the board
        getCol(Turn,CT),changeCol(CT,C),
        % check if the opponent can win on the next step.
	% only the middle is missing for a strike
	((calcDiff(C,S),S =:= 4,replaceOval(Turn,0),!)
	;   % if the zero oval is in opponent's color
        (oval(0,_,_,C),oval(I3,_,_,C),I3 \= 0,((I3 >= 5,IN is I3 - 4);(I3 < 5, IN is I3 + 4)),replaceOval(Turn,IN),!)
        ;
	 addColorOval(Turn)).
% Return the color which related to the Turn
getCol(Turn,C):- Turn == 0, C = red.
getCol(Turn,C):- Turn == 1, C = blue.

%Add oval to a random place on the board
addColorOval(Turn):-
findall(N,oval(N,_,_,black),L),choose(L,I),replaceOval(Turn,I). %From all the black oval on the board,choose one and replace it with color oval.
%Replace a black oval number I -  with a color one,
replaceOval(Turn,I):-
retract(oval(I,X,Y,black)),
((Turn =:=0,setComTurn(red),
assert(oval(I,X,Y,red)),retract(redOval(_,_,_)))
;
(Turn =:= 1,setComTurn(blue),
assert(oval(I,X,Y,blue)),retract(blueOval(_,_,_)))).

% Sort list
sortB(List,Sorted):- q_sort(List,[],Sorted).
q_sort([],Acc,Acc).
q_sort([H|T],Acc,Sorted):-
	pivoting(H,T,L1,L2),q_sort(L1,Acc,Sorted1),q_sort(L2,[H|Sorted1],Sorted).
pivoting(_,[],[],[]).
pivoting(H,[X|T],[X|L],G):- X = oval(IX,_,_,_),H = oval(IH,_,_,_), IX >= IH  , pivoting(H,T,L,G). %   X =< H, pivoting(H,T,L,G).
pivoting(H,[X|T],L,[X|G]):- X = oval(IX,_,_,_),H = oval(IH,_,_,_), IX < IH  , pivoting(H,T,L,G).            %X > H, pivoting(H,T,L,G).

% Transfer rules from list to dynamic memory
reDrawBoard(NewBoard):- retractall(oval(_,_,_,_)),addOvals(NewBoard).
addOvals([]).
addOvals([Oval|Res]):- assert(Oval),addOvals(Res).
% Return list of the oval rules
board(B):-
    bagof(oval(I,X,Y,C) , oval(I,X,Y,C) ,B).
%Check if the X & Y are part of an oval
checkClick(I,X,Y,C):-
	oval(I,XO,YO,C) ,length(L), X >= XO, Y >= YO ,XN is XO + L, YN is YO + L, X =< XN, Y =< YN,!.
%Check if oval can be moved from 'From' to 'To'
checkMove(From,To):- oval(To,_,_,C),C == black,
	 (From =:= To + 1 ; From =:= To - 1 ; From =:= 0 ; To =:= 0 ; (From =:= 8 , To =:= 1) ; (From =:= 1 , To =:= 8) ).
%Set computer move
setComTurn(C):- retract(comTurn(_)),assert(comTurn(C)).
%Change the color of an oval number I to the color C
setColor(I,C):-
	retract(oval(I,X,Y,_)),assert(oval(I,X,Y,C)).
%Check if the board contains winning position
checkWin:- oval(0,_,_,red),oval(A,_,_,red),oval(B,_,_,red),A \= 0, B \= 0,A \= B,D is B - 4, A == D,!.
checkWin:- oval(0,_,_,blue),oval(A,_,_,blue),oval(B,_,_,blue),A \= 0, B \= 0,A \= B,D is B - 4, A == D,!.


