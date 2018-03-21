

public class FeedbackZone extends TableScreen {
    Skatolo skatoloInside;
    public FeedbackZone(){
	super(feedbackZonePos, feedbackZoneSize.x, feedbackZoneSize.y);
	init();
    }
    
    public void init() {

    skatoloInside = new Skatolo(parent, this);
    skatoloInside.setAutoDraw(false);
    skatoloInside.getMousePointer().disable();

    int initP = 22;
    int gap = 51;
    skatoloInside.addHoverButton("happy")
	.setPosition(initP, 10)
	.setSize(20, 20)
	.setLabelVisible(false);
    
    skatoloInside.addHoverButton("sad")
	.setPosition(initP + gap, 10)
	.setSize(20, 20)

	.setLabelVisible(false);
    }
    
    int faceSize = 30;

    public void happy(){
	println("Sending feedback");
	sendFeebdack();
    }
    public void sad(){
	//	println("Sad pressed");
	println("size : " + drawingSize);
    }
       
    // TODO: buttons here for Touch !
    public void drawOnPaper() {
	background(255, 180);

	updateTouch();
	SkatoloLink.addMouseTo(touchList, skatoloInside, this);
        SkatoloLink.updateTouch(touchList, skatoloInside);

	try{
	    drawTouch();
	    skatoloInside.draw(getGraphics());
	}catch(Exception e){
	    e.printStackTrace();
	}
    }

}
