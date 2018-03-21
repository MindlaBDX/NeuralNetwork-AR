import fr.inria.papart.procam.ColorDetection;
import fr.inria.papart.utils.MathUtils;
import fr.inria.papart.utils.*;
import fr.inria.papart.multitouch.detection.*;
import fr.inria.papart.multitouch.*;
import fr.inria.papart.multitouch.tracking.*;
import fr.inria.papart.calibration.*;
import fr.inria.papart.calibration.files.*;

NeuronZone neuronZone;


public class NeuronZone  extends TableScreen {

  ColorTracker colorTracker;
    CalibratedStickerTracker stickerTracker;


  /// A envoyer
  // Nombre d'entrée, 
  // Nombre de neurones / couche  
  //  clé  " Type: couche, id-neurone: 
  // "clé" rnn:neuron:weights:1:1 - "Matrice" 
  //  rnn:neuron:1:1:type - "sigmoid A" 
     //  rnn:neuron:1:1:bias - "sigmoid A" 
    // input: 0,  hidden #1 1  

    // RNN:rate  -> 
  // --> event 
  //  rnn:init  "4;3;3;1" 
  //  4 input; 3, 3 hidden, 1 sortie
  //
  //  Refresh des layer avec poids random. 
  // Apprentissage
  // Event-> 
  //  Rempli:  rnn:input: "0.1; 0.2; 0.1; 0.1"  (Liste)
    //         rnn:output:  "0.1, 0.1"
  // 
  //  Refresh des layer avec poids ajusté.
  
  
  // Mode test: 
  //  rnn:input:"0.1; 0.2; 0.1; 0.1"  (Liste)


    public NeuronZone(){
	super(neuronZonePos, neuronZoneSize.x, neuronZoneSize.y);
	init();
    }
    
    public void init() {
	neuronZone = this;
	
	stickerTracker = new CalibratedStickerTracker(this, 9);
	
	//	colorTracker = papart.initRedTracking(this, 1f);
	// colorTracker = papart.initBlueTracking(this, 0.5f);
	
	// setSaveName(sketchPath() + "/neuron.xml");
	// useAlt(false);
	// setLoadSaveKey("n", "N");
	// setDrawingFilter(0);    
	initNeuronCapture();
  }

    void initNeuronCapture(){
	// int because we use the age.
	capturedNeurons = new int[MAX_LAYERS][MAX_NEURON_PER_LAYER];
    }
    
    public void drawOnPaper() {
	background(10, 180);
	fill(200, 100, 20);
	
	strokeWeight(3);
	noFill();
	stroke(255);
	rect(0, 0, drawingSize.x, drawingSize.y);
	
	ArrayList<TrackedElement> te = stickerTracker.findColor(millis());
	TouchList touchs = stickerTracker.getTouchList(1); // 1 is red
	//	ArrayList<TrackedElement> te = colorTracker.findColor(millis());
	// TouchList touchs = colorTracker.getTouchList();
	
	// Draw the touch found by the tracker. 
	fill(0, 100, 100);
	
	if(Mode.is("init")){
	    for (Touch t : touchs) {
		// Debug
		ellipse(t.position.x, t.position.y + 8, 2, 2);
		// text(t.id, t.position.x, t.position.y + 8);
		// First layer
		fillDetectedNeuron(t.position.x, t.position.y);
	    }
	}
	drawDetectedNeurons();
	
	if(Mode.is("init")){
	    drawAllInputs();
	}
	if(Mode.is("learn") || Mode.is("predict")){
	    if( neuralNetwork!= null && neuralNetwork.size() > 0){
		drawNeuronLinks();
	    }
	}
	
    }

