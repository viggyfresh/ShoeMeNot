from flask import Flask
from flask import jsonify
import cv2
import caffe
import numpy as np
import json

app = Flask(__name__)

classifier = None
extractor = None
transformer = None
features = None

categories = {0: 'Sneakers & Athletic Shoes', 1: 'Boots', 2: 'Oxfords', 3: 'Loafers', 4: 'Sandals', 5: 'Boat Shoes', 6: 'Slippers', 7: 'Clogs & Mules', 8: 'Insoles & Accessories', 9: 'Climbing', 10: 'Heels', 11: 'Flats'}


@app.route("/")
def hello():
    resp = jsonify({"msg": "Hello!", "data": [1, 2, 3]})
    resp.status_code = 200
    return resp

@app.route("/classify")
def classify_demo():
    img = caffe.io.load_image("test4.jpg")
    prediction = classifier.predict([img], oversample=False).argmax()
    resp = jsonify({"msg": categories[prediction], "data": prediction})
    resp.status_code = 200
    return resp

@app.route("/classify/<id>")
def classify(id):
    img = caffe.io.load_image("./shoe_dataset/" + id + ".jpg")
    global classifier
    prediction = classifier.predict([img], oversample=False).argmax()
    resp = jsonify({"msg": categories[prediction], "data": prediction})
    resp.status_code = 200
    return resp

@app.route("/compare/<id>")
def compare(id):
    img = caffe.io.load_image("./shoe_dataset/" + id + ".jpg")
    global extractor
    global transformer
    global features
    extractor.blobs['data'].data[...] = transformer.preprocess('data', img)
    out = extractor.forward()
    curr = extractor.blobs['fc6'].data.reshape((4096,))
    rev = extractor.backward()
    result = features - curr
    squared_dists  = np.square(result)
    sum_squares = np.sum(squared_dists, axis=1)
    dists = np.sqrt(sum_squares)
    sorted_indices = np.argsort(dists)
    closest = sorted_indices[:11]
    resp = jsonify({"msg": "Closest matches for " + id, "data": closest.tolist()})
    resp.status_code = 200
    return resp

if __name__ == "__main__":
    caffe.set_mode_cpu()
    classifier = caffe.Classifier('viggynet_class_deploy.prototxt',
                                  'viggynet_class.caffemodel',
                                  mean=np.load('viggynet_class_mean.npy'),
                                  raw_scale=255,
                                  image_dims=(180, 240))

    extractor = caffe.Net('vgg.prototxt', 'vgg.caffemodel', caffe.TEST)
    transformer = caffe.io.Transformer({'data': extractor.blobs['data'].data.shape})
    transformer.set_transpose('data', (2,0,1))
    transformer.set_raw_scale('data', 255)
    extractor.blobs['data'].reshape(1, 3, 224, 224)
    features = np.load('features.npy')
    app.run(debug=True)
