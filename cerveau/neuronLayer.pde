class NeuronLayer {
    ArrayList<Neuron> neurons;
    NeuronLayer previousLayer = null;
    int layerDetectionID = 0;
    int networkID = 0;
    
    public NeuronLayer(int lineId, NeuronLayer previous){
	if(previous == null){
	    networkID = 0;
	} else {
	    networkID = previous.getID() + 1;
	}
	this.previousLayer = previous;
	this.layerDetectionID = lineId;
	
	neurons = new ArrayList<Neuron>();

	createNeurons();
    }

    void createNeurons(){
	int k =0;
	println("Add neurons for layer " + networkID);

	println("Expected: " + countLayerSize(networkID));
	
	for(int id = 0; id < capturedNeurons[0].length; id++){
	    if(capturedNeurons[layerDetectionID][id] >  detectionTime){
		Neuron n = new Neuron(this, k++, id);
		neurons.add(n);
		println("Add neuron");
	    }
	}
    }

    int getID(){
	return networkID;
    }

    Neuron get(int id){
	if(neurons.size() <= id){
	    println("ERROR: invalid neuron id");
	}
	return neurons.get(id);
    }

    int size(){
	return neurons.size();
    }
}

class Neuron { 
    float weights[];
    // float value = 0;
    // boolean input = false;
    // String key;

    NeuronLayer layer;
    int boardId;
    int id;

    PVector position = new PVector();
    
    public Neuron(NeuronLayer layer, int id, int boardId){
	this.id = id;
	this.boardId = boardId;
	this.layer = layer;
    }

    void setPosition(int x, int y){
	this.position.set(x,y);
    }
    
    void read(){
	if(layer.getID() == 0){
	    //	    println("No weight for first layer...");
	    return;
	}

	String keyBegin = "rnn:neuron:weights";	
	int layerID = layer.getID() - 1;
	
	//	println("Read weight from network...");
	// println("neuronID " + this.id + " layer " + layer.getID() + ".");
	
	// Do not read the input layer
	String key = keyBegin + ":" + layerID + ":" + id;

	//	println("Key " + key);
	String inputWeightStr = redis.get(key);

	//	println("data: " + inputWeightStr);
	
	if(inputWeightStr == null){
	    println("Read neuron error no input for: "  + key);
	    return;
	}
	
	// remove [ and ]
	inputWeightStr = (inputWeightStr.substring(1, inputWeightStr.length() - 1));
	
	// get the new weights
	String[] weights  =  inputWeightStr.split(",");

	int prevLayerSize = layer.previousLayer.size();
	if(weights.length != prevLayerSize){
	    println("Size error: " + weights.length + " received " + prevLayerSize + " expected.");
	}
	setWeights(weights);
    }

    float predictedValue = -2;

    void readPrediction(){
	if(layer.getID() == 0){
	    //	    println("No weight for first layer...");
	    return;
	}

	String keyBegin = "rnn:predict:outputs";	
	int layerID = layer.getID() - 1;
	
	//	println("Read weight from network...");
	// println("neuronID " + this.id + " layer " + layer.getID() + ".");
	
	// Do not read the input layer
	String key = keyBegin + ":" + layerID + ":" + id;

	println("Key " + key);
	String inputWeightStr = redis.get(key);
	println("data: " + inputWeightStr);
	
	if(inputWeightStr == null){
	    println("Read neuron error no input for: "  + key);
	    return;
	}
	predictedValue = Float.parseFloat(inputWeightStr);
    }

    
    
    public void setWeights(String[] input){
	if(weights == null){
	    weights = new float[input.length];
	}

	if(input.length != weights.length){
	    println("Wrong number of inputs: " + input.length + " instead of " +weights.length );
	}

	println("Set weight for neuron " + id + " " + boardId);
	for(int i = 0; i < input.length; i++){

	    weights[i] = Float.parseFloat(input[i]);
	    print(weights[i] + " ");
	}
	println("");
	// Warning: Error possible with Numberformat format.

	// debug
	// for(String item : input){
	//     println("w:  " + item);
	// }

    }
    
}
