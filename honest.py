#now lets import the universe
import os
import subprocess

import pandas as pd
import numpy as np

import xgboost as xgb
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


## Helper functions

def loadData(logTransform=True, impute=False, preprocessed=False, continuous=False):
    """
    loads data and returns stratified test train
    Has to be run in the root directory
    """
    #training
    if(preprocessed):
        if(continuous):
            training = pd.read_csv("cs-training_transformed_continuous.csv", index_col=0)
        else:
            training = pd.read_csv("cs-training_transformed.csv", index_col=0)
    else:
        training = pd.read_csv("cs-training.csv", index_col=0)
    #remove null values
    if impute:
        training['NumberOfDependents'].fillna((training['NumberOfDependents'].mean()), inplace=True)
        training['MonthlyIncome'].fillna((training['MonthlyIncome'].mean()), inplace=True)
    labels = training.SeriousDlqin2yrs
    trainDF = training.drop('SeriousDlqin2yrs', 1)
    #test data
    if(preprocessed):
        if(continuous):
            testDF = pd.read_csv("cs-test_transformed_continuous.csv", index_col=0)
        else:
            testDF = pd.read_csv("cs-test_transformed.csv", index_col=0)
    else:
        testDF = pd.read_csv("cs-test.csv", index_col=0)
    if impute:
        testDF['NumberOfDependents'].fillna((testDF['NumberOfDependents'].mean()), inplace=True)
        testDF['MonthlyIncome'].fillna((testDF['MonthlyIncome'].mean()), inplace=True)
    testDF = testDF.drop('SeriousDlqin2yrs', 1)
    if (logTransform):
        problematicColumns = ['NumberOfTime30-59DaysPastDueNotWorse', 'MonthlyIncome',
                                  'NumberOfOpenCreditLinesAndLoans', 'NumberOfTimes90DaysLate',
                                  'NumberRealEstateLoansOrLines', 'NumberOfTime60-89DaysPastDueNotWorse']
        for col in problematicColumns:
            testDF[col+'-log'] = np.log10(testDF[col]+1e-8)
            trainDF[col+'-log'] = np.log10(trainDF[col]+1e-8)
    X_train, X_test, y_train, y_test = train_test_split(trainDF, labels, test_size=0.2, random_state=123, stratify=labels)
    return (X_train, X_test, y_train, y_test, testDF)

def submit(predictions, filename, message="nothing"):
    """
    Submits to KAGGLE
    """
    df = pd.DataFrame({
        "Id":[i for i in range(1,(len(predictions)+1),1)],
        "Probability":predictions
    })
    df.to_csv(filename, index=False)
    subprocess.run(["kaggle","competitions","submit","-c","givemesomecredit","-f",filename,"-m", message], stdout=subprocess.PIPE)

X_train["NumberOfTime30-59DaysPastDueNotWorse"].describe()
X_train["NumberOfTime30-59DaysPastDueNotWorse"].apply(lambda x: np.abs(x-x.mean()/x.std() <3)

X_train.info()
X_test.info()

numeric_imputation_mapper.transform(X_train)
kjstats.describe(stackPreds)

from scipy import stas
X_test_matrix[1,:]
X_train_matrix[1,:]

preds.flatten(training.head()
training.columns
X_train.info()
numeric_imputation_mapper