    void drawNeuronLinks(){
	NeuronLayer prevLayer = null;
	//	println("draw links");
	for(NeuronLayer layer: neuralNetwork){

	    //	    println("Layer " + layer.networkID);
	    for(Neuron neuron : layer.neurons){
		drawWeights(neuron, prevLayer);

	    }
	    prevLayer = layer;
	}

	for(NeuronLayer layer: neuralNetwork){
	    //	    println("Layer " + layer.networkID);
	    for(Neuron neuron : layer.neurons){
		drawOutputs(neuron, prevLayer);
	    }
	    prevLayer = layer;
	}

	drawInputs();
    }

    void drawWeights(Neuron neuron, NeuronLayer prevLayer){

	// No link in the first layer
	if(prevLayer == null){
	    return;
	}
	
	//	fill(255);
	strokeWeight(2);
	// rect(neuron.position.x,
	//      neuron.position.y,
	//      10, 10);
	if(neuron.weights == null){
	    //	    println("no weights.");
	    return;
	}
	if(neuron.weights.length != prevLayer.size()){
	    // println("prevLayer: " + prevLayer.networkID);
	    // println("Neuron: " + neuron.id + " " + neuron.boardId);
	    // println("Size mismatch data: " + neuron.weights.length + ", prev Layer size: " + prevLayer.size() );
	    return;
	} 
	
	int k = 0;
	for(Neuron prevNeuron : prevLayer.neurons){
	    float weight = neuron.weights[k++];
	    stroke(weight * 255f);
	    // println("line " + prevNeuron.position + " "+ neuron.position);
		    //			stroke(255);
	    strokeWeight(2);
	    line(prevNeuron.position.x, prevNeuron.position.y,
		 neuron.position.x, neuron.position.y);
	}
    }

    void drawOutputs(Neuron neuron, NeuronLayer prevLayer){

	if(prevLayer == null || neuron.weights == null){
	    return;
	}
	if(neuron.weights.length != prevLayer.size()){
	    return;
	} 
	int k = 0;

	translate(0, 0, 1);
	for(Neuron prevNeuron : prevLayer.neurons){
	    float weight = neuron.weights[k++];
	    if(neuron.predictedValue != -2){
		fill(255);
		stroke(255);
		strokeWeight(1);
		text(neuron.predictedValue,
		     neuron.position.x - 55,
		     neuron.position.y);
	    }
	}
    }

    void drawAllInputs(){
	noStroke();
	translate(0, 0, 1);
	for(int i = 0; i < MAX_NEURON_PER_LAYER; i ++){
	    float intens = inputs[i];

	    fill(intens * 255);
	    strokeWeight(1);
	    rect(50,
		 i * neuronHeight ,
		 25, 25);

	}
    }

    
    void drawInputs(){
	NeuronLayer layer = neuralNetwork.get(0);

	noStroke();
	translate(0, 0, 1);
	for(Neuron neuron : layer.neurons){
	    int id = neuron.boardId;
	    float intens = inputs[id];

	    fill(intens * 255);
	    strokeWeight(1);
	    rect(neuron.position.x + 10,
		 neuron.position.y - 10, 25, 25);
	}
    }

    
    void drawDetectedNeurons(){
	strokeWeight(1);
	fill(100, 200, 100);
	noStroke();

	// X adjust initial layer
	int x = leftAdjust;
	int validLayerID = 0;
	
	for(int layer = 0; layer < MAX_LAYERS; layer++){

	    // X adjust last Width
	    if(layer == MAX_LAYERS - 1){
		x = x + lastWidth - hiddenLayerWidth;
	    }
	    // X adjust middle layers
	    int middle = hiddenLayerWidth / 2;
	    if(layer == 0){
		middle = inputAdjust; // hack mm
	    }

	    if(layer == MAX_LAYERS - 1){
		middle = outputAdjust; // hack mm
	    }

	    boolean validLayer = false;
	    int validID = 0;

	    // search the valid neurons
	    for(int id = 0; id < MAX_NEURON_PER_LAYER; id++){

		// get the Y position. 
		int y = id * neuronHeight;

		// if the neuron is detected
		if(capturedNeurons[layer][id] > detectionTime){

		    // There is a neuron in this layer
		    
		    validLayer = true;
		    // Valid neuron ! Set its location. 
		    //		    ellipse(x + middle, y + neuronHeight/2, 15, 15);


		    // try to save the position
		    if(neuralNetwork!= null && neuralNetwork.size() > 0){

			try{
			    // check bounds
			    if(validLayerID < neuralNetwork.size()&&
			       validID < neuralNetwork.get(validLayerID).size()){
				Neuron neuron = neuralNetwork.get(validLayerID).get(validID);
				neuron.setPosition(x + middle, y + neuronHeight/2);
			    }
			}catch(Exception e){
			    println("Cannot save neuron location: " + validLayerID  + " " + validID);
			}
		    }
		    ellipse(x + middle, y + neuronHeight/2,
			    15, 15);
		    validID++;
		}
	    }
	    
	    if(validLayer){
		validLayerID++;
	    }

	    // move forward in X 
	    if(layer == 0){
		x = x+ firstWidth;
	    } else {
		x = x+ hiddenLayerWidth;
	    }
	}
    }

}

