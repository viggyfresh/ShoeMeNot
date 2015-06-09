from flask import Flask, request, redirect, url_for, jsonify
import os
import cv2
import caffe
import numpy as np
import json
import pickle
import re
import uuid
from werkzeug import secure_filename
from PIL import Image
import glob

full = False
suffix = ''

color_model = 'flower'
color_width = 227
color_height = 227
color_dim = 4096
color_layer = 'fc6'
color_norm = True
style_model = 'googlenet'
style_width = 224
style_height = 224
style_dim = 1024
style_layer = 'cls2_fc1'
style_norm = True

classifier = None
color_extractor = None
color_transformer = None
color_features = None
style_extractor = None
style_transformer = None
style_features = None
features = None
cat_map = None
rev_map = None
valid_images = None
ip = "128.12.10.36"
port = "5000"
DATA_FOLDER = './static/shoe_dataset/'
UPLOAD_FOLDER = './static/uploads/'
SHARE_FOLDER = './static/favorites/'
ALLOWED_EXTENSIONS = set(['jpg', 'jpeg', 'png', 'tiff'])

if full == True:
    suffix = '_full'

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
    with open(DATA_FOLDER + id + ".txt") as file:
        lines = [line.rstrip('\n') for line in file]
        metadata = {}
        metadata["id"] = lines[0]
        metadata["name"] = lines[1]
        metadata["brand"] = lines[2]
        metadata["color"] = lines[3]
        category = re.search("> .* >", lines[4])
        metadata["category"] = category.group(0)[2:-2]
        if int(id) < 13824:
            metadata["gender"] = "Men's Shoe"
        else:
            metadata["gender"] = "Women's Shoe"
        metadata["price"] = lines[6]
        metadata["stars"] = lines[7]
        metadata["sku"] = lines[8]
        metadata["url"] = lines[9]
        metadata["msg"] = "Shoe data as promised!"
        resp = jsonify(metadata)
        resp.status_code = 200
        return resp

@app.route("/discover")
def discover():
    choices = np.random.choice(valid_images, size=50, replace=False)
    resp = jsonify({"msg": "Got 50 random shoes", "data": choices.tolist()})
    resp.status_code = 200
    return resp

@app.route("/social")
def social():
    names = []
    for file in glob.glob(SHARE_FOLDER + "*.txt"):
        names.append(file[len(SHARE_FOLDER):-4])
    resp = jsonify({"msg": "Got all favorite lists!", "data": names})
    resp.status_code = 200
    return resp

@app.route("/social/<name>")
def get_social(name):
    try:
        f = open(SHARE_FOLDER + name + ".txt")
        lines = f.readlines()
        data = []
        for line in lines:
            data.append(int(line))
        resp = jsonify({"msg": "Got favorites file!", "data": data})
        resp.status_code = 200
        return resp
    except:
        resp = jsonify({"msg": "Couldn't open favorites file!"})
        resp.status_code = 403
        return resp

@app.route("/share/<name>", methods=["POST"])
def share(name):
    try:
        f = open(SHARE_FOLDER + name + ".txt")
        resp = jsonify({"msg": "That name is already taken!"})
        resp.status_code = 403
        return resp
    except:
        ids = request.get_json()
        with open(SHARE_FOLDER + name + ".txt", "wb") as file:
            for id in ids:
                file.write("%s\n" % id)
            resp = jsonify({"msg": "Favorites saved!"})
            resp.status_code = 201
            return resp

def allowed_file(filename):
    return '.' in filename and \
           filename.rsplit('.', 1)[1] in ALLOWED_EXTENSIONS

def extract_color_features(img):
    global color_extractor
    global color_transformer
    global color_features
    color_extractor.blobs['data'].data[...] = color_transformer.preprocess('data', img)
    out = color_extractor.forward()
    curr = color_extractor.blobs[color_layer].data.reshape((color_dim,))
    if color_norm == True:
        curr = curr / np.linalg.norm(curr)
    rev = color_extractor.backward()
    return curr

