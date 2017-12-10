import fr.inria.papart.procam.*;
import fr.inria.papart.multitouch.*;
import tech.lity.rea.svgextended.*;
import org.bytedeco.javacpp.*;
import org.reflections.*;
import processing.video.*;
import TUIO.*;
import toxi.geom.*;
import fr.inria.papart.depthcam.*;
import fr.inria.papart.procam.display.*;
import tech.lity.rea.skatolo.Skatolo;
import java.awt.event.KeyEvent;
import de.voidplus.redis.*;
import org.openni.*;

import java.util.*;

import fr.inria.guimodes.Mode;

float renderQuality = 1.5f;
Papart papart;

void settings(){
    fullScreen(P3D);
}

// ORDRE:  i, n, f, o, m, r  
// input, neuron, feedback, output, modes,  (reset)

 void setup(){
   //  papart = Papart.seeThrough(this);
     papart = Papart.projection(this);
     papart.loadTouchInput();
     papart.loadSketches();
     papart.startTracking();

     connect();

     Mode.add("init");
     Mode.add("predict");
     Mode.add("learn");

     Mode.set("init");
 }

Redis redis;

void connect(){
  redis = new Redis(this, "54.37.10.254", 6379);
  // redis.auth("156;2Asatu:AUI?S2T51235AUEAIU");
}




// PaperScreens to write.

void draw(){

    if(waitForBackend){
	String b = redis.get("rnn:backend");

	if(b.equals("false")){
	    backendReady();
	}
    }
}

boolean test = false;


void keyPressed() {
    if(key == 'i'){
	initRNN();
	readRNN();
    }

    
    if(key == 'r'){
	neuronZone.initNeuronCapture();
    }

    if(key == '1'){
	modeChange("init");
    }
    if(key == '2'){
	modeChange("learn");
    }
    if(key == '3'){
	modeChange("predict");
    }

    // if(key == 'l'){
    // 	leftAdjust++;
    // }
    // if(key == 'L'){
    // 	leftAdjust--;
    // }
    // println("left " + leftAdjust);

    // if(key == 'i'){
    // 	inputAdjust++;
    // }
    // if(key == 'I'){
    // 	inputAdjust--;
    // }
    // println("input " + inputAdjust);

    
    // if(key == 'o'){
    // 	outputAdjust++;
    // }
    // if(key == 'O'){
    // 	outputAdjust--;
    // }
    // println("output " + outputAdjust);

    if(key == 'd'){
    	sliderOffset++;
    }
    if(key == 'D'){
    	sliderOffset--;
    }
    println("sliderOffset " + sliderOffset);

    
    
    // if(key == 'p'){
    //	sendInput();
	//	inputZone.sendPixels();
    // }


    
    if(key == '5'){
	//	readNeuron(1, 0);
	///	test = !test;
    }

}

boolean waitForBackend = false;

void modeChange(String mode){
    if(Mode.is(mode)){
	return;
    }
    println("Mode change from: " + Mode.getCurrentName()  + " to " + mode);

    if(Mode.is("init")){
	redis.flushDB();
	initRNN();
	// Send init...

	// wait 
	//	waitForBackend();

	// or local run
	runProgram("init");
	
	
	// After init: read
	readRNN();
    }
    if(mode.equals("init")){
	neuronZone.initNeuronCapture();
    }

    Mode.set(mode);
}

void sendFeebdack(){

    if(Mode.is("predict")){
	sendLearnData("predict");
	runProgram("predict");
	readPrediction();
    }
    
    if(Mode.is("learn")){

    println("Sending...");
    sendLearnData("train");

    println("Training...");
    (new LearnThread()).start();
    // for(int i = 0; i < 10; i++){
    // 	runProgram("train");

    // println("Update data...");
    // readRNN();
    // }
    }

    }

class LearnThread extends Thread{
    public void run(){
	for(int i = 0; i < 5; i++){
	    runProgram("train");
	    println("Update data...");
	    readRNN();
	}
    }
}


void waitForBackend(){
    redis.set("rnn:backend", "true");
    waitForBackend = true;
}

void backendReady(){
    if(Mode.is("predict")){
	readRNN();
    }
}

Process backgroundProcess;

void runProgram(String action){
    println("Run : " + action);
    // String file = sketchPath() + "/python/tangible_final.py";
    String file = "tangible_final.py";
    ProcessBuilder pb = new ProcessBuilder("python", file, action);
    Map<String, String> env = pb.environment();

    String dir = sketchPath() + "/python/";
    pb.directory(new File(dir));
    pb.redirectErrorStream(true);
    // Inherit System.out as redirect output stream
    pb.redirectOutput(ProcessBuilder.Redirect.INHERIT);

    
    // env.put("VAR1", "myValue");
    // env.remove("OTHERVAR");
    // env.put("VAR2", env.get("VAR1") + "suffix");
    // pb.directory(new File("myDir"));
    try{
	backgroundProcess  = pb.start();

	// Wait for it
	backgroundProcess.waitFor();
    }catch(InterruptedException e){
	println("Interruption error " + e);
    }catch(IOException e){
	println("IO error " + e);
    }

}