int detectionTime = 5;

int leftAdjust = 13; //mm
int inputAdjust = 3;
int outputAdjust = 30;

int firstWidth = 60;       // mm
int hiddenLayerWidth = 55; // mm
int lastWidth = 80;        // mm
int neuronHeight = 32;     // mm 

int firstSecondDistance = 85; // mm


void fillDetectedNeuron(float px, float py){
    if(px < 0 || py < 0){
	return;
    }

    int totalHiddenLayerWidth = hiddenLayerWidth * MAX_HIDDEN_LAYERS;
    
    // detected x
    int layer = -1;
    int id = -1;
    
    // input Layer
    if(px < firstWidth){
	layer = 0;
    } else {
	px = px - firstWidth;
	// hidden layer
	if(px < totalHiddenLayerWidth){
	    layer = (int) (1 + px / hiddenLayerWidth);
	} else { // last layer 
	    px = px - totalHiddenLayerWidth;
	    if(px < lastWidth) {
		layer = MAX_LAYERS - 1;
	    }
	}
    }

    // neuron ID

    id = (int) (py / neuronHeight); 
    if(id > MAX_NEURON_PER_LAYER - 1){
	id = -1;
    }
    if(layer != -1 && id != -1){
	//	println("Setting neuron " + layer + " " + id);
	capturedNeurons[layer][id]++;
    }
}


int[][] capturedNeurons;

// creation
int MAX_LAYERS = 7;
int MAX_HIDDEN_LAYERS = MAX_LAYERS - 2;
int MAX_NEURON_PER_LAYER = 10;
ArrayList<Integer> capturedLayers = new ArrayList<Integer>(MAX_LAYERS);

int countLayerSize(int layerId){
    int k = 0;
    boolean empty = true;
    for(int id = 0; id < capturedNeurons[layerId].length; id++){
	if(capturedNeurons[layerId][id] > detectionTime){
	    empty = false;
	    k++;
	}
    }
    return k;
}

int countLayers(){
    //     ArrayList<Integer> capturedLayers = new ArrayList<>(max_layers
    int k = 0;
    for(int layer = 0; layer < capturedNeurons.length; layer++){
	int nb = countLayerSize(layer);
	if(nb != 0){
	    k++;
	}
    }
    return k;
}

int getCapturedLayer(int layerNb){
    //     ArrayList<Integer> capturedLayers = new ArrayList<>(max_layers
    int k = 0;
    for(int i = 0; i < capturedLayers.size(); i++){
	if(capturedLayers.get(i) > 0){
	    if(k == layerNb){
		return capturedLayers.get(i);
	    }
	    k++;
	}
    }

    // Warning depassement ?
    println("Error: getting invalid layer");
    return 0;
}
