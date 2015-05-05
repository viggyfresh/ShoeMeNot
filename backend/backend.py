from flask import Flask
from flask import jsonify
import cv2
import caffe
import numpy as np

app = Flask(__name__)

classifier = None
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

if __name__ == "__main__":
    classifier = caffe.Classifier('viggynet_class_deploy.prototxt',
                                  'viggynet_class.caffemodel',
                                  mean=np.load('viggynet_class_mean.npy'),
                                  raw_scale=255,
                                  image_dims=(180, 240))
    app.run(debug=True)