def extract_style_features(img):
    global style_extractor
    global style_transformer
    global style_features
    style_extractor.blobs['data'].data[...] = style_transformer.preprocess('data', img)
    out = style_extractor.forward()
    curr = style_extractor.blobs[style_layer].data.reshape((style_dim,))
    if style_norm == True:
        curr = curr / np.linalg.norm(curr)
    rev = style_extractor.backward()
    return curr

def extract_features(img):
    c_feats = extract_color_features(img)
    s_feats = extract_style_features(img)
    return np.hstack((c_feats, s_feats, s_feats, s_feats))

def classify(img):
    global classifier
    category = classifier.predict([img], oversample=False).argmax()
    return category

@app.route("/upload", methods=['POST'])
def upload_ios():
    id = str(uuid.uuid4())
    closest = []
    if request.method == 'POST':
        file = request.files['file']
        if file and allowed_file(id + '.jpg'):
            filename = secure_filename(id + '.jpg')
            path = os.path.join(app.config['UPLOAD_FOLDER'], filename)
            file.save(path)
            temp = Image.open(path)
            temp.thumbnail((480, 360), Image.ANTIALIAS)
            temp.save(UPLOAD_FOLDER + id + "_sm.jpg")
            img = caffe.io.load_image(path)
            curr = extract_features(img)
            dists = np.sqrt(np.sum(np.square(features - curr), axis=1))
            sorted_indices = np.argsort(dists)
            i = 0
            while len(closest) < 50:
                shoe_id = sorted_indices[i]
                closest.append(shoe_id)
                i += 1
    resp = jsonify({"msg": "Image uploaded!", "data": closest, "id": id})
    resp.status_code = 201
    return resp

@app.route("/classify/<id>")
def classify_by_id(id):
    img = caffe.io.load_image(DATA_FOLDER + str(id) + ".jpg")
    category = classify(img)
    resp = jsonify({"msg": categories[category], "data": category})
    resp.status_code = 200
    return resp

@app.route("/compare/<id>")
def compare_by_id(id):
    img = caffe.io.load_image(DATA_FOLDER + id + ".jpg")
    category = classify(img)
    curr = extract_features(img)
    dists = np.sqrt(np.sum(np.square(features - curr), axis=1))
    sorted_indices = np.argsort(dists)
    sorted_indices = sorted_indices[1:]
    closest = []
    i = 0
    global rev_map
    while len(closest) < 50:
        shoe_id = sorted_indices[i]
        #if rev_map[shoe_id] == category:
        closest.append(shoe_id)
        i += 1
    resp = jsonify({"msg": "Closest matches for " + id, "data": closest, "category": category})
    resp.status_code = 200
    return resp

@app.route("/compare_color/<id>")
def compare_by_color(id):
    img = caffe.io.load_image(DATA_FOLDER + id + ".jpg")
    category = classify(img)
    curr = extract_color_features(img)
    dists = np.sqrt(np.sum(np.square(color_features - curr), axis=1))
    sorted_indices = np.argsort(dists)
    sorted_indices = sorted_indices[1:]
    closest = []
    i = 0
    global rev_map
    while len(closest) < 50:
        shoe_id = sorted_indices[i]
        #if rev_map[shoe_id] == category:
        closest.append(shoe_id)
        i += 1
    resp = jsonify({"msg": "Closest matches for " + id, "data": closest, "category": category})
    resp.status_code = 200
    return resp

@app.route("/compare_style/<id>")
def compare_by_style(id):
    img = caffe.io.load_image(DATA_FOLDER + id + ".jpg")
    category = classify(img)
    curr = extract_style_features(img)
    dists = np.sqrt(np.sum(np.square(style_features - curr), axis=1))
    sorted_indices = np.argsort(dists)
    sorted_indices = sorted_indices[1:]
    closest = []
    i = 0
    global rev_map
    while len(closest) < 50:
        shoe_id = sorted_indices[i]
        #if rev_map[shoe_id] == category:
        closest.append(shoe_id)
        i += 1
    resp = jsonify({"msg": "Closest matches for " + id, "data": closest, "category": category})
    resp.status_code = 200
    return resp

