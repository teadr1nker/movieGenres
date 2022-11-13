#!/usr/bin/python3
import tensorflow as tf
import numpy as np
from tensorflow.keras.layers import TextVectorization
import string
import re

def standartization(data):
    stripped = tf.strings.regex_replace(
            tf.strings.lower(data),
            "<br />", " ")
    return tf.strings.regex_replace(
        stripped, f"[{re.escape(string.punctuation)}]", "")

print(standartization("hello <br> WORLD"))    
