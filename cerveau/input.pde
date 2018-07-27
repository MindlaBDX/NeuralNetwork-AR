import fr.inria.papart.procam.camera.TrackedView;

InputZone inputZone;

float[] inputs;
int nbInputs = 10;


// IP  - vps469444.ovh.net
//  54.37.10.254 : 6379
public class InputZone  extends TableScreen {

  int w = 150;
  int h = 220;

  TrackedView inputView;

  PVector captureSize = new PVector(50, 50);
  PVector origin = new PVector(22, 96);
  int picSize = 4; // Works better with power of 2

    public InputZone(){
	super(inputZonePos, inputZoneSize.x, inputZoneSize.y);
	init();
    }
    
    void init() {
	inputZone = this;
	// setSaveName(sketchPath() + "/input.xml");
	// useAlt(false);
	// setLoadSaveKey("i", "I");
 	
	inputView = new TrackedView(this);
	inputView.setCaptureSizeMM(captureSize);
	inputView.setImageWidthPx(picSize);
	inputView.setImageHeightPx(picSize);
	inputView.setTopLeftCorner(origin);
	inputView.init();

	inputs = new float[nbInputs];
    }

    PImage out;
    
    public void drawOnPaper() {
	
	// Objectif: lecture de X pixels,
	stroke(100);
	noFill();
	strokeWeight(2);
	rectMode(CORNER);
	line(0, 0, origin.x, origin.y);
	rect((int) origin.x - 22, (int) origin.y - 5, 
	     (int) captureSize.x + 5, (int)captureSize.y - 5);
	
	out = inputView.getViewOf(this.getCameraTracking());
	
	if (out != null) {
	    image(out, 0, 0, 50, 50);
	    read();
	}
    }
    
    void read(){
	out.loadPixels();
	colorMode(HSB, 1);

	inputs[0] = pxColor(1);
	inputs[1] = pxColor(6);
	inputs[2] = pxColor(13);
	inputs[3] = pxColor(11);
	inputs[4] = pxColor(4);
	inputs[5] = pxColor(14);
	inputs[6] = pxColor(5);
	inputs[7] = pxColor(2);
	inputs[8] = pxColor(9);
	inputs[9] = pxColor(10);
    }

    float pxColor(int p){
	int p1 = out.pixels[p]; 
	return (float) brightness(p1);
    }
}

// void sendInput(){
//     String key = "rnn:input";
//     StringBuilder value = new StringBuilder("rnn:input:");

//     for(int i = 0; i < inputs.length; i++){
// 	value.append(inputs[i]);
	
// 	// todo: update to [a,b,c] format
// 	if(i != inputs.length-1){
// 	    value.append(",");
// 	}
//     }
//     println("send input: " + value);
//     redis.set(key, value.toString());

//     waitForBackend();
// }
