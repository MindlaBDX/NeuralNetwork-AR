import fr.inria.papart.tracking.DetectedMarker;

int left = -300;

//PVector modesZonePos = new PVector(-130, 140);
//PVector modesZoneSize = new PVector(180, 40);

PVector modesZonePos = new PVector(-130, 0);
PVector modesZoneSize = new PVector(180, 180);

PVector inputZonePos = new PVector(left - 40, -145);
PVector inputZoneSize = new PVector(150, 220);

PVector neuronZonePos = new PVector(left + 50, -210);
PVector neuronZoneSize = new PVector(420, 320);

PVector outputZonePos = new PVector(185, -215);
PVector outputZoneSize = new PVector(100, 320);

PVector feedbackZonePos = new PVector(170, 160);
PVector feedbackZoneSize = new PVector(150, 35);

// public FeedbackZone(){
//     super(feedbackZonePos, feedbackZoneSize.x, feedbackZoneSize.y);
//     init();
// }


public class ModesZone  extends TableScreen {

    ColorTracker colorTracker;
    // CalibratedColorTracker colorTracker;
    Skatolo skatoloInside;

    
    public ModesZone(){
	super(modesZonePos, modesZoneSize.x, modesZoneSize.y);
	init();
    }

    public void init() {
	//    colorTracker = papart.initAllTracking(this, 1.0f);
    
    //    colorTracker = new CalibratedColorTracker(this, 1.5f);
     colorTracker = papart.initRedTracking(this, 1f);

    skatoloInside = new Skatolo(parent, this);
    skatoloInside.setAutoDraw(false);
    skatoloInside.getMousePointer().disable();

    int initP = 10;
    int gap = 70;
    skatoloInside.addHoverButton("create")
	.setPosition(initP, 10)
	.setSize(20, 20)
	.setLabelVisible(false);
    
    skatoloInside.addHoverButton("learn")
	.setPosition(initP + gap, 10)
	.setSize(20, 20)
	.setLabelVisible(false);

    skatoloInside.addHoverButton("test")
	.setPosition(initP + gap * 2, 10)
	.setSize(20, 20)
		.setLabelVisible(false);
  }

    void create(){
	// println("Create pressed");
	modeChange("init");
    }
    void learn(){
	//	println("learn pressed");
	modeChange("learn");
    }
    void test(){
	// println("test pressed");
	modeChange("predict");
    }
    
    boolean debug = false;
    
    
  public void drawOnPaper() {
      background(20);

      ArrayList<TrackedElement> te = colorTracker.findColor(millis());
      colorMode(RGB, 255);
      TouchList touchs = colorTracker.getTouchList();

      // for(Touch t : touchs){
      // 	  ellipse(t.position.x,
      // 		  t.position.y, 10, 10); 
      // }

      SkatoloLink.updateTouch(touchs, skatoloInside); 

      if(debug){
	  // Draw the pointers. (debug)
	  for (tech.lity.rea.skatolo.gui.Pointer p : skatoloInside.getPointerList()) {
	      fill(0, 200, 0);
	      rect(p.getX(), p.getY(), 3, 3);
	  }
      }

      skatoloInside.draw(getGraphics());
  }
}
