# -*- coding: utf-8 -*-
"""
Created on Wed Dec  6 12:58:23 2017
inspired by :
    https://iamtrask.github.io/2015/07/12/basic-python-network/
    https://mattmazur.com/2015/03/17/a-step-by-step-backpropagation-example/
    https://www.youtube.com/watch?v=ILsA4nyG7I0
    https://machinelearningmastery.com/implement-backpropagation-algorithm-scratch-python/
@author: lrosique
"""
import numpy as np
import redis
import ast
import threading
import time
import sys
import pickle

# seed random numbers to make calculation deterministic (just a good practice)
np.random.seed()

#################################
#################################
# FUNCTIONS
# Sum of weights at layer level
def sum_weight(X, w):
    sums = []
    for i in range(np.size(w,0)):
        sums.append(sum_weight_on_neuron(X,w, i))
    return np.array(sums)

# Sum of weights at neuron level
def sum_weight_on_neuron(X, w, neuron_number):
    return np.sum(X*w[neuron_number])

# Function sigmoïd (positive)
def sigmoid_positive(x,deriv=False):
    if(deriv==True):
        return x*(1-x)
    return 1/(1+np.exp(-x))
sigmoid_positive = np.vectorize(sigmoid_positive)

# Function sigmoïd (between -1 and 1)
def sigmoid(x,deriv=False):
    if(deriv==True):
        return 2*sigmoid_positive(x, True)
    return 2*sigmoid_positive(x) - 1
sigmoid = np.vectorize(sigmoid)

# Function identity
def identity(x,deriv=False):
    if(deriv==True):
        return 1
    return x
identity = np.vectorize(identity)

# Function ReLU
def relu(x,deriv=False):
    if x > 0:
        if(deriv==True):
            return 1
        else:
            return x
    return 0
relu = np.vectorize(relu)

# Automatic generation of weights at layer level
def genererate_weights_layer(size_n1, size_n2):
    # Testing case : weights go by +1 at each connection
    # wlayer = np.arange(size_n1*size_n2).reshape(size_n2, size_n1)
    # Testing case : all equal to 1
    # wlayer = np.ones(size_n1*size_n2).reshape(size_n2, size_n1)
    # Random case (usual)
    wlayer = np.random.random((size_n2,size_n1))
    return wlayer

# Automatic generation of weights at network level
def genererate_weights_network(size_layer):
    print('Generating network weights...')
    size_n1 = None
    size_n2 = None
    weights_network = []
    for x in np.nditer(size_layer):
        size_n2 = x
        if(size_n1 is not None):
            weights_network.append(genererate_weights_layer(size_n1, size_n2))
        size_n1 = x
    return np.array(weights_network)

# Full run forward of a network
def evaluate_network(X_in, weight, nb_neurons_per_layer):
    list_sums = []
    list_functions = []
    result_layer = X_in
    for i in range(np.size(nb_neurons_per_layer, 0) - 1):
        sum_weights_layer = sum_weight(result_layer, weight[i])
        result_layer = sigmoid_positive(sum_weights_layer) #globals().get(functions_at_neurons[i])(sum_weights_layer)
        list_sums.append(sum_weights_layer)
        list_functions.append(result_layer)
    return [np.array(list_sums), np.array(list_functions)]

def save_network(r, matrix_data, key_as_save):
    print('Saving...')
    #Layers
    for i in range(np.size(matrix_data, 0)):
        #Neurons
        for j in range(np.size(matrix_data[i], 0)):
            #print('rnn:neuron:'+str(i)+':'+str(j)+':'+'['+','.join(str(e) for e in matrixWeights[i][j].tolist())+']')
            save_nplist(r, key_as_save+str(i)+':'+str(j),matrix_data[i][j])

def save_nplist(r, key, nplist):
    r.set(key,'['+','.join(str(e) for e in nplist.tolist())+']')

def save_values(r, matrix_values, key_for_save):
    print('Saving...')
    #Layers
    for i in range(np.size(matrix_values, 0)):
        #Neurons
        for j in range(np.size(matrix_values[i], 0)):
            #print('rnn:neuron:'+str(i)+':'+str(j)+':'+str(l1[i][j]))
            r.set(key_for_save+str(i)+':'+str(j), str(matrix_values[i][j]))
            
# Backpropagate error and store in neurons
def backward_propagate_error(neurons_per_layer, weights, y_out, y_exp):
    deltas = []
    for i in reversed(range(len(neurons_per_layer) - 1)):
        errors = list()
        delta = []
        # Traitement de la dernière couche
        if (i == len(neurons_per_layer) - 2):
            for j in range(neurons_per_layer[i+1]):
                errors.append(- y_exp[j] + y_out[i][j])
        # Traitement des autres couches
        if (i != len(neurons_per_layer) - 2):
            for j in range(neurons_per_layer[i+1]):
                error = 0.0
                for k in range(neurons_per_layer[i+2]):
                    error += (weights[i+1][k][j]*deltas[len(neurons_per_layer) - 3 - i][k])
                errors.append(error)
        #print(errors)
        for j in range(neurons_per_layer[i+1]):
            delta.append(errors[j]*sigmoid_positive(y_out[i][j], deriv=True))
        deltas.append(delta)
    #print(deltas)
    return deltas

def save_weights(weights):
    with open('weights.pickle', 'wb') as handle:
        pickle.dump(weights, handle, protocol=pickle.HIGHEST_PROTOCOL)

