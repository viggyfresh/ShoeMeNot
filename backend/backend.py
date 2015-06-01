from flask import Flask, request, redirect, url_for
from flask import jsonify
import os
import cv2
import caffe
import numpy as np
import json
import pickle
import re
import PIL
import uuid
from werkzeug import secure_filename

classifier = None
extractor = None
transformer = None
features = None
cat_map = None
rev_map = None
valid_images = None
ip = "128.12.10.36"
port = "5000"
UPLOAD_FOLDER = './static/uploads/'
ALLOWED_EXTENSIONS = set(['jpg', 'jpeg', 'png', 'tiff'])

app = Flask(__name__)
app.config['UPLOAD_FOLDER'] = UPLOAD_FOLDER

categories = {0: 'Sneakers & Athletic Shoes', 1: 'Boots', 2: 'Oxfords', 3: 'Loafers', 4: 'Sandals', 5: 'Boat Shoes', 6: 'Slippers', 7: 'Clogs & Mules', 8: 'Insoles & Accessories', 9: 'Climbing', 10: 'Heels', 11: 'Flats'}

@app.route("/")
def hello():
    resp = jsonify({"msg": "Hello!", "data": [1, 2, 3]})
    resp.status_code = 200
    return resp

@app.route("/shoe/<id>")
def shoe(id):
    with open("./static/shoe_dataset/" + id + ".txt") as file:
        lines = [line.rstrip('\n') for line in file]
        metadata = {}
        metadata["id"] = lines[0]
        metadata["name"] = lines[1]
        metadata["brand"] = lines[2]
        metadata["color"] = lines[3]
        category = re.search("> .* >", lines[4])
        metadata["category"] = category.group(0)[2:-2]
        metadata["price"] = lines[6]
        metadata["stars"] = lines[7]
        metadata["sku"] = lines[8]
        metadata["msg"] = "Shoe data as promised!"
        resp = jsonify(metadata)
        resp.status_code = 200
        return resp

@app.route("/discover")
def discover():
    choices = np.random.choice(valid_images, size=50,replace=False)
    resp = jsonify({"msg": "Got 50 random shoes", "data": choices.tolist()})
    resp.status_code = 200
    return resp

def allowed_file(filename):
    return '.' in filename and \
           filename.rsplit('.', 1)[1] in ALLOWED_EXTENSIONS

@app.route("/upload", methods=['POST'])
def upload():
    id = str(uuid.uuid4())
    if request.method == 'POST':
        file = request.get_data()
        if file and allowed_file(id + '.jpg'):
            filename = secure_filename(id + '.jpg')
            with open(os.path.join(app.config['UPLOAD_FOLDER'], filename), 'wb') as f:
                f.write(file)
    resp = jsonify({"msg": "Image uploaded!", "data": [1, 2, 3], "id": id})
    resp.status_code = 201
    return resp

@app.route("/classify/<id>")
def classify(id):
    img = caffe.io.load_image("./static/shoe_dataset/" + id + ".jpg")
    global classifier
    prediction = classifier.predict([img], oversample=False).argmax()
    resp = jsonify({"msg": categories[prediction], "data": prediction})
    resp.status_code = 200
    return resp

@app.route("/compare/<id>")
def compare(id):
    img = caffe.io.load_image("./static/shoe_dataset/" + id + ".jpg")
    global classifier
    category = classifier.predict([img], oversample=False).argmax()
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
    sorted_indices = sorted_indices[1:]
    closest = []
    i = 0
    global rev_map
    while len(closest) < 50:
        shoe_id = sorted_indices[i]
        if rev_map[shoe_id] == category:
            closest.append(shoe_id)
        i += 1
    resp = jsonify({"msg": "Closest matches for " + id, "data": closest, "category": category})
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
    valid_images = np.load('valid_images.npy')
    with open('cat_map.pickle') as file1:
        cat_map = pickle.load(file1)
    with open('rev_map.pickle') as file2:
        rev_map = pickle.load(file2)
    app.run(host='0.0.0.0', debug=True)
    #app.run()
    #app.run(host='0.0.0.0')
