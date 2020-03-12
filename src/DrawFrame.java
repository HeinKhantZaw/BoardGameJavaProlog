import java.awt.*;
import java.awt.event.*;
import javax.swing.*;

public class DrawFrame extends JFrame {
	
	private final JButton newGameButton; // 'undo' button	
	//private final JCheckBox fillButton; // check for filled shape 
	private final JComboBox opponentCB,diffCB,firstCB; // choose the shape
        private final JLabel playerLBL,emptyLBL,diffLBL,opponenetLBL,beginLBL;
	private final BorderLayout borderLayout;
	private String shapes[] = {"Line","Oval","Rectangle","ORectangle"}; // string arr with all the shapes 
        private String opponents[] = {"Player","Computer"};
        private String levels[] = {"1","2","3"};        
        private String firstP[] = {"Player","Computer"};
        private Object[] poss   = {"Player","Computer"};
        private Object[] opt = { "Start","Info","Cancel"};
        private JPanel jp; // Panel for JOptionPane
        private int input; // For JOptionPane return value                        	
        
        private DrawDesignPro drawPanel;
	private Color currColor;
	// Constructor
	public DrawFrame()
	{
		super("Drawing Frame");                              
                //Create and Declare variables
		currColor = Color.black;
		borderLayout = new BorderLayout(5,5);
		setLayout(borderLayout);		                				
                playerLBL = new JLabel("Player 1     |      ");
                opponenetLBL  = new JLabel("Choose your opponent :  ");
                emptyLBL = new JLabel("  Turn :   ");
                diffLBL = new JLabel("     |     Difficulty level :   ");
                beginLBL = new JLabel("    |     First Player  :    ");                          
		newGameButton = new JButton("New Game");	
		opponentCB = new JComboBox(opponents);
                diffCB = new JComboBox(levels);                
                firstCB = new JComboBox(firstP);		
		newGameButton.addActionListener(new Handler());		
		opponentCB.addActionListener(new Handler());
                diffCB.addActionListener(new Handler());                
                
		// upper panel which will contain the buttons                
		JPanel buttons = new JPanel();
               
                buttons.add(newGameButton);                
		buttons.add(opponentCB);             
		add(buttons,BorderLayout.NORTH);
                drawPanel = new DrawDesignPro(this);
		add(drawPanel,BorderLayout.CENTER);
		getContentPane().setBackground(Color.white); // set background
		
                diffCB.setEnabled(false);                
                firstCB.setEnabled(false);
               
                // Panel for JOptionPane
                jp = new JPanel();               
                jp.add(opponenetLBL);
                jp.add(opponentCB);
                jp.add(diffLBL);
                jp.add(diffCB);
                jp.add(beginLBL);
                jp.add(firstCB);
                
                createDialog();                             
	}
        // Get the first player to start playing
        public String getFirstPlayer(){return (String)firstCB.getSelectedItem(); }
        // Get difficulty level
        public String getDifficultyLVL(){return (String)diffCB.getSelectedItem();}
        // Get opponent
        public String getOpponent(){return (String)opponentCB.getSelectedItem(); }
        // Create dialog which will ask the user to select game parameters
        public void createDialog()
        {   
            opponentCB.setSelectedIndex(1);            
            diffCB.setSelectedIndex(1);
            diffCB.setEnabled(true);
            firstCB.setSelectedIndex(0);
            firstCB.setEnabled(true);
            // Show Dialog
            input = JOptionPane.showOptionDialog(null,jp,"Choose your game mode!",JOptionPane.DEFAULT_OPTION,JOptionPane.QUESTION_MESSAGE,null,opt,"Start");
            if (input == JOptionPane.OK_OPTION) // If the user selected ok button
            {
                
                drawPanel.setOpponent((String)opponentCB.getSelectedItem());
            } // if the user selected cancel button
            else if( input == JOptionPane.CANCEL_OPTION)
            {
                System.exit(0);
            }
            else // selected info button
            {
                String infoMessage = "Welcome to the game! \nRules : \nThe purpose of the game is to arrange ovals of the same color in a row, \n"
                        + "while the middle oval must be part of the row. \n"
                        + "First player - plays with the red oval. \nSecond player : plays with the blue oval. \n"
                        + "Phase 1 : \nEach player got 3 oval of his color outside the board. \n"
                        + "In his turn, he has to choose a black oval from the board and click there, \nin order to place there one of his ovals. \n"
                        + "First phase continues while there are still ovals outside the board. \n"
                        + "Phase 2 : \n"
                        + "Each player in his turn, has to chooses one of his ovals, by clicking it,\n(the chosen oval will change his color to pink) \n"
                        + "and then make an accepted move. \n"
                        + "Accepted move : Each oval can be moved -only- to one of his black neighbors. \n"
                        + "In order to cancel the selection of the oval, clicked again on the pink oval.\n" 
                        +"Enjoy !"
                        ;
                JOptionPane.showMessageDialog(null, infoMessage, "information", JOptionPane.INFORMATION_MESSAGE);
                //Return to the dialog again
                createDialog();
            }
        }
	// handle the action of the buttons
	private class Handler implements ActionListener
	{
		public void actionPerformed(ActionEvent e)
		{
                        JComboBox cb;
                        // if the user change the opponent
			if(e.getSource() == opponentCB) 
                        {
                            cb = (JComboBox)e.getSource();
                            String selected = (String)cb.getSelectedItem();
                            if(selected.equals("Computer")) // The user selected to play agains computer
                            {
                                diffCB.setEnabled(true);                                
                                firstCB.setEnabled(true);                                
                            }
                            else // plays agains user
                            {
                                 diffCB.setEnabled(false);                                 
                                 firstCB.setEnabled(false);
                            }                           
                        }
                        
                        if(e.getSource() == diffCB) // change difficulty level
                        {
                            cb = (JComboBox)e.getSource();
                            String selected = (String)cb.getSelectedItem();
                            drawPanel.setLevel(selected);
                        }    
                        // The new game button was pressed
                        if(e.getSource() == newGameButton)
			{
                            opponentCB.setSelectedIndex(0);
                            //sideCB.setSelectedIndex(0);
                            drawPanel.restartScene();
                            createDialog();
                        }                       
		}				
	}
}
