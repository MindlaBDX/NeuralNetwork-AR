

public class FeedbackZone extends TableScreen {
    Skatolo skatoloInside;
    public FeedbackZone(){
	super(feedbackZonePos, feedbackZoneSize.x, feedbackZoneSize.y);
	init();
    }

    CalibratedStickerTracker stickerTracker;
    
    public void init() {

	// Sticker tracker 
	stickerTracker = new CalibratedStickerTracker(this, 15);

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
      colorMode(RGB, 255);
      background(0);


      stickerTracker.findColor(millis());
      TouchList touchs = getTouchListFrom(stickerTracker);

      for(Touch t : touchs){
	  t.id = 3;
	  // ellipse(t.position.x,
	  // 	  t.position.y,
	  // 	  3, 3);
	  
      }
      
      SkatoloLink.addMouseTo(touchs, skatoloInside, this);
      SkatoloLink.updateTouch(touchs, skatoloInside); 
      skatoloInside.draw(getGraphics());
    }

}
