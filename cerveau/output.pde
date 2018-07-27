float[] feedbackValue;

int distanceSlider = 33; // mm
int sliderOffset = 6; // mm

public class OutputZone  extends TableScreen {

    int w = 100;
    int h = 320;

    CalibratedStickerTracker stickerTracker;
    
    public OutputZone(){
	super(outputZonePos, outputZoneSize.x, outputZoneSize.y);
	init();
    }

    public void init() {
	setSaveName(sketchPath() + "/output.xml");
	useAlt(false);
	setLoadSaveKey("o", "O");
	setDrawingFilter(0);
	feedbackValue = new float[MAX_NEURON_PER_LAYER];    

	stickerTracker = new CalibratedStickerTracker(this, 15);
    }
    

    public void drawOnPaper() {
	background(25);

      ArrayList<TrackedElement> te = stickerTracker.findColor(millis());
      TouchList touchs = stickerTracker.getTouchList(0); // Touchs 0 -> red

      //      println("nbTouchs: " + te.size());

      
      for(Touch t : touchs){
	  int id = findSliderID(t.position.y);
	  float v = findSliderValue(t.position.x);

	  if(id > 0 && id < MAX_NEURON_PER_LAYER){
	      feedbackValue[id] = v;
	  }
	  //	  println("Touch: "  + id + " " + v);
      }

      // debug 

      if(Mode.is("learn")){
	  int y = sliderOffset;
	  for(int i = 0; i < MAX_NEURON_PER_LAYER; i++){
	      //       	  rect(10,  y, 80, 10);
	      
	      text(Float.toString(feedbackValue[i]), 3, y); 
	      y = y + distanceSlider;
	  }
      }
      if(Mode.is("predict")){
	  try{
	  NeuronLayer outputLayer = neuralNetwork.get(neuralNetwork.size() - 1);

	  for(Neuron neuron : outputLayer.neurons){

	      int id = neuron.boardId;
	      float v = neuron.predictedValue;
	      
	      text(Float.toString(v), 3, id * distanceSlider + sliderOffset ); 
	  }
	  }catch(Exception e)
	      {}
	      
	  
      }
      
    }

    
    int findSliderID(float py){
	int id = (int) (py / (float) distanceSlider);
	
	return id;
    }

    float findSliderValue(float px){
	px = px - 10;
	px = px / 65f;
	px = constrain(px, 0, 1);

	//	px = px  / drawingSize.x;
	return px;
    }
    
}
