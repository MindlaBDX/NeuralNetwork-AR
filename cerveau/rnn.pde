ArrayList<NeuronLayer> neuralNetwork;

// Init

void initRNN(){

    neuralNetwork = new ArrayList<NeuronLayer>();

    String key = "rnn:init";
    StringBuilder value = new StringBuilder();
    value.append("[");

    // Number of input
    int inputNumber = countLayerSize(0);
    int outputNumber = countLayerSize(MAX_LAYERS - 1);

    if(inputNumber == 0){
	println("Error: cannot create a RNN with no input");
	return ;
    }
    if(outputNumber == 0){
	println("Error: cannot create a RNN with no output");
	return ;
    }
    value.append(Integer.toString(inputNumber) + ",");

    println("Input :  "+ inputNumber);
    println("Output :  "+ outputNumber);
    
    
    NeuronLayer first = new NeuronLayer(0, null);
    NeuronLayer previous = first;

    println("Create first with size " + first.size());
    neuralNetwork.add(first);

    // Find the hidden layers
    for(int i = 1; i <= MAX_HIDDEN_LAYERS; i++){
	int neuronsInLayer = countLayerSize(i);
	if(neuronsInLayer == 0){
	    continue;
	}
	// create the layer 
	NeuronLayer layer = new NeuronLayer(i, previous);
	println("Create layer with size " + layer.size());
	previous = layer;
	neuralNetwork.add(layer);
	value.append(Integer.toString(layer.size()) + ",");	
    }
    //    println("Output number: " + outputNumber);
    NeuronLayer last = new NeuronLayer(MAX_LAYERS -1, previous);
    neuralNetwork.add(last);

    println("Create last with size " + last.size());
    
    // Number of outputs 
    value.append(Integer.toString(outputNumber));
    value.append("]");

    println("Send " + key + " " + value);

    redis.set("rnn:mode", "init");
    redis.set(key, value.toString());

    // TODO: penser à clear
}




void readRNN(){
    //    redis.set("rnn:mode", "learn");
    // Each layer

    println("Read the rnn from network");
    for(NeuronLayer layer : neuralNetwork){
	for(Neuron neuron : layer.neurons){
	    neuron.read();
	}
    }
}

void readPrediction(){
    //    redis.set("rnn:mode", "learn");
    // Each layer

    println("Read the rnn from network");
    for(NeuronLayer layer : neuralNetwork){
	for(Neuron neuron : layer.neurons){
	    neuron.readPrediction();
	}
    }
}




int nbPreviousNeurons(int current){
    if(current == 0){
	println("Error: No previous neuron");
	return 0;
    }
    return neuralNetwork.get(current - 1).size();
}



void sendLearnData(String name){
    sendInput(name);
    sendOutput(name);
}

void sendInput(String name){

    String inputKey = "rnn:" + name + ":input";

    StringBuilder value = new StringBuilder();
    value.append("[");

    //     for(int i = 0; i < nbInputs
    NeuronLayer inputLayer = neuralNetwork.get(0);

    println("InputLayer size " + inputLayer.size());
    for(int i = 0; i < inputLayer.neurons.size(); i++){
	// Default is 0
	float v = 0;
	if(i < inputs.length){
	    v = inputs[i];	    
	}
	value.append(Float.toString(v)).append(",");	
    }

    // remove last
    value.setLength(value.length() - 1);
    value.append("]");
    
    println("sending input learn data: " + value);
    redis.set(inputKey, value.toString());
}

void sendOutput(String name){

    // find last layer
    NeuronLayer outputLayer = neuralNetwork.get(neuralNetwork.size() - 1);
    String outputKey = "rnn:" + name + ":output";

    StringBuilder value = new StringBuilder();
    value.append("[");
    
    // Build the output data.
    for(Neuron n: outputLayer.neurons){
	float v = feedbackValue[n.boardId];
	value.append(Float.toString(v)).append(",");
    }
    // remove last
    value.setLength(value.length() - 1);
    value.append("]");
    
    println("sending output learn data: " + value);
    redis.set(outputKey, value.toString());
}
