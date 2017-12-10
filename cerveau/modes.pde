import fr.inria.papart.tracking.DetectedMarker;

public class ModesZone  extends PaperScreen {
  int w = 180;
  int h = 40;

  ColorTracker colorTracker;
    Skatolo skatoloInside;

    
  public void settings() {
    setDrawingSize(w, h);
    loadMarkerBoard(sketchPath() + "/markers/modes.svg", w, h);
    setDrawOnPaper();
  }

  public void setup() {
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
