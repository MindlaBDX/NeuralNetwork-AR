import fr.inria.papart.tracking.DetectedMarker;

int left = -300;

PVector modesZonePos = new PVector(-130, 140);
PVector modesZoneSize = new PVector(180, 40);


PVector inputZonePos = new PVector(left - 40, -145);
PVector inputZoneSize = new PVector(150, 220);

PVector neuronZonePos = new PVector(left + 50, -210);
PVector neuronZoneSize = new PVector(420, 320);

PVector outputZonePos = new PVector(185, -215);
PVector outputZoneSize = new PVector(100, 320);

PVector feedbackZonePos = new PVector(150, 150);
PVector feedbackZoneSize = new PVector(150, 35);

// public FeedbackZone(){
//     super(feedbackZonePos, feedbackZoneSize.x, feedbackZoneSize.y);
//     init();
// }


public class ModesZone  extends TableScreen {
  int w = 180;
  int h = 40;

  ColorTracker colorTracker;
    Skatolo skatoloInside;

    
    public ModesZone(){
	super(modesZonePos, modesZoneSize.x, modesZoneSize.y);
	init();
    }

    public void init() {
	setSaveName(sketchPath() + "/modes.xml");
    useAlt(false);
    setLoadSaveKey("m", "M");

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
      //      setLocation(0, drawingSize.y, 0);

      ArrayList<TrackedElement> te = colorTracker.findColor(millis());
      TouchList touchs = colorTracker.getTouchList();

      SkatoloLink.updateTouch(touchs, skatoloInside); 

      if(debug){
	  background(100);
	  
	  // Draw the pointers. (debug)
	  for (tech.lity.rea.skatolo.gui.Pointer p : skatoloInside.getPointerList()) {
	      fill(0, 200, 0);
	      rect(p.getX(), p.getY(), 3, 3);
	  }
	  skatoloInside.draw(getGraphics());
      }

      skatoloInside.draw(getGraphics());
      
      // Main marker, with id 800 - 1000
    // int id = getMainMarker(MARKER_WIDTH);
    // if (id != -1) {
    //   colorMode(HSB, 10, 100, 100); // change hue
    //   background(id - 800, 100, 100);
    // } else {
    //   colorMode(RGB, 255); // default
    //   background(id - 800, 240, 240);
    // }
  }
}
