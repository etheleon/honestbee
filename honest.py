#now lets import the universe
import os

import pandas as pd
import numpy as np

import rpy2
%load_ext rpy2.ipython
# use R plot instead
#import matplotlib.pyplot as plt
#%matplotlib inline
from tqdm import tqdm_notebook

#machine learning
## xgboost
import xgboost as xgb
## sklearn
import sklearn
from sklearn.model_selection import train_test_split
# from sklearn.pipeline import FeatureUnion     #
from sklearn_pandas import DataFrameMapper    #
from sklearn_pandas import CategoricalImputer #
from sklearn.model_selection import cross_val_score
from sklearn.feature_extraction import DictVectorizer
from sklearn.preprocessing import FunctionTransformer
from sklearn.model_selection import RandomizedSearchCV
from sklearn.model_selection import GridSearchCV
#score
from sklearn.metrics import roc_auc_score

os.chdir("/data/honestbee")

def loadData():
    """
    loads data
    """
    #training
    training = pd.read_csv("cs-training.csv", index_col=0)
    #remove null values
    training['NumberOfDependents'].fillna((training['NumberOfDependents'].mean()), inplace=True)
    training['MonthlyIncome'].fillna((training['MonthlyIncome'].mean()), inplace=True)
    y_train = training.SeriousDlqin2yrs
    X_train = training.drop('SeriousDlqin2yrs', 1)

    #test data
    testing = pd.read_csv("cs-test.csv", index_col=0)
    testing['NumberOfDependents'].fillna((testing['NumberOfDependents'].mean()), inplace=True)
    testing['MonthlyIncome'].fillna((testing['MonthlyIncome'].mean()), inplace=True)
    testing = testing.drop('SeriousDlqin2yrs', 1)
    return (X_train, y_train, testSet)

