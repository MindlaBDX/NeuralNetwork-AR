

public class FeedbackZone  extends PaperTouchScreen {

    int w = 100;
    int h =35;
    Skatolo skatoloInside;

    
    public void settings() {
	setDrawingSize(w, h);
	loadMarkerBoard(Papart.markerFolder + "A4-default.svg", w, h);
    setDrawOnPaper();
    }
    
    public void setup() {

    setSaveName(sketchPath() + "/feedback.xml");
    useAlt(false);
    setLoadSaveKey("f", "F");
    setDrawingFilter(0);

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
    }
       

    // TODO: buttons here for Touch !
    
    public void drawOnPaper() {
	background(255, 60);
	setLocation(0, 220, 0);

	SkatoloLink.addMouseTo(touchList, skatoloInside, this);
        SkatoloLink.updateTouch(touchList, skatoloInside);

        drawTouch();
	skatoloInside.draw(getGraphics());

	
    }

}