@app.route("/recompare/<id>")
def recompare_by_id(id):
    img = caffe.io.load_image(UPLOAD_FOLDER + id + ".jpg")
    curr = extract_features(img)
    dists = np.sqrt(np.sum(np.square(features - curr), axis=1))
    sorted_indices = np.argsort(dists)
    closest = []
    i = 0
    global rev_map
    while len(closest) < 50:
        shoe_id = sorted_indices[i]
        closest.append(shoe_id)
        i += 1
    resp = jsonify({"msg": "Closest matches for " + id, "data": closest})
    resp.status_code = 200
    return resp

@app.route("/recompare_color/<id>")
def recompare_by_color(id):
    img = caffe.io.load_image(UPLOAD_FOLDER + id + ".jpg")
    curr = extract_color_features(img)
    dists = np.sqrt(np.sum(np.square(color_features - curr), axis=1))
    sorted_indices = np.argsort(dists)
    closest = []
    i = 0
    global rev_map
    while len(closest) < 50:
        shoe_id = sorted_indices[i]
        closest.append(shoe_id)
        i += 1
    resp = jsonify({"msg": "Closest matches for " + id, "data": closest})
    resp.status_code = 200
    return resp

@app.route("/recompare_style/<id>")
def recompare_by_style(id):
    img = caffe.io.load_image(UPLOAD_FOLDER + id + ".jpg")
    curr = extract_style_features(img)
    dists = np.sqrt(np.sum(np.square(style_features - curr), axis=1))
    sorted_indices = np.argsort(dists)
    closest = []
    i = 0
    global rev_map
    while len(closest) < 50:
        shoe_id = sorted_indices[i]
        closest.append(shoe_id)
        i += 1
    resp = jsonify({"msg": "Closest matches for " + id, "data": closest})
    resp.status_code = 200
    return resp

if __name__ == "__main__":
    caffe.set_mode_cpu()
    classifier = caffe.Classifier('viggynet_class_deploy.prototxt',
                                  'viggynet_class.caffemodel',
                                  mean=np.load('viggynet_class_mean.npy'),
                                  raw_scale=255,
                                  image_dims=(180, 240))

    color_extractor = caffe.Net(color_model + '.prototxt', color_model + '.caffemodel', caffe.TEST)
    color_transformer = caffe.io.Transformer({'data': color_extractor.blobs['data'].data.shape})
    color_transformer.set_transpose('data', (2,0,1))
    color_transformer.set_raw_scale('data', 255)
    color_extractor.blobs['data'].reshape(1, 3, color_width, color_height)
    if color_norm == True:
        color_features = np.load('features_' + color_model + '_' + color_layer + '_norm' + suffix + '.npy')
    else:
        color_features = np.load('features_' + color_model + '_' + color_layer + suffix + '.npy')

    style_extractor = caffe.Net(style_model + '.prototxt', style_model + '.caffemodel', caffe.TEST)
    style_transformer = caffe.io.Transformer({'data': style_extractor.blobs['data'].data.shape})
    style_transformer.set_transpose('data', (2,0,1))
    style_transformer.set_raw_scale('data', 255)
    style_extractor.blobs['data'].reshape(1, 3, style_width, style_height)
    if style_norm == True:
        style_features = np.load('features_' + style_model + '_' + style_layer + '_norm' + suffix + '.npy')
    else:
        style_features = np.load('features_' + style_model + '_' + style_layer + suffix + '.npy')
    features = np.hstack((color_features, style_features, style_features, style_features))
    valid_images = np.load('valid_images' + suffix + '.npy')
    with open('cat_map' + suffix + '.pickle') as file1:
        cat_map = pickle.load(file1)
    with open('rev_map' + suffix + '.pickle') as file2:
        rev_map = pickle.load(file2)
    #app.run(host='0.0.0.0', debug=True)
    app.run(host='0.0.0.0')
