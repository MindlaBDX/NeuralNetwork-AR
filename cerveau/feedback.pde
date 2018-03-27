

public class FeedbackZone extends TableScreen {
    Skatolo skatoloInside;
    public FeedbackZone(){
	super(feedbackZonePos, feedbackZoneSize.x, feedbackZoneSize.y);
	init();
    }
       ColorTracker colorTracker;
  
    public void init() {
    colorTracker = papart.initRedTracking(this, 1f);

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
	//	background(255, 180);

	// updateTouch();

        // SkatoloLink.updateTouch(touchList, skatoloInside);

   ArrayList<TrackedElement> te = colorTracker.findColor(millis());
      colorMode(RGB, 255);
      background(0);
      TouchList touchs = colorTracker.getTouchList();

      for(Touch t : touchs){
	  ellipse(t.position.x,
		  t.position.y, 10, 10); 
      }

      SkatoloLink.addMouseTo(touchList, skatoloInside, this);
      SkatoloLink.updateTouch(touchs, skatoloInside); 

      skatoloInside.draw(getGraphics());
	    //	    drawTouch();
    }

}
