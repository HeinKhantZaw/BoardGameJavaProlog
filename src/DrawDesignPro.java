import java.awt.Color;
import java.awt.Graphics;
import java.util.ArrayList;
import java.awt.*;
import java.awt.event.*;
import java.awt.geom.Line2D;
import javax.swing.*;
import java.util.*;
import org.jpl7.Query;
import org.jpl7.*;
import org.jpl7.fli.*;
import java.awt.geom.*;

public class DrawDesignPro  extends JPanel{
    	
        private DrawFrame drawFrame;
        private int turn , chosenOval,computerTurn;
        private String status,gameLVL,opponent;	
	
	//private MyShape currShape; // current shape which is drawn
	private Color currColor; // color of the current shape
	
        private JLabel playerLBL,turnLBL,statusLBL;
        private boolean chosen;
	// Constructor
	public DrawDesignPro(DrawFrame drawF)
	{                   
                // Consult the prolog files
                drawFrame = drawF;
                System.out.print("Consult");
                String t0 = "consult('BoardGame.pl')";
                Query q0 = new Query(t0);
                System.out.println(t0 + " " + (q0.hasSolution() ? "succeded" : "failed" ));	
                                                
                // Declare variables
                status = "Player";        
                computerTurn = -1;                
                turnLBL = new JLabel("Turn :   ");
                playerLBL = new JLabel("Player 1");                
                statusLBL = new JLabel("    |    Mode : Vs Player");
                
                setLayout(new FlowLayout());
               
                add(turnLBL);
                add(playerLBL);
                add(statusLBL);				
		currColor = Color.BLACK;	// default color is black					
                turn = 0;
                chosen = false;
                // Draw the scene
                createScene();
		// add mouse handeling
		this.addMouseMotionListener(new Listener());
		this.addMouseListener(new Listener());               
	}        
        // Set inside title for the game
        public void setStatus(String newStatus)
        {
            status = newStatus;
            statusLBL.setText("    |    Mode : Vs " + status);
        }
        // set the game level
        public void setLevel(String newLevel){gameLVL = newLevel;}  
        // Set opponent and handle situation if computer begins
        public void setOpponent(String newOpponent)
        {          
            opponent = newOpponent;
            setStatus(opponent);
            // handle situation when computer begins
            if(opponent.equals("Computer"))
                {                      
                    // set the depth level for alpha beta pruning
                    gameLVL = drawFrame.getDifficultyLVL();
                     if(gameLVL.equals("1") || gameLVL.equals("2"))
                          Query.hasSolution("setDepth(" + 1 + ")");
                     else
                         Query.hasSolution("setDepth(" + 4 + ")");
                     // check if computer begins and calculate his first move
                      if( drawFrame.getFirstPlayer().equals("Computer"))  
                      {
                         computerTurn = 0;                         
                         Query.hasSolution("computerMove(0," + gameLVL + ",0)");
                         turn = 1;
                      }
                      else
                      {                        
                         computerTurn = 1;
                      }
                }
            else
                computerTurn = -1;          
            
            repaint();           
        } 
        // set current color
        public void setColor(Color color){this.currColor = color; } // color is immutable
	// Draw outside ovals
	public void createTempOvals()
        {            
            Query.hasSolution("retractall(redOval(_,_,_))");
            Query.hasSolution("retractall(blueOval(_,_,_))");
            Query.hasSolution("assert(redOval(0,630,750))");
            Query.hasSolution("assert(redOval(1,700,750))");
            Query.hasSolution("assert(redOval(2,770,750))");
            Query.hasSolution("assert(blueOval(0,230,750))");
            Query.hasSolution("assert(blueOval(1,300,750))");
            Query.hasSolution("assert(blueOval(2,370,750))");                                                                             
        }
        // redraw the scene
        public void restartScene()
        {          
          createTempOvals();
          Query.hasSolution("restartScene");          
          turn = 0;
          playerLBL.setText("Player 1");
          statusLBL.setText("    |    Mode : Vs Player");
          repaint();
        }
        // Draw the scene for the game
	public void createScene()
        {
            // draw outside ovals
            createTempOvals();
            Query.hasSolution("restartScene");
            Variable Y = new Variable("Y");
            Variable X = new Variable("X"); 
            Variable Z = new Variable("Z");
            Variable N = new Variable("N");  
             //  DRAW BLACK CIRCLES            
            Query q2 = new Query("oval",new Term[]{N,X,Y,Z});            
            //  DRAW LINES
            Variable Y1 = new Variable("Y1");
            Variable X1 = new Variable("X1");  
            Query q3 = new Query("line",new Term[]{X,Y,X1,Y1});           
                      
        }        	
	// update the color of a specific oval
        public void updateColor(int i)
        {
                                if(turn == 0)
                                {                                                                                                       
                                        Query.hasSolution("setColor(" + i + ",red)");
                                }
                                else 
                                {                                                                                                          
                                        Query.hasSolution("setColor(" + i + ",blue)");
                                }
                                repaint();
        }
        // check if a currect move was made
        public boolean checkMove(int from,int to)
        {           
                String q = "checkMove(" + from  + "," + to  + ")";              
                
                if(Query.hasSolution(q))
                {
                    return true;
                }
                else
                {
                    return false;
                }
        }
        // check if computer won
        public boolean checkComputerWin()
        {
            if(Query.hasSolution("checkWin"))            
                                  {      
                                      repaint();
                                      JOptionPane.showMessageDialog(null, "Computer Won!"," Congradulations!",JOptionPane.INFORMATION_MESSAGE);
                                      restartScene();
                                      drawFrame.createDialog();
                                      return true;
                                  }
            else
                return false;
        }
        // check if the player won
        public boolean checkWin()
        {                         
              if(Query.hasSolution("checkWin"))            
                                  {  
                                      repaint();
                                      JOptionPane.showMessageDialog(null, "You Won!"," Congradulations!",JOptionPane.INFORMATION_MESSAGE);
                                      restartScene();                                      
                                      drawFrame.createDialog();
                                      return true;
                                  }
              else
                  return false;
        }
        // Draw the board
	public void paintComponent(Graphics g)
	{                    
		super.paintComponent(g);		                                    
                int length,X,Y,X2,Y2;    
                String C;
                String t = "length(L)";
                length = Query.oneSolution(t).get("L").intValue();	                                        
                // draw blue oval
                Query q = new Query("blueOval(I,X,Y)");                                     
                while (q.hasMoreSolutions())
                {
                    Map<String, Term> s = q.nextSolution();                                                    
                    X = s.get("X").intValue();
                    Y = s.get("Y").intValue();                                                    
                    g.setColor(Color.blue);
                    g.fillOval(X,Y,length,length);
                }            
                // draw red ovals
                q = new Query("redOval(I,X,Y)");                                     
                while (q.hasMoreSolutions())
                {
                    Map<String, Term> s = q.nextSolution();                                                    
                    X = s.get("X").intValue();
                    Y = s.get("Y").intValue();                                                    
                    g.setColor(Color.red);
                    g.fillOval(X,Y,length,length);
                }       
                // draw ovals
                q = new Query("oval(I,X,Y,C)");                                     
                while (q.hasMoreSolutions())
                {
                    Map<String, Term> s = q.nextSolution();                                                    
                    X = s.get("X").intValue();
                    Y = s.get("Y").intValue(); 
                    C = s.get("C").name();
                    if(C.equals("black"))
                        g.setColor(Color.black);
                    else if(C.equals("red"))
                              g.setColor(Color.red);
                          else if(C.equals("blue"))
                              g.setColor(Color.blue);
                              else
                                g.setColor(Color.pink);
                    g.fillOval(X,Y,length,length);
                }
                // draw lines
                Query q2 = new Query("line(X,Y,X2,Y2)");                                     
                while (q2.hasMoreSolutions())
                {
                    Map<String, Term> s2 = q2.nextSolution();                                                    
                    X = s2.get("X").intValue();
                    Y = s2.get("Y").intValue(); 
                    X2 = s2.get("X2").intValue();
                    Y2 = s2.get("Y2").intValue();  
                    g.setColor(Color.black);
                    g.drawLine(X, Y ,X2, Y2);
                    Graphics2D g2 = (Graphics2D) g;
                    g2.setStroke(new BasicStroke(4));
                    g2.draw(new Line2D.Float(X, Y ,X2, Y2));
                    g.setColor(Color.red);                    
                }                                 			
		
				
	}
        // Handle interaction with the user during the game
	private class Listener extends MouseAdapter implements MouseMotionListener
    {        
        public void mousePressed(MouseEvent e)
        {      
                int X,Y;
                //  check if oval was clicked 
                Variable C = new Variable("C");
                Variable I = new Variable("I");                                                                   
                String t4 = "checkClick(I," + e.getX()  + "," + e.getY()  + ",C)";                
                
                if(Query.hasSolution(t4)){                
                    int i = Query.oneSolution(t4).get("I").intValue();                    
                     String currColor = Query.oneSolution("oval(" + i + "," + "_"  + "," + "_"  + ",C)").get("C").name();                    
                    // -------------------------      Stage 0 -------------------------------------
                    if(Query.hasSolution("blueOval(I,X,Y)") || Query.hasSolution("redOval(I,X,Y)")) {                                          
                        if( currColor.equals("black") ) {// if a black oval was clicked                                                                    
                            if(turn == 0){                                                                                                                                                                                                                                         
                                   Query.hasSolution("setColor(" + i + ",red)");
                                                                                                                   
                                    Query.hasSolution("retract(redOval(I,X,Y))");
                                    checkWin();
                                    if(computerTurn == 1) {    
                                        
                                        boolean check = Query.hasSolution("computerMove(1," + gameLVL + ",0)");  
                                        
                                        checkComputerWin();//--------------------------------------------------------------------------
                                    }                                        
                                    else // happens when two players play the game
                                    {
                                        turn = 1;
                                        playerLBL.setText("Player 2");
                                    }
                            }
                            else{  // Turn == 1                                                                                                                                                                    
                                     Query.hasSolution("setColor(" + i + ",blue)");
                                        
                                     Query.hasSolution("retract(blueOval(I,X,Y))");
                                     checkWin();
                                     if(computerTurn == 0) {                                     
                                        if(Query.hasSolution("blueOval(I,X,Y)") || Query.hasSolution("redOval(I,X,Y)")){ // if one temp oval is left                                        
                                                  Query.hasSolution("computerMove(0," + gameLVL + ",0)"); 
                                                  checkComputerWin();
                                         }
                                        else{ // no more temp ovals left                                        
                                                  Query.hasSolution("computerMove(0," + gameLVL + ",1)"); 
                                                  checkComputerWin();
                                        }
                                     }
                                     else{ // happens when two players play the game                                     
                                          turn = 0; 
                                          playerLBL.setText("Player 1");
                                     }
                            }                          
                        }
                    }
                    // -------------------------      Stage 1      -------------------------------------
                    else{ // No more outside ovals - Stage == 1                    
                        if( chosen == true){                        
                            if(chosenOval == i){ // chose the same same oval again                            
                                updateColor(i);                               
                                chosen = false;
                            }
                            else{ // chosenOval != i                            
                                if(checkMove(chosenOval,i)){ // move from chosenOval to i                                          
                                  chosen = false;
                                  Query.hasSolution("setColor(" + chosenOval + ",black)");     
                                  repaint();      
             
                                  updateColor(i);      
                                  if(checkWin())
                                      return;                                  
                                  if(turn == 0){                                                             
                                         if(computerTurn == 1) {                                                 
                                            Query.hasSolution("computerMove(1," + gameLVL + ",1)");                                             
                                        Variable Y3 = new Variable("Y3");
                                        Variable X3 = new Variable("X3"); 
                                        Variable Z3 = new Variable("Z3");
                                        Variable N3 = new Variable("N3");  
                                         //  DRAW BLACK CIRCLES            
                                        Query q6 = new Query("oval",new Term[]{N3,X3,Y3,Z3});
                                        /*System.out.println("check          each solution of oval(N33,X33,Y33,Z3)");
                                            while (q6.hasMoreSolutions()){                                            
                                                    Map<String, Term> s6 = q6.nextSolution();                                               
                                            }  */        
                                            repaint();
                                
                                            checkComputerWin();
                                         }
                                         else{                                         
                                              turn = 1; 
                                              playerLBL.setText("Player 2");
                                         }                                           
                                  }
                                  else{                                  
                                      if(computerTurn == 0)     {                                      
                                            Query.hasSolution("computerMove(0," + gameLVL + ",1)"); 
                                            checkComputerWin();
                                      }
                                      else{                                         
                                              turn = 0; 
                                              playerLBL.setText("Player 1");
                                         }                                      
                                  }                                         
                                }
                            }
                            
                        }
                        else{ // chosen == false                                                                               
                            if( (turn == 0 && currColor.equals("red")) || (turn == 1 && currColor.equals("blue"))){                                   
                                chosenOval = i;
                                //ovalList.get(i).setColor(Color.pink);  
                                Query.hasSolution("setColor(" + i + ",pink)");
                                chosen = true;
                            }
                        }
                    }                                                                                                                                         
                    repaint();
                }                                                                               
        }                            
        
    }
}


