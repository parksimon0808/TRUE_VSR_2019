# Short-term Prediction of Metro Ridership in Seoul

This project uses a LSTM model to predict the number of passengers getting on and off per hour interval at a given station.

## Prerequisites

1. Python 3
2. Python Libraries
- Numpy
- Pandas
- Matplotlib
- TensorFlow
- Keras
- Sklearn
3. Jupyter Notebook

## Running the code

Data Preprocessing
1. Run process.py. This code processes the raw data file and creates a separate data file for each station for each calendar year.
2. Run process_combine.py. This code combines the data from all available calendar years for each station.
3. Open data/result.csv and delete the second column. The current values are the accuracy of the model on each station from a test run on a local environment.

Training
1. Open Training - One Station.ipynb and run the code if you want to train and evaluate the model on the data from one specific station.
2. Open Training - All Stations.ipynb and run the code if you want to train the model on the data from each station. This file automatically updates result.csv.

## Analyzing the result

Open result.csv and look at the SMAPE values for each station.