def calculate_new_weights(weights, y_out, deltas_neurons):
    new_weights = []
    for i in range(np.size(weights, 0)):
        new_weight = []
        for j in range(np.size(weights[i], 0)):
            new_weight.append((weights[i][j] - y_out[i][j]*deltas_neurons[i][j]).tolist())
        new_weights.append(np.array(new_weight))
    return np.array(new_weights)

def score_error(r, neurons_per_layer, y_out, y_exp):
    errors = []
    for j in range(neurons_per_layer[-1:][0]):
        errors.append(1/2*(- y_exp[j] + y_out[np.size(neurons_per_layer,0)-2][j])**2)
    total_error = np.sum(errors)
    # Save errors
    r.set('rnn:train:errors:','['+','.join(str(e) for e in errors)+']')
    # Save total error
    r.set('rnn:train:total_error:',total_error)
    return [total_error, errors]

def initialize(r):
    print('Initializing...')
    # Get size of layers
    v = r.get('rnn:init').decode("utf-8")
    v = np.array(ast.literal_eval(v))
    # Generate weights
    weights = genererate_weights_network(v)
    # Save weights on redis
    save_network(r, weights, 'rnn:neuron:weights:')
    save_weights(weights)
    # Printing
    print('Neurons per layer = ',v)
    print('Network weights = ',weights)
    return [v, weights]
    
def predict(r):
    print('Predicting...')
    neurons_per_layer = get_neurons_per_layer_redis(r)
    weights = get_weights_redis(r, neurons_per_layer)
    # Input
    X = r.get('rnn:predict:input').decode("utf-8")
    X = np.array(ast.literal_eval(X))
    # Evaluation
    lst = evaluate_network(X, weights, neurons_per_layer)
    # Save sums
    save_values(r, lst[0], 'rnn:predict:sums:')
    # Save outputs
    save_values(r, lst[1], 'rnn:predict:outputs:')
    # Printing
    print('X_input = ',X)
    print('Sums = ',lst[0])
    print('Outputs = ',lst[1])
    return [lst[0],lst[1]]
    
def train(r):
    print('Training...')
    neurons_per_layer = get_neurons_per_layer_redis(r) 
    weights = get_weights_redis(r, neurons_per_layer)
    # Input
    X = r.get('rnn:train:input').decode("utf-8")
    X = np.array(ast.literal_eval(X))
    # Output (expected)
    y_expected = r.get('rnn:train:output').decode("utf-8")
    y_expected = np.array(ast.literal_eval(y_expected))
    # Forward pass
    [list_sums, list_y] = evaluate_network(X, weights, neurons_per_layer)
    # Errors
    [total_error, errors] = score_error(r, neurons_per_layer, list_y, y_expected)
    # Backward deltas
    deltas = backward_propagate_error(neurons_per_layer, weights, list_y, y_expected)[::-1]
    # New weights
    weights_updated = calculate_new_weights(weights, list_y, deltas)
    # Save deltas
    save_values(r, deltas, 'rnn:train:deltas:')
    # Save weights
    save_values(r, weights_updated, 'rnn:train:weights:')
    save_network(r, weights_updated, 'rnn:neuron:weights:')
    save_weights(weights_updated)
    # Printing
    print('X_input = ',X)
    print('y_expected = ',y_expected)
    print('y_actual = ',list_y[-1:])
    print('Total error = ',total_error)
    print('Partial errors = ',errors)
    print('Deltas = ',deltas)
    print('Old weights = ',weights)
    print('New weights = ',weights_updated)
    return [weights_updated, list_y[np.size(neurons_per_layer,0) -2], y_expected, total_error, errors]

# Connexion to Redis
#r = redis.StrictRedis(host='54.37.10.254', port=6379, db=0)

# Initialization
#[nbNeuronsPerLayers,networkWeights] = initialize(r)

# Prediction
#[sums,y_out] = predict(r, nbNeuronsPerLayers, networkWeights)

# Training
#[networkWeights, output_actual, output_expected, totalError, errorsPerNeuron] = train(r, nbNeuronsPerLayers, networkWeights)

def get_neurons_per_layer_redis(r):
    X = r.get('rnn:init').decode("utf-8")
    X = np.array(ast.literal_eval(X))
    return X

def get_weights_redis(r, neurons_per_layer):
    #return networkWeights
    with open('weights.pickle', 'rb') as handle:
        loadWeights = pickle.load(handle)
    return loadWeights
    #weights = genererate_weights_network(neurons_per_layer)
    #for j in range(neurons_per_layer[i+1]):
    #    for i in range(np.size(neurons_per_layer)-1):
    #        print(i,' ',j)
    #        sw = r.get('rnn:neuron:weights:'+str(i)+':'+str(j)).decode("utf-8")
    #        spl = sw.replace('[','').replace(']','').split(',')
    #        for k in range(len(spl)-1):
    #            weights[i][j][k] = np.float64(spl[k])
    #return weights

if __name__ == "__main__":
    r = redis.StrictRedis(host='54.37.10.254', port=6379, db=0)
    # r = redis.StrictRedis(host='localhost', port=6379, db=0)
    if (sys.argv[1] == 'init'):
        [nbNeuronsPerLayers,networkWeights] = initialize(r)
    elif (sys.argv[1] == 'predict'):
        [sums,y_out] = predict(r)
    elif  (sys.argv[1] == 'train'):
        [networkWeights, output_actual, output_expected, totalError, errorsPerNeuron] = train(r)
    else:
        print('Argument non reconnu')
